module Cassify::Errors  
  class LoginTokenExpired < Base
    def initialize(token)
      super(:TICKET_ERROR, "login token:#{token} is expired")
    end
  end
end