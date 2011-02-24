require 'spec_helper'

describe Cassify::ServiceValidate do
  before do
    @ticket_granting_ticket = Cassify::Models::TicketGrantingTicket.generate!("user@user.com", "localhost", :roles => ['user', 'superuser'])
    @service_ticket = Cassify::Models::ServiceTicket.generate!("http://localhost:3000", "user@user.com", "localhost", @ticket_granting_ticket)
  end

  it "should return valid object when passed a correct service ticket" do
    validator = Cassify::ServiceValidate.new("http://localhost:3000", @service_ticket.ticket).validate
    validator.success.should be_true
  end
  
  it "should have the username" do
    validator = Cassify::ServiceValidate.new("http://localhost:3000", @service_ticket.ticket).validate
    validator.username.should == @ticket_granting_ticket.username
  end
  
  it "should have extra attributes from the ticket granting ticket" do
    validator = Cassify::ServiceValidate.new("http://localhost:3000", @service_ticket.ticket).validate
    validator.extra_attributes.should == @ticket_granting_ticket.extra_attributes
  end
end
