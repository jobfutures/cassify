module Cassify
  class Logger
    include Singleton
    
    def intialize(env)
      FileUtils.mkdir_p log_dir
      @logfile = File.join(log_dir, "#{env}.log")
      @log     = Logger.new @logfile
    end
    
    def self.logfile
      @logfile
    end

    def self.log
      @log
    end

    private
    def log_dir
      File.join(Dir.pwd, 'log')
    end
  end
end
