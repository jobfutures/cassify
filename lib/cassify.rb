require 'active_record'
require 'logger'
require 'fileutils'

require 'cassify/cas'
require 'cassify/utils'
require 'cassify/error'
require 'cassify/auth'
require 'cassify/settings'

require 'cassify/models/ticket'
require 'cassify/models/consumable'
require 'cassify/models/login_ticket'
require 'cassify/models/proxy_granting_ticket'
require 'cassify/models/service_ticket'
require 'cassify/models/proxy_ticket'
require 'cassify/models/ticket_granting_ticket'

require 'cassify/service_validator'
require 'cassify/proxy_validator'

#autoload :Ticket, 'cassify/models/ticket'
#autoload :Consumable, 'cassify/models/consumable'
#autoload :LoginTicket, 'cassify/models/login_ticket'
#autoload :ProxyGrantingTicket, 'cassify/models/proxy_granting_ticket'
#autoload :ProxyTicket, 'cassify/models/proxy_ticket'
#autoload :ServiceTicket, 'cassify/models/service_ticket'
#autoload :TicketGrantingTicket, 'cassify/models/ticket_granting_ticket'

module Cassify
  # Your code goes here...
end

Logger.new("log/cas.log")

Cassify::Settings.configure do |config|
  config.maximum_unused_login_ticket_lifetime = 1.day
end
