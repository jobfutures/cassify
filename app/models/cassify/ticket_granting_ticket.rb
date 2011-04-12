module Cassify
  class TicketGrantingTicket < Ticket
    set_table_name 'casserver_tgt'

    serialize :extra_attributes

    has_many :granted_service_tickets,
      :class_name => 'ServiceTicket',
      :foreign_key => :granted_by_tgt_id
      
    def self.generate!(username, host_name, extra_attributes = {})
      ticket = new(
        :ticket           => "TGC-#{Cassify::Utils.random_string}",
        :username         => username,
        :extra_attributes => extra_attributes,
        :client_hostname  => host_name
      )

      if ticket.save!
        log = []
        log << "Generated ticket granting ticket '#{ticket.ticket}' for user '#{ticket.username}' at '#{ticket.client_hostname}'"
        log << "with extra attributes #{extra_attributes.inspect}" unless extra_attributes.blank?
        CasLog.info log.join(' ')
        ticket
      end
    end
    
    def self.validate(ticket)
      ticket_granting_ticket = find_by_ticket(ticket)
      case
      when ticket_granting_ticket.nil?
        raise Cassify::Errors.TicketGrantingTicketNotValid.new
      when ticket_granting_ticket.expired?
        raise Cassify::Errors.TicketGrantingTicketNotValid.new
      else
        ticket_granting_ticket
      end
    end
  end
end
