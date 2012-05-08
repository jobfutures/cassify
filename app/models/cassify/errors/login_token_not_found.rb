module Cassify::Errors  
  class LoginTokenNotFound < Base
    def initialize(token)
      super(:TICKET_ERROR, "Could not find ticket with login token:#{token}")
    end
  end
end