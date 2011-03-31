require 'json'
# Detect if we're running inside of rails
if defined? Rails
  class Engine < Rails::Engine; end
  
  module Rhosync  
    class Authenticate
      def self.call(env)
        req = Rack::Request.new(env)
        puts req.GET.inspect
        body = req.body.read
        puts JSON.parse(body).inspect if req.content_type == 'application/json' and body and body.length > 2
        [200, {'Content-Type' => 'text/plain'}, ["hello from rack"]]
      end
    end
  end
end


# Detect if we're running inside of sinatra
if defined? Sinatra
  # Defines Sinatra routes
  # This is automatically registered if you are using
  # the 'classic' style sinatra application.  To use in a 
  # classic application:
  #
  # require 'rubygems'
  # require 'sinatra'
  # require 'rhosync-rb'
  #
  # get '/' do
  #  'hello world'
  # end
  #
  # For modular sinatra applications, you will need to register
  # the module inside your class. To use in a modular application:
  #
  # require 'sinatra/base'
  # require 'rhosync-rb'
  # 
  # class Myapp < Sinatra::Base
  #   register Sinatra::RhosyncAuthenticate
  #   get '/' do
  #     'hello world'
  #   end
  # end
  module Sinatra
    module RhosyncEndpoints
      def self.registered(app)
        app.get '/rhosync/authenticate' do
          "hello sinatra: #{params.inspect}"
        end
      end
    end
    register RhosyncEndpoints
  end
end