class SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [ :validate, :cas ]
  before_filter :cas_login_params, :only => [ :new ]
  
  def create
    login_ticket = Cassify::Models::LoginTicket.validate(params[:login_ticket])
    if login_ticket
      # Warden will already redirect to the new page before now if the authentication fails
      resource = warden.authenticate!(:scope => resource_name, :recall => "new")
      set_flash_message(:notice, :signed_in)
      sign_in(resource_name, resource)
    
      # Set the ticket granting ticket(TGT) and service ticket(ST) 
      # after succesfull authentication
      ticket_granting_ticket = Cassify::Models::TicketGrantingTicket.generate!(resource.email, service, :roles => resource.roles.map(&:name))
      service_ticket         = Cassify::Models::ServiceTicket.generate!(service, resource.email, host_name, ticket_granting_ticket)
    
      # Set the ticket granting ticket (TGT) in a cookie
      cookies.permanent[:tgt] = {
        :value   => ticket_granting_ticket.to_s,
        :expires => 1.day.from_now
      }
      redirect_to Cassify::Utils.service_uri_with_ticket(service, service_ticket.to_s)
    else
      render_with_scope :new
    end
  end

  def destroy
    cookies.delete(:tgt)
    signed_in = signed_in?(resource_name)
    sign_out_and_redirect(resource_name)
    set_flash_message :notice, :signed_out if signed_in
  end

  def host_name
    request.referrer
  end

  def service
    Cassify::Utils.clean_service_url(params[:service] || request.referrer)
  end
  
  def cas_login_params
    @service = service
    @ticket  = Cassify::Models::LoginTicket.generate!(service)
  end
end
