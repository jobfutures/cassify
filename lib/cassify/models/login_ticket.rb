module Cassify
  module Models
    class LoginTicket < Ticket
      set_table_name 'casserver_lt'

      def self.generate!(host_name)
        ticket = LoginTicket.new(
          :ticket          => "LT-#{Cassify::Utils.random_string}",
          :client_hostname => host_name
        )
        ticket.save!
        CasLog.info "Generated login ticket '#{ticket.ticket}' for client at '#{ticket.client_hostname}'"
        ticket
      end

      def self.validate(ticket)
        login_ticket = find_by_ticket(ticket)
        case
        when login_ticket.nil?
          raise Cassify::Error.new :TICKET_ERROR, "Login Ticket was nil"
        when login_ticket.consumed?
          raise Cassify::Error.new :TICKET_ERROR, "Login ticket '#{ticket}' previously used up"
        when login_ticket.expired?
          raise Cassify::Error.new :TICKET_ERROR, "Expired login ticket '#{ticket}'"
        else
          login_ticket.consume!
          login_ticket
        end
      end
    end
  end
end
