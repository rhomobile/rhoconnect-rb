require 'json'

module Rhosync
  class EndpointHelpers
    def self.authenticate(content_type, body)
      code, params = 200, nil
      if content_type and content_type.match(/^application\/json/) and body and body.length > 2
        params = JSON.parse(body)
      end
      if params and Rhosync.configuration.authenticate
        code = 401 unless Rhosync.configuration.authenticate.call(params)
      end  
      [code, {'Content-Type' => 'text/plain'}, [""]]
    end
  end
end

# Detect if we're running inside of rails
if defined? Rails
  class Engine < Rails::Engine; end
  
  module Rhosync  
    class Authenticate
      def self.call(env)
        req = Rack::Request.new(env)
        Rhosync::EndpointHelpers.authenticate(req.content_type, req.body.read)
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
    class RhosyncEndpoints
      def self.registered(app)
        app.post '/rhosync/authenticate' do
          Rhosync::EndpointHelpers.authenticate(
            request.env['CONTENT_TYPE'], request.body.read
          )
        end
      end
    end
    register RhosyncEndpoints
  end
end