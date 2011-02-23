module Cassify
  class Utils
    class << self
      def random_string(max_length = 29)
        rg  =  Crypt::ISAAC.new
        max = 4294619050
        ar  = [rg.rand(max), rg.rand(max), rg.rand(max), rg.rand(max), rg.rand(max), rg.rand(max), rg.rand(max), rg.rand(max)]
        r   = "#{Time.now.to_i}r%X%X%X%X%X%X%X%X" % ar
        r[0..max_length-1]
      end

      def self.service_uri_with_ticket(service, ticket)
        service_uri = URI.parse(service)
        sep = if service.include? "?"
                if service_uri.query.empty?
                  ""
                else
                  "&"
                end
              else
                "?"
              end
        service_with_ticket = "#{service}#{sep}ticket=#{ticket}"
        service_with_ticket
      end
      
      def clean_service_url(dirty_service)
        return dirty_service if dirty_service.blank?
        clean_service = dirty_service.dup
        ['service', 'ticket', 'gateway', 'renew'].each do |p|
          clean_service.sub!(Regexp.new("&?#{p}=[^&]*"), '')
        end
        clean_service.gsub!(/[\/\?&]$/, '')
        clean_service.gsub!('?&', '?')
        clean_service.gsub!(' ', '+')
        clean_service
      end
    end
  end
end
