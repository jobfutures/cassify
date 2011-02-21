require 'spec_helper'

describe Cassify::Auth do
  #before do
  #  @user = User.new(
  #            :name     => "Geoff Podgeson",
  #            :password => "password"
  #          )
  #  @host_name = "http://localhost:3000"
  #end
  #it "should validate if username, password and login ticket are givin" do
  #  Cassify::Cas.generate_login_ticket(host_name)
    #INSERT INTO "casserver_lt" ("ticket", "created_on", "consumed", "client_hostname") VALUES ('LT-1298252766r64BA4EF48A02B1607E', '2011-02-21 01:46:06.482672', NULL, 'localhost') RETURNING "id"
    

   # ticket = Cassify::Auth.login(@user.name, "password", params[:lt])

  #end

  #it "should not be valid if the username, password or login ticket are invalid" do
  #  ticket = Cassify::Auth.login(params[:username], params[:password], params[:lt])

  #end

  it "should validate proxy ticket" do
    
  end
end
