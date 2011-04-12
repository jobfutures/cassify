module Cassify
  class CasLog
    include Singleton
    
    attr_reader :logger
    
    def initialize
      logfile = File.exists?("log") ? File.open("log/Cas.log", 'w') : STDERR
      @logger = Logger.new(logfile)
    end
    
    def self.log
      instance.logger
    end

    def self.time
      Time.now.strftime('%F-%H %M:%S')
    end

    def self.info(message)
      self.log.info "#{time} | #{message_to_log(message)}"
    end
    
    def self.error(code, message)
      self.log.info "#{time} | ERROR: #{code.to_s} - #{message_to_log(message)}"
    end

    def self.warn(message)
      self.log.info "#{time} | WARNING: #{message_to_log(message)}"
    end

    def self.message_to_log(message)
      message.gsub(/\n/, '').gsub(/\s\s+/,' ').strip
    end
  end
  
end