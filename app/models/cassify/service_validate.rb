module Cassify
  class ServiceValidate
    attr_reader :proxies, :extra_attributes, :success, :username, :pgtiou, :error

    def initialize(service, ticket, pgt_url = nil, renew = nil)
      @service = service
      @ticket  = ticket
      @pgt_url = pgt_url
      @renew   = renew
      
      @proxies = []
      @extra_attributes = {}
    end

    def validate
      begin
        service_ticket    = Cassify::ServiceTicket.validate(@service, @ticket)
        @username         = service_ticket.username
        @extra_attributes = service_ticket.granted_by_tgt.extra_attributes || {}
        
        @success = true
        self
      rescue Cassify::Errors.Base => e
        @success = false
        @error = e
        self
      end
    end
  end
end
