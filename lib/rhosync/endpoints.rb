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
    
    def self.query(resource_name, partition)
      result, records = {}, []
      puts "received: #{resource_name.inspect}, #{partition.inspect}"
      begin
        klass = Kernel.const_get(resource_name)
        records = klass.send(:rhosync_query, partition)
      rescue NameError
        raise "Missing Rhosync::Resource #{resource_name}"
      rescue NoMethodError
        raise "Method `rhosync_query` is not defined on Rhosync::Resource #{resource_name}"
      end
      puts "records: #{records.inspect}"
      records.each do |record|
        result[record.id.to_s] = record.attributes.dup
      end
      puts "result: #{result.inspect}"
      puts "json: #{result.to_json}"
      [200, {'Content-Type' => 'application/json'}, [result.to_json]]
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
  
  module Rhosync  
    class Query
      def self.call(env)
        req = Rack::Request.new(env)
        puts "params: #{req.params.inspect}"
        Rhosync::EndpointHelpers.query(req.params["resource"], req.params["partition"])
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
        app.post "/rhosync/query" do
          Rhosync::EndpointHelpers.query(params[:resource], params[:partition])
        end
        
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