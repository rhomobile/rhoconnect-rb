require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-b", "-c", "-fd"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec