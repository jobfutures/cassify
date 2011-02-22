require 'singleton'

module Cassify
  class Settings
    include Singleton
    
    attr_accessor :maximum_unused_login_ticket_lifetime

    def
      yield self if block_given?
    end
  end
end
