require 'singleton'

module Cassify
  class Settings
    include Singleton
    
    attr_accessor :maximum_unused_login_ticket_lifetime

    def self.configure
      yield instance if block_given?
    end
    
    def self.maximum_unused_login_ticket_lifetime
      @maximum_unused_login_ticket_lifetime
    end
  end
end
