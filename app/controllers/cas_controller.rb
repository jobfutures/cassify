class CasController < ApplicationController
  before_filter :authenticate_user!, :except => [ :grant, :validate ]
  
  # Can be Cassify Session new
  def grant
    begin
      ticket_granting_ticket = Cassify::TicketGrantingTicket.validate(cookies[:tgt])
      # make sure user need to login again if their was changed
      # Maybe it is better to save user.id rather than user's email
      User.find_by_email!(ticket_granting_ticket.username)
      service_ticket = generate_service_ticket(service_path, ticket_granting_ticket)
      redirect_to Cassify::Utils.service_uri_with_ticket(service_path, service_ticket.to_s)
    rescue Exception => e
      flash[:error] = e.message
      generate_login_ticket
      redirect_to new_user_session_path
    end
  end

  # Can be Cassify Session show
  def validate
    begin
      service_ticket = Cassify::ServiceTicket.validate(params[:service], params[:ticket])
      render :template => 'service_validate.builder', :content_type => :xml, :locals => { :service_ticket => service_ticket }
    rescue Exception => e
      render :template => 'validate_error.builder', :content_type => :xml, :locals => { :error => e}
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
    
    def generate_login_ticket
      unless service_path.blank?
        login_ticket = Cassify::LoginTicket.generate!(service_path)
        session[:login_ticket] = login_ticket.ticket  
      end
    end
    
    def service_path
      Cassify::Utils.clean_service_url(params[:service] || request.referrer)
    end
end
