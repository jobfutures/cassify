module Cassify
  class Auth
    def self.login(username, host_name, login_ticket)
      error = LoginTicket.validate_ticket(login_ticket)
      unless error.nil?
        return TicketGrantingTicket.generate!(username, host_name)
      end
    end

    def logout
      #TODO
    end
  end
end

