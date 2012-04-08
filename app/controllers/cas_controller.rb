class CasController < ApplicationController
  prepend_before_filter :authenticate_user!, :only => [:grant]
  
  # Can be Cassify Session new
  def grant
    ticket_granting_ticket = Cassify::TicketGrantingTicket.find_by_ticket(cookies['tgt'])
    service_ticket = generate_service_ticket(service_path, ticket_granting_ticket)
    redirect_to service_ticket.service_url
  end

  # Can be Cassify Session show
  def validate
    begin
      service_ticket = Cassify::ServiceTicket.validate(params[:service], params[:ticket])
      render :template => 'validate_successful.builder', :content_type => :xml, :locals => { :service_ticket => service_ticket }
    rescue Exception => e
      render :template => 'validate_fail.builder', :content_type => :xml, :locals => { :error => e}
    end
  end

private
  def generate_service_ticket(service_path, ticket_granting_ticket)
    ticket = Cassify::ServiceTicket.create!(
      :service            => service_path,
      :username           => ticket_granting_ticket.username,
      :granted_by_tgt     => ticket_granting_ticket,
      :client_hostname    => service_path
    )
  end
  
  def service_path
    Cassify::Utils.clean_service_url(params[:service] || request.referrer)
  end
end
