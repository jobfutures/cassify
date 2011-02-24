module Cassify
  class ProxyValidate < ServiceValidate
    def validate
      begin
        proxy_ticket      = Cassify::Models::ProxyTicket.validate(@service, @ticket)
        @extra_attributes = proxy_ticket.granted_by_tgt.extra_attributes || {}
        
        if proxy_ticket.kind_of? ProxyTicket
          @proxies << proxy_ticket.granted_by_pgt.service_ticket.service
        end

        #if @pgt_url
        #  pgt = generate_proxy_granting_ticket(@pgt_url, t)
        #  @pgtiou = pgt.iou if pgt
        #end

        @success = true
        self
      rescue Cassify::Error => e
        @success = false
        @error = e
        self
      end
    end
  end
end
