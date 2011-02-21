require 'spec_helper'

describe Cassify::Cas do
  it "generate login ticket" do
    Cassify::Cas.generate_login_ticket("http://rubyforge.org").ticket.should match /^LT-/
  end
end
