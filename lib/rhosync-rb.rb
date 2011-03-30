require 'json'
require 'rest_client'
require 'rhosync/version'
require 'rhosync/configuration'
require 'rhosync/client'
require 'rhosync/resource'
require 'rhosync/authenticate'

# Detect if we're running inside of rails
class Engine < Rails::Engine; end if defined? Rails

if defined? Sinatra
  module Sinatra
    module RhosyncAuthenticate
      def self.registered(app)
        puts "registered: #{app.inspect}"
        app.get '/rhosync/authenticate' do
          'hello sinatra'
        end
      end
    end
    register RhosyncAuthenticate
  end
end
