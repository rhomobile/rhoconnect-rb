require 'rubygems'
require 'bundler'
Bundler.setup

desc "Run all specs"
task :spec do
  bundle_exec("spec -cfs spec")
end

desc "Build the gem using rhosync-rb.gemspec"
task :gem do
  bundle_exec("gem build rhosync-rb.gemspec")
end

task :default => :spec

def bundle_exec(cmd)
  system "bundle exec #{cmd}"
end