require 'spec_helper'
require 'builder'

describe Cassify::ProxyValidate do
  it "validate the ticket and return proxy object" do
    service = "http://localhost:3000"
    ticket          = Cassify::Models::LoginTicket.generate!(service)
    granting_ticket = Cassify::Auth.login("user@site.com", service, ticket.ticket)
    
    response = Cassify::ProxyValidate.new(service, granting_ticket.ticket).validate!
    STDERR.puts response.inspect
  end
end
