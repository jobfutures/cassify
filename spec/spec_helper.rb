$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV['DATABASE_CONFIG'] = 'spec'
ENV['CAS_ENV'] = 'test'

require 'active_record'
require 'fileutils'
require 'logger'
require 'rspec'
require 'rspec/autorun'
require 'cassify'

$LOG = Logger.new(STDOUT)
ActiveRecord::Base.configurations = YAML.load_file(File.join(ENV['DATABASE_CONFIG'], "database.yml"))
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations.fetch(ENV['CAS_ENV']))

FileUtils.mkdir_p "#{Dir.pwd}/log"
logfile = "#{Dir.pwd}/log/database.log"
ActiveRecord::Base.logger = Logger.new(File.open(logfile, 'w'))
