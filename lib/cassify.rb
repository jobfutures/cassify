require 'active_record'
require 'active_support/core_ext'
require 'logger'
require 'fileutils'
require 'uri'
require 'net/https'
require 'crypt-isaac'

require 'cassify/cas'
require 'cassify/utils'
require 'cassify/settings'

require 'cassify/models/ticket'
require 'cassify/models/login_ticket'
require 'cassify/models/proxy_granting_ticket'
require 'cassify/models/service_ticket'
require 'cassify/models/proxy_ticket'
require 'cassify/models/ticket_granting_ticket'

require 'cassify/service_validate'
require 'cassify/proxy_validate'
require 'cassify/proxy'

if defined?(::Rails::Railtie)
  require 'cassify/railtie'
end

module Cassify
  class CasLog
    include Singleton
    
    attr_reader :logger
    
    def initialize
      logfile = File.exists?("log") ? File.open("log/Cas.log", 'w') : STDERR
      logger = Logger.new(logfile)
    end
    
    def self.log
      instance.logger
    end

    def self.time
      Time.now.strftime('%F-%H %M:%S')
    end

    def self.info(message)
      log.info "#{time} | #{message_to_log(message)}"
    end
    
    def self.error(code, message)
      log.info "#{time} | ERROR: #{code.to_s} - #{message_to_log(message)}"
    end

    def self.warn(message)
      log.info "#{time} | WARNING: #{message_to_log(message)}"
    end

    def self.message_to_log(message)
      message.gsub(/\n/, '').gsub(/\s\s+/,' ').strip
    end
  end
  
  class Error < Exception
    attr_reader :code, :message

    def initialize(code, message)
      @code    = code
      @message = message
      CasLog.error code, message
    end

    def to_s
      message
    end
  end
end

Cassify::Settings.configure do |config|
  config.maximum_unused_login_ticket_lifetime = 1.day
  config.max_lifetime = 1.week
end
