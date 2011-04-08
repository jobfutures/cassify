require 'spec_helper'

describe "Cassify Routing" do
  it "should rounte /validate to cas_controller#validate" do
     { :get => '/validate' }.should route_to(:controller => "cas", :action => "validate")
  end

  it "should route /cas to cas_controller#grant" do
     { :get => '/cas' }.should route_to(:controller => "cas", :action => "grant")
  end
end