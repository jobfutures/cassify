Rails.application.routes.draw do
  devise_for :users, :controllers => { :sessions => "sessions" }
  
  get 'validate', :to  => 'cas#validate', :as => :cas_validate
  get 'cas', :to  => 'cas#grant', :as => :cas_grant
end