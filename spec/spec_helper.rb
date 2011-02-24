$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['CAS_ENV'] = 'test'

require 'active_record'
require 'fileutils'
require 'logger'
require 'rspec'
require 'rspec/autorun'
require 'cassify'

ActiveRecord::Base.configurations = YAML.load_file(File.join("config", "database.yml"))
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations.fetch(ENV['CAS_ENV']))
ActiveRecord::Base.logger = STDERR
