require 'uri'
require 'net/https'

module Cassify
  class Cas

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
