module Cassify::Errors
  class Base < Exception
    attr_reader :code, :message

    def initialize(code, message)
      @code    = code
      @message = message
      CasLog.error code, message
    end

    def to_s
      message
    end
  end
end