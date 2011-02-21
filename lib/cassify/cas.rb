require 'uri'
require 'net/https'

module Cassify
  class Cas
    def self.generate_login_ticket(host_name)
      login_ticket = LoginTicket.new(
        :ticket          => "LT-" + Cassify::Utils.random_string,
        :client_hostname => host_name
      )
      login_ticket.save!
      $LOG.debug("Generated login ticket '#{login_ticket.ticket}' for client at '#{login_ticket.client_hostname}'")
      login_ticket
    end

    def generate_service_ticket(service, username, host_name, tgt)
      service_ticket = ServiceTicket.new(
        :ticket             => "ST-" + Cassify::Utils.random_string
        :service            => service
        :username           => username
        :granted_by_tgt_id  => tgt.id
        :client_hostname    => host_name
      )
      service_ticket.save!
      $LOG.debug("Generated service ticket '#{service_ticket.ticket}' for service '#{service_ticket.service}'" +
        " for user '#{service_ticket.username}' at '#{service_ticket.client_hostname}'")
      service_ticket
    end

    def generate_proxy_ticket(target_service, host_name, pgt)
      proxy_ticket = ProxyTicket.new(
        :ticket             => "PT-" + Cassify::Utils.random_string,
        :service            => target_service,
        :username           => pgt.service_ticket.username,
        :granted_by_pgt_id  => pgt.id,
        :granted_by_tgt_id  => pgt.service_ticket.granted_by_tgt.id,
        :client_hostname    => host_name
      )
      proxy_ticket.save!
    
      $LOG.debug("Generated proxy ticket '#{proxy_ticket.ticket}' for target service '#{proxy_ticket.service}'" +
        " for user '#{proxy_ticket.username}' at '#{proxy_ticket.client_hostname}' using proxy-granting" +
        " ticket '#{pgt.ticket}'")
      proxy_ticket
    end

    def generate_proxy_granting_ticket(pgt_url, st)
      uri = URI.parse(pgt_url)
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true

      # Here's what's going on here:
      #
      #   1. We generate a ProxyGrantingTicket (but don't store it in the database just yet)
      #   2. Deposit the PGT and it's associated IOU at the proxy callback URL.
      #   3. If the proxy callback URL responds with HTTP code 200, store the PGT and return it;
      #      otherwise don't save it and return nothing.
      #
      https.start do |conn|
        path = uri.path.empty? ? '/' : uri.path
        path += '?' + uri.query unless (uri.query.nil? || uri.query.empty?)
      
        pgt = ProxyGrantingTicket.new
        pgt.ticket = "PGT-" + Cassify::Utils.random_string(60)
        pgt.iou = "PGTIOU-" + Cassify::Utils.random_string(57)
        pgt.service_ticket_id = st.id
        pgt.client_hostname = @env['HTTP_X_FORWARDED_FOR'] || @env['REMOTE_HOST'] || @env['REMOTE_ADDR']

        # FIXME: The CAS protocol spec says to use 'pgt' as the parameter, but in practice
        #         the JA-SIG and Yale server implementations use pgtId. We'll go with the
        #         in-practice standard.
        path += (uri.query.nil? || uri.query.empty? ? '?' : '&') + "pgtId=#{pgt.ticket}&pgtIou=#{pgt.iou}"

        response = conn.request_get(path)
        # TODO: follow redirects... 2.5.4 says that redirects MAY be followed
        # NOTE: The following response codes are valid according to the JA-SIG implementation even without following redirects
      
        if %w(200 202 301 302 304).include?(response.code)
          # 3.4 (proxy-granting ticket IOU)
          pgt.save!
          $LOG.debug "PGT generated for pgt_url '#{pgt_url}': #{pgt.inspect}"
          pgt
        else
          $LOG.warn "PGT callback server responded with a bad result code '#{response.code}'. PGT will not be stored."
          nil
        end
      end
    end



    def validate_ticket_granting_ticket(ticket)
      $LOG.debug("Validating ticket granting ticket '#{ticket}'")

      if ticket.nil?
        error = "No ticket granting ticket given."
        $LOG.debug error
      elsif tgt = TicketGrantingTicket.find_by_ticket(ticket)
        if settings.config[:maximum_session_lifetime] && Time.now - tgt.created_on > settings.config[:maximum_session_lifetime]
  	tgt.destroy
          error = "Your session has expired. Please log in again."
          $LOG.info "Ticket granting ticket '#{ticket}' for user '#{tgt.username}' expired."
        else
          $LOG.info "Ticket granting ticket '#{ticket}' for user '#{tgt.username}' successfully validated."
        end
      else
        error = "Invalid ticket granting ticket '#{ticket}' (no matching ticket found in the database)."
        $LOG.warn(error)
      end

      [tgt, error]
    end

    def validate_service_ticket(service, ticket, allow_proxy_tickets = false)
      $LOG.debug "Validating service/proxy ticket '#{ticket}' for service '#{service}'"

      if service.nil? or ticket.nil?
        error = Error.new(:INVALID_REQUEST, "Ticket or service parameter was missing in the request.")
        $LOG.warn "#{error.code} - #{error.message}"
      elsif st = ServiceTicket.find_by_ticket(ticket)
        if st.consumed?
          error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' has already been used up.")
          $LOG.warn "#{error.code} - #{error.message}"
        elsif st.kind_of?(Cassify::Model::ProxyTicket) && !allow_proxy_tickets
          error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' is a proxy ticket, but only service tickets are allowed here.")
          $LOG.warn "#{error.code} - #{error.message}"
        elsif Time.now - st.created_on > settings.config[:maximum_unused_service_ticket_lifetime]
          error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' has expired.")
          $LOG.warn "Ticket '#{ticket}' has expired."
        elsif !st.matches_service? service
          error = Error.new(:INVALID_SERVICE, "The ticket '#{ticket}' belonging to user '#{st.username}' is valid,"+
            " but the requested service '#{service}' does not match the service '#{st.service}' associated with this ticket.")
          $LOG.warn "#{error.code} - #{error.message}"
        else
          $LOG.info("Ticket '#{ticket}' for service '#{service}' for user '#{st.username}' successfully validated.")
        end
      else
        error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' not recognized.")
        $LOG.warn("#{error.code} - #{error.message}")
      end

      if st
        st.consume!
      end


      [st, error]
    end

    def validate_proxy_ticket(service, ticket)
      pt, error = validate_service_ticket(service, ticket, true)

      if pt.kind_of?(Cassify::Model::ProxyTicket) && !error
        if not pt.granted_by_pgt
          error = Error.new(:INTERNAL_ERROR, "Proxy ticket '#{pt}' belonging to user '#{pt.username}' is not associated with a proxy granting ticket.")
        elsif not pt.granted_by_pgt.service_ticket
          error = Error.new(:INTERNAL_ERROR, "Proxy granting ticket '#{pt.granted_by_pgt}'"+
            " (associated with proxy ticket '#{pt}' and belonging to user '#{pt.username}' is not associated with a service ticket.")
        end
      end

      [pt, error]
    end

    def validate_proxy_granting_ticket(ticket)
      if ticket.nil?
        error = Error.new(:INVALID_REQUEST, "pgt parameter was missing in the request.")
        $LOG.warn("#{error.code} - #{error.message}")
      elsif pgt = ProxyGrantingTicket.find_by_ticket(ticket)
        if pgt.service_ticket
          $LOG.info("Proxy granting ticket '#{ticket}' belonging to user '#{pgt.service_ticket.username}' successfully validated.")
        else
          error = Error.new(:INTERNAL_ERROR, "Proxy granting ticket '#{ticket}' is not associated with a service ticket.")
          $LOG.error("#{error.code} - #{error.message}")
        end
      else
        error = Error.new(:BAD_PGT, "Invalid proxy granting ticket '#{ticket}' (no matching ticket found in the database).")
        $LOG.warn("#{error.code} - #{error.message}")
      end

      [pgt, error]
    end

    # Takes an existing ServiceTicket object (presumably pulled from the database)
    # and sends a POST with logout information to the service that the ticket
    # was generated for.
    #
    # This makes possible the "single sign-out" functionality added in CAS 3.1.
    # See http://www.ja-sig.org/wiki/display/CASUM/Single+Sign+Out
    def send_logout_notification_for_service_ticket(st)
      uri = URI.parse(st.service)
      http = Net::HTTP.new(uri.host, uri.port)
      #http.use_ssl = true if uri.scheme = 'https'

      time = Time.now
      rand = Cassify::Utils.random_string

      path = uri.path
      path = '/' if path.empty?

      req = Net::HTTP::Post.new(path)
      req.set_form_data(
        'logoutRequest' => %{<samlp:LogoutRequest ID="#{rand}" Version="2.0" IssueInstant="#{time.rfc2822}">
  <saml:NameID></saml:NameID>
  <samlp:SessionIndex>#{st.ticket}</samlp:SessionIndex>
  </samlp:LogoutRequest>}
      )

      begin
        http.start do |conn|
          response = conn.request(req)

          if response.kind_of? Net::HTTPSuccess
            $LOG.info "Logout notification successfully posted to #{st.service.inspect}."
            return true
          else
            $LOG.error "Service #{st.service.inspect} responed to logout notification with code '#{response.code}'!"
            return false
          end
        end
      rescue Exception => e
        $LOG.error "Failed to send logout notification to service #{st.service.inspect} due to #{e}"
        return false
      end
    end
  end
end
