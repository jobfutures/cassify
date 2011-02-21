module Cassify
  class Auth
    def login(username, login_ticket)
      error = validate_login_ticket(login_ticket)
      unless error.nil?
        return generate_ticket_granting_ticket(username)
      end
    end

    def logout
      #TODO
    end
  end
end

