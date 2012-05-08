require "addressable/uri"

module Cassify
  class ServiceTicket < Ticket
    set_table_name 'casserver_st'

    belongs_to :granted_by_tgt, :class_name => 'TicketGrantingTicket', :foreign_key => :granted_by_tgt_id
      
    before_save :generate_token
    after_save  :log_ticket
    
    def generate_token
      self.ticket = "ST-#{Cassify::Utils.random_string}"
    end
    
    def log_ticket
      Cassify.logger.info <<-EOL
        Generated service ticket '#{ticket}' for service '#{service}' and for user '#{username}'
      EOL
    end

    def matches_service?(service)
      Cassify::Utils.clean_service_url(self.service) == Cassify::Utils.clean_service_url(service)
    end
    
    def extra_attributes
      service_ticket.granted_by_tgt.extra_attributes || {} 
    end
    
    def service_url
      service_uri = Addressable::URI.parse(self.service)
      service_uri.query_values = (service_uri.query_values || {}).merge({ :ticket => self.ticket })
      service_uri.to_s
    end
    
    class << self
      def validate(service, ticket)
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
