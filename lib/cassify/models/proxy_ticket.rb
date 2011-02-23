module Cassify
  module Models
    class ProxyTicket < ServiceTicket
      belongs_to :granted_by_pgt,
        :class_name => 'Cassify::Model::ProxyGrantingTicket',
        :foreign_key => :granted_by_pgt_id

      def self.generate!(target_service, host_name, proxy_granting_ticket)
        proxy_ticket = ProxyTicket.new(
          :ticket             => "PT-" + Cassify::Utils.random_string,
          :service            => target_service,
          :username           => proxy_granting_ticket.service_ticket.username,
          :granted_by_pgt_id  => proxy_granting_ticket.id,
          :granted_by_tgt_id  => proxy_granting_ticket.service_ticket.granted_by_tgt.id,
          :client_hostname    => host_name
        )
        proxy_ticket.save!

        ProxyTicket.logger.debug("Generated proxy ticket '#{proxy_ticket.ticket}' for target service '#{proxy_ticket.service}'" +
          " for user '#{proxy_ticket.username}' at '#{proxy_ticket.client_hostname}' using proxy-granting" +
          " ticket '#{pgt.ticket}'")
        proxy_ticket
      end
      
      def self.validate(service, ticket)
        super(service, ticket, true)
        proxy_ticket = find_by_ticket(ticket)
        case
        when proxy_ticket.nil?
          raise Cassify::Error.new :TICKET_ERROR, "Proxy ticket was nil"
        when proxy_ticket.granted_by_pgt.nil?
          raise Cassify::Error.new :TICKET_ERROR, "Proxy ticket '#{proxy_ticket.ticket}' belonging to user '#{proxy_ticket.username}' is not associated with a proxy granting ticket."
        when proxy_ticket.granted_by_pgt.service_ticket.nil?
          raise Cassify::Error.new :TICKET_ERROR, <<-EOL
            Proxy granting ticket '#{proxy_ticket.granted_by_pgt.ticket}'
            (associated with proxy ticket '#{proxy_ticket.ticket}' and belonging to user '#{proxy_ticket.username}' is not associated with a service ticket.
          EOL
        end
      end
    end
  end
end
