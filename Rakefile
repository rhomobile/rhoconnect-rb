require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-b", "-c", "-fd"]
  t.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rspec_opts = ["-b", "-c", "-fd"]
  t.rcov_opts =  ['--exclude', 'spec/*,gems/*']
end

desc "Build the gem using rhosync-rb.gemspec"
task :gem do
  bundle_exec("gem build rhosync-rb.gemspec")
end

task :default => :spec

def bundle_exec(cmd)
  system "bundle exec #{cmd}"
end