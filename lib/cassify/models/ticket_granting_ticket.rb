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
