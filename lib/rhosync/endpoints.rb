require 'json'

module Rhosync
  class EndpointHelpers
    def self.authenticate(content_type, body)
      code, params = 200, parse_params(content_type, body)
      if params and Rhosync.configuration.authenticate
        code = 401 unless Rhosync.configuration.authenticate.call(params)
      end  
      [code, {'Content-Type' => 'text/plain'}, [""]]
    end
    
    def self.query(resource_name, partition)
      action, content_type, result, records = :rhosync_query, 'application/json', {}, []
      # Call resource rhosync_query class method
      code, warning = get_resource(resource_name, action) do |klass|
        records = klass.send(action, partition)
      end
      if code == 200
        # Serialize records into hash of hashes
        records.each do |record|
          result[record.id.to_s] = record.normalized_attributes
        end
        result = result.to_json
      else
        result = warning
        content_type = 'text/plain'
        # Log warning if something broke
        warn warning
      end    
      [code, {'Content-Type' => content_type}, [result]]
    end
    
    def self.create(content_type, body)
      params = parse_params(content_type, body)
      action, object_id = :create, ""
      code, warning = get_resource(resource_name, action) do |klass|
        instance = klass.send(:new, attributes)
        instance.skip_rhosync_callbacks = true
        instance.save
        object_id = instance.id.to_s
      end
      [code, {'Content-Type' => "text/plain"}, [warning || object_id]]
    end
    
    private
    
    def self.get_resource(resource_name, action)
      code, warning = 200, nil
      begin
        klass = Kernel.const_get(resource_name)
        yield klass
      rescue NoMethodError
        warning = "Method `#{action}` is not defined on Rhosync::Resource #{resource_name}"
        code = 500
      rescue NameError
        warning = "Missing Rhosync::Resource #{resource_name}"
        code = 404
      end
      [code, warning]
    end
    
    def self.parse_params(content_type, params)
      if content_type and content_type.match(/^application\/json/) and params and params.length > 2
        JSON.parse(params)
      else 
        nil
      end
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
    
    class Query
      def self.call(env)
        req = Rack::Request.new(env)
        Rhosync::EndpointHelpers.query(req.params["resource"], req.params["partition"])
      end
    end
    
    class Create
      def self.call(env)
        req = Rack::Request.new(env)
        Rhosync::EndpointHelpers.create(req.content_type, req.body.read)
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
        app.post '/rhosync/authenticate' do
          call_helper(:authenticate, request.env['CONTENT_TYPE'], request.body.read)
        end
        
        app.post "/rhosync/query" do
          call_helper(:query, params[:resource], params[:partition])
        end
      end
      
      def self.call_helper(method,*args)
        code, c_type, body = Rhosync::EndpointHelpers.send(method,*args)
        content_type c_type['Content-Type']
        status code
        body[0]
      end
      
    end
    register RhosyncEndpoints
  end
end