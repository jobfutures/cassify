require 'spec_helper'

describe Cassify::Settings do
  it "should be able set maximum_unused_login_ticket_lifetime and retrieve it" do
    Cassify::Settings.configure do |config|
      config.maximum_unused_login_ticket_lifetime = 1.day
    end
    Cassify::Settings.maximum_unused_login_ticket_lifetime.should_not be_nil
  end
end
