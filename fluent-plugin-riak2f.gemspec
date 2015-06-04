# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-riak2f"
  gem.description = "Riak 2.x plugin for Fluent event collector"
  gem.homepage    = "https://github.com/kyanagimoto/fluent-plugin-riak2f"
  gem.summary     = gem.description
  gem.version     = File.read("VERSION").strip
  gem.license     = 'Apache-2.0'
  gem.authors     = ["koichi yanagimoto"]
  gem.email       = "kyanagi1107@gmail.com"
  gem.has_rdoc    = false
  #gem.platform    = Gem::Platform::RUBY
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "fluentd", "~> 0.10"
  gem.add_dependency "riak-client", "~> 2.1.0"
  gem.add_dependency "uuidtools", "~> 2.1.3"
  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency "simplecov", ">= 0.5.4"
  gem.add_development_dependency "rr", ">= 1.0.0"
end
