class SessionsController < Devise::SessionsController
  skip_before_filter :authenticate
  
  protected
  def after_sign_out_path_for(resource_or_scope)
    service_path || super(resource_or_scope)
  end

  def service_path
    Cassify::Utils.clean_service_url(params[:destination] || request.referrer)
  end
end  
