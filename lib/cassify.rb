require 'active_support/core_ext'
require 'cassify/settings'
require 'cassify/utils'
require 'cassify/engine'

module Cassify
  def self.logger
    @logger ||= Logger.new("log/Cas.log")
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