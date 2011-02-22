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
        logger.debug("Generated login ticket '#{ticket.ticket}' for client at '#{ticket.client_hostname}'")
        ticket
      end
      
      def self.validate_ticket(ticket)
        logger.debug("Validating login ticket '#{ticket}'")

        unless ticket
          error = _("Your login request did not include a login ticket. There may be a problem with the authentication system.")
          logger.warn "Missing login ticket."
          return error
        end 

        login_ticket = Models::LoginTicket.find_by_ticket(ticket)
        unless login_ticket
          error = _("The login ticket you provided is invalid. There may be a problem with the authentication system.")
          logger.warn "Invalid login ticket '#{ticket}'"
          return error
        end

        if login_ticket.consumed?
          error = _("The login ticket you provided has already been used up. Please try logging in again.")
          logger.warn "Login ticket '#{ticket}' previously used up"
        elsif Time.now - login_ticket.created_on < Time.now - Settings.maximum_unused_login_ticket_lifetime
          logger.info "Login ticket '#{ticket}' successfully validated"
        else
          error = _("You took too long to enter your credentials. Please try again.")
          logger.warn "Expired login ticket '#{ticket}'"
        end

        login_ticket.consume!
      end
    end
  end
end
