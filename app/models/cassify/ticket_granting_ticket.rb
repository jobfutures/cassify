module Cassify
  class TicketGrantingTicket < Ticket
    set_table_name 'casserver_tgt'

    serialize :extra_attributes

    has_many :granted_service_tickets,
      :class_name => 'ServiceTicket',
      :foreign_key => :granted_by_tgt_id
    
    def self.authenticate(ticket)
      ticket_granting_ticket = Cassify::TicketGrantingTicket.validate(ticket)
      # make sure user need to login again if there was changed
      # Maybe it is better to save user.id rather than user's email
      User.find(ticket_granting_ticket.username)
    end
    
    def self.validate(ticket)
      ticket_granting_ticket = find_by_ticket(ticket)
      case
      when ticket_granting_ticket.nil?
        raise Cassify::Errors::LoginTokenNotFound.new(ticket)
      when ticket_granting_ticket.expired?
        raise Cassify::Errors::LoginTokenExpired.new(ticket)
      else
        ticket_granting_ticket
      end
    end
  end
end
