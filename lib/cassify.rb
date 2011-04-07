require 'authentication_system/engine'
require 'authentication_system/setting'

Cassify::Settings.configure do |config|
  config.maximum_unused_login_ticket_lifetime = 1.day
  config.max_lifetime = 1.week
end
