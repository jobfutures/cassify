require 'active_record'
require 'active_record/base'

module Cassify
  module Models
    class ServiceTicket < Ticket
      set_table_name 'casserver_st'
      include Consumable

      belongs_to :granted_by_tgt,
        :class_name => 'Cassify::Model::TicketGrantingTicket',
        :foreign_key => :granted_by_tgt_id
      has_one :proxy_granting_ticket,
        :foreign_key => :created_by_st_id

      def self.generate!(service, username, host_name, tgt)
        ticket = ServiceTicket.new(
          :ticket             => "ST-" + Cassify::Utils.random_string,
          :service            => service,
          :username           => username,
          :granted_by_tgt_id  => tgt.id,
          :client_hostname    => host_name
        )
        ticket.save!
        ServiceTicket.logger.debug("Generated service ticket '#{ticket.ticket}' for service '#{ticket.service}'" +
          " for user '#{ticket.username}' at '#{ticket.client_hostname}'")
        ticket
      end
      
      def self.validate_ticket(service, ticket, allow_proxy_tickets = false)
        logger.debug "Validating service/proxy ticket '#{ticket}' for service '#{service}'"

        if service.nil? or ticket.nil?
          error = Error.new(:INVALID_REQUEST, "Ticket or service parameter was missing in the request.")
          logger.warn "#{error.code} - #{error.message}"
        elsif st = ServiceTicket.find_by_ticket(ticket)
          if st.consumed?
            error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' has already been used up.")
            logger.warn "#{error.code} - #{error.message}"
          elsif st.kind_of?(Cassify::Model::ProxyTicket) && !allow_proxy_tickets
            error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' is a proxy ticket, but only service tickets are allowed here.")
            logger.warn "#{error.code} - #{error.message}"
          elsif Time.now - st.created_on > settings.config[:maximum_unused_service_ticket_lifetime]
            error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' has expired.")
            logger.warn "Ticket '#{ticket}' has expired."
          elsif !st.matches_service? service
            error = Error.new(:INVALID_SERVICE, "The ticket '#{ticket}' belonging to user '#{st.username}' is valid,"+
              " but the requested service '#{service}' does not match the service '#{st.service}' associated with this ticket.")
            logger.warn "#{error.code} - #{error.message}"
          else
            logger.info("Ticket '#{ticket}' for service '#{service}' for user '#{st.username}' successfully validated.")
          end
        else
          error = Error.new(:INVALID_TICKET, "Ticket '#{ticket}' not recognized.")
          logger.warn("#{error.code} - #{error.message}")
        end

        if st
          st.consume!
        end


        [st, error]
      end
        
      def matches_service?(service)
        Cassify::CAS.clean_service_url(self.service) ==
          Cassify::CAS.clean_service_url(service)
      end
    end
  end
end
