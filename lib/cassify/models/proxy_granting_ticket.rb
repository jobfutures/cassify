module Cassify
  module Models
    class ProxyGrantingTicket < Ticket
      set_table_name 'casserver_pgt'
      belongs_to :service_ticket
      has_many :granted_proxy_tickets,
        :class_name => 'Cassify::Model::ProxyTicket',
        :foreign_key => :granted_by_pgt_id
      
      # TODO: Need refactoring
      # Move https validate part to a new validation method
      # Create a new attribute for pgt_url
      def self.generate!(pgt_url, host_name, st)

        uri = URI.parse(pgt_url)
        path = uri.path.empty? ? '/' : uri.path
        path += '?' + uri.query unless (uri.query.nil? || uri.query.empty?)
        
        https = Net::HTTP.new(uri.host,uri.port)
        https.use_ssl = true

        # Here's what's going on here:
        #
        #   1. We generate a ProxyGrantingTicket (but don't store it in the database just yet)
        #   2. Deposit the PGT and it's associated IOU at the proxy callback URL.
        #   3. If the proxy callback URL responds with HTTP code 200, store the PGT and return it;
        #      otherwise don't save it and return nothing.
        #
        pgt = ProxyGrantingTicket.new(
          :ticket             => "PGT-" + Cassify::Utils.random_string(60),
          :iou                => "PGTIOU-" + Cassify::Utils.random_string(57),
          :service_ticket_id  => st.id,
          :client_hostname    => host_name
        )

        # FIXME: The CAS protocol spec says to use 'pgt' as the parameter, but in practice
        #         the JA-SIG and Yale server implementations use pgtId. We'll go with the
        #         in-practice standard.
        path += (uri.query.nil? || uri.query.empty? ? '?' : '&') + "pgtId=#{pgt.ticket}&pgtIou=#{pgt.iou}"
              
        https.start do |conn|
          response = conn.request_get(path)
          # TODO: follow redirects... 2.5.4 says that redirects MAY be followed
          # NOTE: The following response codes are valid according to the JA-SIG implementation even without following redirects

          if %w(200 202 301 302 304).include?(response.code)
            # 3.4 (proxy-granting ticket IOU)
            pgt.save!
            logger.debug "PGT generated for pgt_url '#{pgt_url}': #{pgt.inspect}"
            pgt
          else
            logger.warn "PGT callback server responded with a bad result code '#{response.code}'. PGT will not be stored."
            nil
          end
        end
      end
      
      def self.validate_ticket(ticket)
        unless ticket
          error = Error.new(:INVALID_REQUEST, "pgt parameter was missing in the request.")
          logger.warn("#{error.code} - #{error.message}")
          return [nil, error]
        end
        
        pgt = ProxyGrantingTicket.find_by_ticket(ticket)
        unless pgt
          error = Error.new(:BAD_PGT, "Invalid proxy granting ticket '#{ticket}' (no matching ticket found in the database).")
          logger.warn("#{error.code} - #{error.message}")
          return [nil, error]
        end
        
        if pgt.service_ticket
          logger.info("Proxy granting ticket '#{ticket}' belonging to user '#{pgt.service_ticket.username}' successfully validated.")
        else
          error = Error.new(:INTERNAL_ERROR, "Proxy granting ticket '#{ticket}' is not associated with a service ticket.")
          logger.error("#{error.code} - #{error.message}")
        end
        [pgt, error]
      end
    end
  end
end
