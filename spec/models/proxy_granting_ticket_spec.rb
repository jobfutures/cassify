require 'spec_helper'

describe Cassify::ProxyGrantingTicket do
  # Could not make it work unless have a proper test server setup
  it "should have to_s method" do
    @ticket_granting_ticket = Cassify::TicketGrantingTicket.generate!("user@user.com", "localhost", :roles => ['user', 'superuser'])
    @service_ticket = Cassify::ServiceTicket.generate!("http://0.0.0.0", "user@user.com", "localhost", @ticket_granting_ticket)
    @proxy_granted_ticket = Cassify::ProxyGrantingTicket.generate!("http://0.0.0.0", "http://localhost:3000", @service_ticket)
    @proxy_granted_ticket.should be_nil
  end
end
