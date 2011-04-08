module Cassify
  class ProxyGrantingTicket < Ticket
    @url = nil
    attr_accessor :url
    set_table_name 'casserver_pgt'
    
    belongs_to :service_ticket
    has_many :granted_proxy_tickets,
      :class_name => 'ProxyTicket',
      :foreign_key => :granted_by_pgt_id
    
    validate :callback_uri_should_be_valid
    after_save :log_ticket
    
    def callback_uri_should_be_valid
      uri = URI.parse(url)
      path = uri.path.empty? ? '/' : uri.path
      path += '?' + uri.query unless (uri.query.nil? || uri.query.empty?)
      path += (uri.query.nil? || uri.query.empty? ? '?' : '&') + "pgtId=#{ticket}&pgtIou=#{iou}"
      
      https = Net::HTTP.new(uri.host,uri.port)
      https.use_ssl = true      
      begin
        https.start do |conn|
          response = conn.request_get(path)
          unless %w(200 202 301 302 304).include?(response.code)
            errors.add(:url, "PGT callback server responded with a bad result code '#{response.code}'")
          end
        end
      rescue Errno::ECONNREFUSED
        errors.add(:pgt_url, "#{url} is not reachable")
      end
    end
    
    def log_ticket
      logger.debug "PGT generated for pgt_url '#{pgt_url}': #{inspect}"
    end
    
    def self.generate!(pgt_url, host_name, st)        
      pgt = ProxyGrantingTicket.new(
        :ticket             => "PGT-" + Cassify::Utils.random_string(60),
        :iou                => "PGTIOU-" + Cassify::Utils.random_string(57),
        :service_ticket_id  => st.id,
        :client_hostname    => host_name
      )
      pgt.url = pgt_url
      if pgt.save
        pgt
      else
        nil
      end
    end
    
    def self.validate_ticket(ticket)
      unless ticket
        error = Error.new(:INVALID_REQUEST, "pgt parameter was missing in the request.")
        logger.warn("#{error.code} - #{error.message}")
        return [nil, error]
      end
      
      pgt = ProxyGrantingTicket.find_by_ticket(ticket)
      unless pgt
        error = Error.new(:BAD_PGT, "Invalid proxy granting ticket '#{ticket}' (no matching ticket found in the database).")
        logger.warn("#{error.code} - #{error.message}")
        return [nil, error]
      end
      
      if pgt.service_ticket
        logger.info("Proxy granting ticket '#{ticket}' belonging to user '#{pgt.service_ticket.username}' successfully validated.")
      else
        error = Error.new(:INTERNAL_ERROR, "Proxy granting ticket '#{ticket}' is not associated with a service ticket.")
        logger.error("#{error.code} - #{error.message}")
      end
      [pgt, error]
    end
  end
end
