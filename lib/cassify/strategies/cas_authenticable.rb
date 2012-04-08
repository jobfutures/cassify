module Cassify
  module Strategies
    class CasAuthenticable < ::Warden::Strategies::Base
      def valid?
        params[:service]
      end
      
      def authenticate!
        begin
         u = Cassify::TicketGrantingTicket.authenticate(cookies['tgt'])
         success!(u)
        rescue Exception => e
          fail("Could not login")
        end
      end
    end 
  end
end

Warden::Strategies.add(:cas_authenticatable, Cassify::Strategies::CasAuthenticable)