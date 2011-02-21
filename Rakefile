$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'cassify/tasks'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
desc 'Run Cassify unit tests.'
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ['--colour', '--format nested']
  t.pattern = 'spec/**/*_spec.rb'
end

namespace :cassify do
  desc 'run CAS migrations'
  task 'migrate' do
    Cassify::Tasks.migrate
  end

  desc 'install cas views'
  task 'sinatra' do
    Cassify::Tasks.install_views("views")
  end
end
