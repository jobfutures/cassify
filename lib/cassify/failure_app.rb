require 'devise/failure_app'
module Cassify
  class FailureApp < Devise::FailureApp

  protected
    def attempted_path
      if params[:service]
        params[:service]
      else
        warden_options[:attempted_path]
      end
    end
  end  
end
