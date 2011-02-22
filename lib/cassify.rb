require 'active_record'
require 'logger'
require 'fileutils'

require 'cassify/cas'
require 'cassify/utils'
require 'cassify/logger'
require 'cassify/error'

autoload :Ticket, 'cassify/models/ticket'
autoload :Consumable, 'cassify/models/consumable'
autoload :LoginTicket, 'cassify/models/login_ticket'
autoload :ProxyGrantingTicket, 'cassify/models/proxy_granting_ticket'
autoload :ProxyTicket, 'cassify/models/proxy_ticket'
autoload :ServiceTicket, 'cassify/models/service_ticket'
autoload :TicketGrantingTicket, 'cassify/models/ticket_granting_ticket'

module Cassify
  # Your code goes here...
end

Logger.new(ENV['CAS_ENV'] || "test")
