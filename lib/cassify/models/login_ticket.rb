require 'active_record'
require 'active_record/base'

module Cassify
  module Models
    class LoginTicket < Ticket
      set_table_name 'casserver_lt'
      include Consumable
      
      def self.generate!(host_name)
        ticket = LoginTicket.new(
          :ticket          => "LT-" + Cassify::Utils.random_string,
          :client_hostname => host_name
        )
        ticket.save!
        LoginTicket.logger.debug("Generated login ticket '#{ticket.ticket}' for client at '#{ticket.client_hostname}'")
        ticket
      end
    end
  end
end
