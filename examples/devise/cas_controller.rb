class CasController < ApplicationController
  before_filter :authenticate_user!, :except => [ :grant, :validate ]

  def grant
    begin
      ticket_granting_ticket = Cassify::Models::TicketGrantingTicket.validate(cookies[:tgt])
      service_ticket         = Cassify::Models::ServiceTicket.generate!(service, ticket_granting_ticket.username, host_name, ticket_granting_ticket)
      redirect_to Cassify::Utils.service_uri_with_ticket(service, service_ticket.to_s)
    rescue Cassify::Error => e
      flash[:error] = e.message
      redirect_to new_user_session_path(:service => service)
    end
  end

  def validate
    @validator = Cassify::ServiceValidate.new(params[:service], params[:ticket], params[:service] || request.referrer).validate
    if @validator.success
      render :template => 'service_validate.builder', :content_type => :xml
    else
      render :template => 'validate_error.builder', :content_type => :xml
    end
    
  end
  
  def host_name
    request.referrer
  end

  def service
    Cassify::Utils.clean_service_url(params[:service] || request.referrer)
  end
end
