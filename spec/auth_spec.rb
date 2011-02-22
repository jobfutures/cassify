require 'spec_helper'

describe Cassify::Auth do
  it "login with an existing ticket" do
    ticket          = Cassify::Models::LoginTicket.generate!("http://localhost:3000")
    granting_ticket = Cassify::Auth.login("user@site.com", "http://localhost:3000", ticket.ticket)
    granting_ticket.should match /TGV/
  end
end
