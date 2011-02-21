require 'active_record'
require 'logger'
require 'fileutils'

require 'cassify/cas'
require 'cassify/model'
require 'cassify/utils'
require 'cassify/logger'

module Cassify
  # Your code goes here...
end

Logger.new(ENV['CAS_ENV'] || "test")
