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

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "activerecord", ">= 3.0.0"
  s.add_development_dependency "activesupport", ">= 3.0.0"
  s.add_development_dependency "pg"
  s.add_development_dependency "devise"
  s.add_development_dependency "builder"

  s.add_runtime_dependency "activerecord", ">= 3.0.0"
  s.add_runtime_dependency "activesupport", ">= 3.0.0"
  s.add_runtime_dependency "pg"
  s.add_runtime_dependency "devise"
  s.add_runtime_dependency "builder"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
