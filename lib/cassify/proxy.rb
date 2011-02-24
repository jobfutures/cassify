module Cassify
  class Proxy
    attr_reader :proxy_ticket, :error, :success

    def initialize(ticket, target_service)
      @ticket         = ticket
      @target_service = target_service
    end

    def validate
      begin
        proxy_granting_ticket = Cassify::Models::ProxyGrantingTicket.validate(@ticket)
        @proxy_ticket = Cassify::Models::ProxyTicket.generate!(@target_service, proxy_granting_ticket)
      rescue Cassify::Error => e
        @success = false
        @error = e
      end
    end
  end
end
