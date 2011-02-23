module Cassify
  class ServiceValidate
    attr_reader :proxies, :extra_attributes, :success, :username, :pgtiou, :error

    def intialize(service, ticket, pgt_url = nil, renew = nil)
      @service = service
      @ticket  = ticket
      @pgt_url = pgt_url
      @renew   = renew
      
      @proxies = []
      @extra_attributes = {}
    end

    def validate!
      st, @error = ServiceTicket.validate_ticket(@service, @ticket)
      @success = st && !@error

      if @success
        @username = st.username
        if @pgt_url
          pgt = Cas.generate_proxy_granting_ticket(@pgt_url, st)
          @pgtiou = pgt.iou if pgt
        end
        @extra_attributes = st.granted_by_tgt.extra_attributes || {}
      end
      self
    end
  end
end
