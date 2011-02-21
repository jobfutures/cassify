require 'crypt-isaac'

# Misc utility function used throughout by the RubyCAS-Server.
module Cassify
  module Utils
    def random_string(max_length = 29)
      rg =  Crypt::ISAAC.new
      max = 4294619050
      r = "#{Time.now.to_i}r%X%X%X%X%X%X%X%X" %
        [rg.rand(max), rg.rand(max), rg.rand(max), rg.rand(max),
         rg.rand(max), rg.rand(max), rg.rand(max), rg.rand(max)]
      r[0..max_length-1]
    end
    module_function :random_string

    def log_controller_action(controller, params)
      $LOG << "\n"

      /`(.*)'/.match(caller[1])
      method = $~[1]

      if params.respond_to? :dup
        params2 = params.dup
        params2['password'] = '******' if params2['password']
      else
        params2 = params
      end
      $LOG.debug("Processing #{controller}::#{method} #{params2.inspect}")
    end
    module_function :log_controller_action
    
    # It will generate a URI with ticket as parameter
    def service_uri_with_ticket(service, st)
      raise ArgumentError, "Second argument must be a ServiceTicket!" unless st.kind_of? Cassify::Model::ServiceTicket

      # This will choke with a URI::InvalidURIError if service URI is not properly URI-escaped...
      # This exception is handled further upstream (i.e. in the controller).
      service_uri = URI.parse(service)

      if service.include? "?"
        if service_uri.query.empty?
          query_separator = ""
        else
          query_separator = "&"
        end
      else
        query_separator = "?"
      end

      service_with_ticket = service + query_separator + "ticket=" + st.ticket
      service_with_ticket
    end
    module_function :service_uri_with_ticket
    
    # Strips CAS-related parameters from a service URL and normalizes it,
    # removing trailing / and ?. Also converts any spaces to +.
    #
    # For example, "http://google.com?ticket=12345" will be returned as
    # "http://google.com". Also, "http://google.com/" would be returned as
    # "http://google.com".
    #
    # Note that only the first occurance of each CAS-related parameter is
    # removed, so that "http://google.com?ticket=12345&ticket=abcd" would be
    # returned as "http://google.com?ticket=abcd".
    def clean_service_url(dirty_service)
      return dirty_service if dirty_service.blank?
      clean_service = dirty_service.dup
      ['service', 'ticket', 'gateway', 'renew'].each do |p|
        clean_service.sub!(Regexp.new("&?#{p}=[^&]*"), '')
      end

      clean_service.gsub!(/[\/\?&]$/, '') # remove trailing ?, /, or &
      clean_service.gsub!('?&', '?')
      clean_service.gsub!(' ', '+')

      $LOG.debug("Cleaned dirty service URL #{dirty_service.inspect} to #{clean_service.inspect}") if
        dirty_service != clean_service

      return clean_service
    end
    module_function :clean_service_url
  end
end
