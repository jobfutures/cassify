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

  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.rdoc"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  
  s.add_dependency("devise")
  s.add_dependency("builder")
  s.add_dependency("active_support")
end
