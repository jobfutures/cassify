# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cassify/version"

Gem::Specification.new do |s|
  s.name        = "cassify"
  s.version     = Cassify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Job Futures"]
  s.email       = ["developers@jobfutures.com.au"]
  s.homepage    = ""
  s.summary     = %q{CAS authentication methods}
  s.description = %q{CAS without the ugly bits}

  s.rubyforge_project = "cassify"

  s.add_dependency("builder")
  s.add_dependency("activesupport")
  
  s.add_dependency "devise"
  s.add_dependency "rails", ">= 3.0.0"
  s.add_dependency "addressable"
  
  s.add_development_dependency "rspec", ">= 2.5.0"
  s.add_development_dependency "rspec-rails", ">= 2.5.0"
  s.add_development_dependency "capybara", ">= 0.4.0"
  s.add_development_dependency "sqlite3"
  
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
end
