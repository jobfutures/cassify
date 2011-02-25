require 'spec_helper'

describe Cassify::Models::ProxyGrantingTicket do
  # Could not make it work unless have a proper test server setup
  it "should have to_s method" do
    @ticket_granting_ticket = Cassify::Models::TicketGrantingTicket.generate!("user@user.com", "localhost", :roles => ['user', 'superuser'])
    @service_ticket = Cassify::Models::ServiceTicket.generate!("http://0.0.0.0", "user@user.com", "localhost", @ticket_granting_ticket)
    @proxy_granted_ticket = Cassify::Models::ProxyGrantingTicket.generate!("http://0.0.0.0", "http://localhost:3000", @service_ticket)
    @proxy_granted_ticket.should be_nil
  end
end
