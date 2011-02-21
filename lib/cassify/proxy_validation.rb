module Cassify
  class ProxyValidation < ServiceValidation
    def validate!
      t, @error = Cas.validate_proxy_ticket(@service, @ticket)
      @success = t && !@error
      if @success
        @username = t.username
        
        if t.kind_of? ProxyTicket
          @proxies << t.granted_by_pgt.service_ticket.service
        end

        if @pgt_url
          pgt = generate_proxy_granting_ticket(@pgt_url, t)
          @pgtiou = pgt.iou if pgt
        end

        @extra_attributes = t.granted_by_tgt.extra_attributes || {}
      end
      self
    end
  end
end
