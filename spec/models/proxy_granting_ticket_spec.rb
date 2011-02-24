require 'spec_helper'

describe Cassify::Models::ProxyGrantingTicket do
  
  it "should have to_s method" do
    @ticket_granting_ticket = Cassify::Models::TicketGrantingTicket.generate!("user@user.com", "localhost", :roles => ['user', 'superuser'])
    @service_ticket = Cassify::Models::ServiceTicket.generate!("http://localhost:3000", "user@user.com", "localhost", @ticket_granting_ticket)
    @proxy_granted_ticket = Cassify::Models::ProxyGrantingTicket.generate!("http://localhost:3000", "http://localhost:3000", @service_ticket)
    @proxy_granted_ticket.should_not be_nil
    @proxy_granted_ticket.to_s.should match /^LT-/
  end
end
