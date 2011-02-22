require 'active_record'
require 'active_record/base'

module Cassify
  module Models
    class TicketGrantingTicket < Ticket
      set_table_name 'casserver_tgt'

      serialize :extra_attributes

      has_many :granted_service_tickets,
        :class_name => 'Cassify::Model::ServiceTicket',
        :foreign_key => :granted_by_tgt_id
        
      # Creates a TicketGrantingTicket for the given username. This is done when the user logs in
      # for the first time to establish their SSO session (after their credentials have been validated).
      #
      # The optional 'extra_attributes' parameter takes a hash of additional attributes
      # that will be sent along with the username in the CAS response to subsequent
      # validation requests from clients.
      def self.generate!(username, host_name, extra_attributes = {})
        # 3.6 (ticket granting cookie/ticket)
        ticket = TicketGrantingTicket.new(
                                  :ticket           => "TGC-" + Cassify::Utils.random_string,
                                  :username         => username,
                                  :extra_attributes => extra_attributes,
                                  :client_hostname  => host_name
                                )
        ticket.save!

        logger.debug("Generated ticket granting ticket '#{ticket.ticket}' for user" + 
          " '#{ticket.username}' at '#{ticket.client_hostname}'" +
          (extra_attributes.blank? ? "" : " with extra attributes #{extra_attributes.inspect}"))
        ticket
      end
      
      def validate_ticket(ticket)
        logger.debug("Validating ticket granting ticket '#{ticket}'")

        unless ticket
          error = "No ticket granting ticket given."
          logger.debug error
          return [nil, error]
        end
        
        tgt = TicketGrantingTicket.find_by_ticket(ticket)
        unless tgt
          error = "Invalid ticket granting ticket '#{ticket}' (no matching ticket found in the database)."
          logger.warn(error)
          return [nil, error]        
        end
        
        if settings.config[:maximum_session_lifetime] && Time.now - tgt.created_on > settings.config[:maximum_session_lifetime]
          tgt.destroy
          error = "Your session has expired. Please log in again."
          logger.info "Ticket granting ticket '#{ticket}' for user '#{tgt.username}' expired."
        else
          logger.info "Ticket granting ticket '#{ticket}' for user '#{tgt.username}' successfully validated."
        end

        [tgt, error]
      end
    end
  end
end
