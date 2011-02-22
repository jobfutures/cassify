module Cassify
  class Auth
    def self.login(username, host_name, login_ticket)
      error = validate_login_ticket(login_ticket)
      unless error.nil?
        return generate_ticket_granting_ticket(username, host_name)
      end
    end

    def logout
      #TODO
    end
    
    def self.validate_login_ticket(ticket)
      #$LOG.debug("Validating login ticket '#{ticket}'")
      
      unless ticket
        #error = _("Your login request did not include a login ticket. There may be a problem with the authentication system.")
        #$LOG.warn "Missing login ticket."
        #return error
      end 
      
      login_ticket = Models::LoginTicket.find_by_ticket(ticket)
      unless login_ticket
        #error = _("The login ticket you provided is invalid. There may be a problem with the authentication system.")
        #$LOG.warn "Invalid login ticket '#{ticket}'"
        #return error
      end
      
      if login_ticket.consumed?
        #error = _("The login ticket you provided has already been used up. Please try logging in again.")
        #$LOG.warn "Login ticket '#{ticket}' previously used up"
      elsif Time.now - login_ticket.created_on < Time.now - Settings.maximum_unused_login_ticket_lifetime
        #$LOG.info "Login ticket '#{ticket}' successfully validated"
      else
        #error = _("You took too long to enter your credentials. Please try again.")
        #$LOG.warn "Expired login ticket '#{ticket}'"
      end

      login_ticket.consume!
    end
    
    # Creates a TicketGrantingTicket for the given username. This is done when the user logs in
    # for the first time to establish their SSO session (after their credentials have been validated).
    #
    # The optional 'extra_attributes' parameter takes a hash of additional attributes
    # that will be sent along with the username in the CAS response to subsequent
    # validation requests from clients.
    def self.generate_ticket_granting_ticket(username, host_name, extra_attributes = {})
      # 3.6 (ticket granting cookie/ticket)
      ticket_granting_ticket = TicketGrantingTicket.new(
                                :ticket           => "TGC-" + Cassify::Utils.random_string,
                                :username         => username,
                                :extra_attributes => extra_attributes,
                                :client_hostname  => host_name
                              )
      ticket_granting_ticket.save!
      
      #$LOG.debug("Generated ticket granting ticket '#{ticket_granting_ticket.ticket}' for user" + 
      #  " '#{ticket_granting_ticket.username}' at '#{ticket_granting_ticket.client_hostname}'" +
      #  (extra_attributes.blank? ? "" : " with extra attributes #{extra_attributes.inspect}"))
      ticket_granting_ticket
    end
  end
end

