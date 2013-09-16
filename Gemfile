source "http://rubygems.org"

gemspec
gem 'rake'
gem 'rails', '>= 3.0'
gem 'activeresource', '>= 3.0'

group :test do
  gem 'rspec', '~>2.5.0', :require => 'spec'
  gem 'simplecov', :platforms => [:ruby_19,:jruby]
  gem 'webmock'
end

platforms :jruby do
  gem 'jruby-openssl'
end
