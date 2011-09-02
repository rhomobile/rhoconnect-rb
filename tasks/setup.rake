namespace :rhoconnect do
  desc "setup initializer"
  task :setup do
    sh "cp #{File.join(File.dirname(__FILE__),'../','templates','rhoconnect.rb')} #{::Rails.root.to_s}/config/initializers/"
  end
end