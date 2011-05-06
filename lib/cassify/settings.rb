require 'singleton'

module Cassify
  class Settings
    include Singleton
    
    attr_accessor :maximum_unused_login_ticket_lifetime, :max_lifetime, :logger

    def self.configure
      yield instance if block_given?
    end
    
    def self.method_missing(m, *args, &block)
      begin
        instance.send(m)
      rescue
        super
      end
    end
  end
end
