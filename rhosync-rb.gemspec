# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rhosync-rb"
  s.version     = IO.read(File.join(File.dirname(__FILE__), 'VERSION'))
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rhomobile"]
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.email       = ["support@rhomobile.com"]
  s.homepage    = %q{http://rhomobile.com}
  s.summary     = %q{RhoSync rails plugin}
  s.description = %q{RhoSync rails plugin}

  s.rubyforge_project = nil  
  s.add_dependency('rest-client', '~>1.6.1')
  s.add_dependency('json', '~>1.4.6')
  
  #s.add_development_dependency('rspec', '~>2.4.0')
  #s.add_development_dependency('rcov', '~>0.9.8')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  
end
