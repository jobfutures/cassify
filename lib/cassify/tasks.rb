require 'cassify'

module Cassify
  class Tasks
    class << self
      def migrate
        database_config = File.join('config', 'database.yml')

        unless File.exists? database_config
          raise "config/database.yml could not be found" 
        end
        
        begin
          cas_database_config = YAML.load_file(database_config)
          ActiveRecord::Base.establish_connection(cas_database_config.fetch(ENV['CAS_ENV']))
          ActiveRecord::Base.logger = Cassify::Logger.log
          ActiveRecord::Migration.verbose = true
          ActiveRecord::Migrator.migrate("db/migrate")
        rescue Exception => e
          STDERR.puts e
          STDERR.puts "do you have a cas database group in your database.yml and specified CAS_ENV?"
        end
      end

      def install_views(view_path)
        source      = File.join(File.dirname(__FILE__), 'views')
        destination = File.join(Dir.pwd, view_path)
        STDERR.puts "\ncopying views from: #{source} to: #{destination}.....\n\n"
        FileUtils.cp_r source, destination
        STDERR.puts "done\n"
      end
    end
  end
end
