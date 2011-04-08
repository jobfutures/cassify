class SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [ :validate, :cas ]
  before_filter :cas_login_params, :only => [ :new ]

  def create
    begin
      login_ticket = Cassify::LoginTicket.validate(params[:login_ticket])
      resource = warden.authenticate!(:scope => resource_name, :recall => "new")
      set_flash_message(:notice, :signed_in)
      sign_in(resource_name, resource)
      grant_ticket_granting_ticket(resource.email, :roles => resource.roles.map(&:name))
    rescue Cassify::Error => e
      flash[:error] = e
      render :new
    end
  end

  def destroy
    cookies.delete(:tgt)
    signed_in = signed_in?(resource_name)
    sign_out(resource_name)
    set_flash_message :notice, :signed_out if signed_in
    redirect_to params[:destination] || service
  end

  def grant_ticket_granting_ticket(username, extra_attributes = {})
    # Set the ticket granting ticket(TGT) and service ticket(ST)
    # after succesfull authentication
    ticket_granting_ticket = Cassify::TicketGrantingTicket.generate!(username, service, extra_attributes)
    service_ticket         = Cassify::ServiceTicket.generate!(service, username, host_name, ticket_granting_ticket)

    # Set the ticket granting ticket (TGT) in a cookie
    cookies.permanent[:tgt] = {
      :value   => ticket_granting_ticket.to_s,
      :expires => 1.day.from_now
    }
    redirect_to Cassify::Utils.service_uri_with_ticket(service, service_ticket.to_s)
  end

  def cas_login_params
    @service = service
    @ticket  = Cassify::LoginTicket.generate!(service)
  end
  
  private 
    def host_name
      request.referrer
    end

    def service
      url = Cassify::Utils.clean_service_url(params[:service] || host_name)
      url.blank? ? '/' : url
    end
end
