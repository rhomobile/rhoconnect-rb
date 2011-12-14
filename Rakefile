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

desc "Run all specs with rcov"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts =  ['--exclude', 'spec/*,gems/*']
  t.rspec_opts = ["-b", "-c", "-fd"]
end

task :default => :spec