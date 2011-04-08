require 'spec_helper'

describe "Session routing" do
  it "should route /users/sign_in to sessions_controller#create" do
     { :get => '/users/sign_in' }.should route_to(:controller => "sessions", :action => "create")
  end
  
  it "should route /users/sign_out to sessions_controller#destory" do
     { :get => '/users/sign_out' }.should route_to(:controller => "sessions", :action => "destory")
  end
end