module Cassify::Errors
  class Base < Exception
    attr_reader :code, :message

    def initialize(code, message)
      @code    = code
      @message = message
      Cassify.logger.error code, message
    end

    def to_s
      message
    end
  end
end