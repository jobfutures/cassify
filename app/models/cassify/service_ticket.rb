module Cassify
  class ServiceTicket < Ticket
    set_table_name 'casserver_st'

    belongs_to :granted_by_tgt,
      :class_name => 'TicketGrantingTicket',
      :foreign_key => :granted_by_tgt_id
      
    after_save :log_ticket
    
    def log_ticket
      CasLog.info <<-EOL
        Generated service ticket '#{ticket}' for service '#{service}' 
        for user '#{username}' at '#{client_hostname}'
      EOL
    end

    def matches_service?(service)
      Cassify::Utils.clean_service_url(self.service) == Cassify::Utils.clean_service_url(service)
    end
    
    class << self
      def generate!(service, username, host_name, ticket_granting_ticket)
        ticket = new(
          :ticket             => "ST-#{Cassify::Utils.random_string}",
          :service            => service,
          :username           => username,
          :granted_by_tgt_id  => ticket_granting_ticket.id,
          :client_hostname    => host_name
        )

        if ticket.save!
          ticket
        end
      end
    
      def validate(service, ticket, allow_proxy_tickets = false)
        service_ticket = find_by_ticket(ticket)
        case
        when service_ticket.nil?
          raise Cassify::Errors::Base.new :TICKET_ERROR, "Service ticket was nil"
        when service_ticket.consumed?
          raise Cassify::Errors::Base.new :TICKET_ERROR, "Expired service ticket '#{ticket}'"
        when !service_ticket.matches_service?(service)
          raise Cassify::Errors::Base.new :TICKET_ERROR, <<-EOL
            The ticket '#{ticket}' belonging to user '#{service_ticket.username}' is valid,
            but the requested service '#{service}' does not match the service '#{service_ticket.service}'
            associated with this ticket.
          EOL
        else
          service_ticket.consume!
          service_ticket
        end
      end
    end  
  end
end
