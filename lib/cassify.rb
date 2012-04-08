require 'active_support/core_ext'
require 'active_support/buffered_logger'
require 'cassify/settings'
require 'cassify/utils'
require 'cassify/engine'
require 'cassify/hooks/service_register'
require 'cassify/strategies/cas_authenticable'


module Cassify
  def self.logger
    @logger ||= ActiveSupport::BufferedLogger.new("log/cas.log")
  end
  
  def self.logger=(logger)
    @logger = logger
  end
  
  Settings.configure do |config|
    config.maximum_unused_login_ticket_lifetime = 1.day
    config.max_lifetime = 1.week
    config.logger = self.logger
  end
end