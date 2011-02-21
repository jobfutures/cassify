require 'active_record'
require 'fileutils'
require 'logger'

namespace :db do
  desc "run CAS migrations"
  task :migrate do |t|
    ActiveRecord::Base.configurations = YAML.load_file(File.join(ENV['DATABASE_CONFIG'], "database.yml"))
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations.fetch(ENV['CAS_ENV']))

    logfile = "#{Dir.pwd}/log/cas.log"
    ActiveRecord::Base.logger = Logger.new(File.open(logfile, 'w'))
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end
