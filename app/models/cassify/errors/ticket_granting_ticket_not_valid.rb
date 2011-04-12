module Cassify::Errors  
  class TicketGrantingTicketNotValid < Base
      def initialize()
        super(:TICKET_ERROR, "Previous login token is not valid")
      end
  end
end