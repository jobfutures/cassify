module Cassify
  class Utils
    class << self
      def random_string(max_length = 29)
        ActiveSupport::SecureRandom.base64(max_length)
      end

      def service_uri_with_ticket(service, ticket)
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
      
      def serialize_extra_attribute(builder, value)
        if value.kind_of?(String)
          builder.text! value
        elsif value.kind_of?(Numeric)
          builder.text! value.to_s
        else
          builder.cdata! value.to_yaml
        end
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
