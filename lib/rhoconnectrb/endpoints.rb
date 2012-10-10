require 'json'

module Rhoconnectrb
  class EndpointHelpers
    def self.authenticate(content_type, body)
      code, params = 200, parse_params(content_type, body)
      if Rhoconnectrb.configuration.authenticate
        code = 401 unless Rhoconnectrb.configuration.authenticate.call(params)
      end
      [code, {'Content-Type' => 'text/plain'}, [code == 200 ? params['login'] : ""]]
    end
    
    def self.query(content_type, body)
      params = parse_params(content_type, body)
      action, c_type, result, records = :rhoconnect_query, 'application/json', {}, []
      # Call resource rhoconnect_query class method
      code, error = get_rhoconnect_resource(params['resource'], action) do |klass|
        records = klass.send(action, params['partition'], params['attributes'])
      end
      if code == 200
        # Serialize records into hash of hashes
        records.each do |record|
          result[record.id.to_s] = record.normalized_attributes
        end
        result = result.to_json
      else
        result = error
        c_type = 'text/plain'
        # Log warning if something broke
        warn error
      end    
      [code, {'Content-Type' => c_type}, [result]]
    end
    
    def self.on_cud(action, content_type, body)
      params = parse_params(content_type, body)
      object_id = ""
      code, error = get_rhoconnect_resource(params['resource'], action) do |klass|
        object_id = klass.send("rhoconnect_receive_#{action}".to_sym,
          params['partition'], params['attributes'])
        object_id = object_id.to_s if object_id
      end
      [code, {'Content-Type' => "text/plain"}, [error || object_id]]
    end
    
    def self.create(content_type, body)
      self.on_cud(:create, content_type, body)
    end
    
    def self.update(content_type, body)
      self.on_cud(:update, content_type, body)  
    end
    
    def self.delete(content_type, body)
      self.on_cud(:delete, content_type, body)  
    end
    
    private
    
    def self.get_rhoconnect_resource(resource_name, action)
      code, error = 200, nil
      begin
        klass = Kernel.const_get(resource_name)
        yield klass
      rescue NoMethodError => ne
        error = "error on method `#{action}` for #{resource_name}: #{ne.message}"
        code = 404
      rescue NameError
        error = "Missing Rhoconnectrb::Resource #{resource_name}"
        code = 404
      # TODO: catch HaltException and Exception here, built-in source adapter will handle them
      rescue Exception => e
        error = e.message
        code = 500
      end
      [code, error]
    end
    
    def self.parse_params(content_type, params)
      if content_type and content_type.match(/^application\/json/) and params and params.length > 2
        JSON.parse(params)
      else 
        {}
      end
    end
  end
end

# Detect if we're running inside of rails
if defined? Rails
  #if Rails::VERSION::STRING.to_i >= 3
    class Engine < Rails::Engine; end
  #end
  
  module Rhoconnectrb
    class BaseEndpoint
      def self.call(env)
        req = Rack::Request.new(env)
        Rhoconnectrb::EndpointHelpers.send(self.to_s.downcase.split("::")[1].to_sym, req.content_type, req.body.read)
      end
    end
    
    class Authenticate < BaseEndpoint; end
    
    class Query < BaseEndpoint;  end
    
    class Create < BaseEndpoint; end
    
    class Update < BaseEndpoint; end
    
    class Delete < BaseEndpoint; end
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
  # require 'rhoconnect-rb'
  #
  # get '/' do
  #  'hello world'
  # end
  #
  # For modular sinatra applications, you will need to register
  # the module inside your class. To use in a modular application:
  #
  # require 'sinatra/base'
  # require 'rhoconnect-rb'
  # 
  # class Myapp < Sinatra::Base
  #   register Sinatra::RhoconnectrbEndpoints
  #   get '/' do
  #     'hello world'
  #   end
  # end
  module Sinatra
    module RhoconnectHelpers
      def call_helper(method,*args)
        code, c_type, body = Rhoconnectrb::EndpointHelpers.send(method,*args)
        content_type c_type['Content-Type']
        status code
        body[0]
      end
    end
    
    module RhoconnectEndpoints
      def self.registered(app)
        # install our endpoint helpers
        app.send(:include, RhoconnectHelpers)

        [:authenticate,:query,:create,:update,:delete].each do |endpoint|
          app.post "/rhoconnect/#{endpoint}" do
            call_helper(endpoint, request.env['CONTENT_TYPE'], request.body.read)
          end
        end
      end
    end
    register RhoconnectEndpoints
  end
end