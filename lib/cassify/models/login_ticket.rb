require 'active_record'
require 'active_record/base'

module Cassify
  class LoginTicket < Ticket
    set_table_name 'casserver_lt'
    include Consumable
  end
end