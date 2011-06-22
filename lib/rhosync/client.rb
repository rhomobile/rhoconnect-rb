require 'uri'

module Rhosync
  class Client
    attr_accessor :uri, :token

    def self.set_app_endpoint(url)
      RestClient::Request.execute(:method => :post, :url => url, :timeout => 2000)
    end
    
    # allow configuration, uri or environment variable initialization
    def initialize(params = {})
      uri = params[:uri] || Rhosync.configuration.uri || ENV['RHOSYNC_URL']
      raise ArgumentError.new("Please provide a :uri or set RHOSYNC_URL") unless uri
      uri = URI.parse(uri)
      
      @token = params[:token] || Rhosync.configuration.token || uri.user
      uri.user = nil; @uri = uri.to_s
      raise ArgumentError.new("Please provide a :token or set it in uri") unless @token
      
      RestClient.proxy = ENV['HTTP_PROXY'] || ENV['http_proxy'] || Rhosync.configuration.http_proxy
    end
    
    def create(source_name, partition, obj = {})
      send_objects(:push_objects, source_name, partition, obj)
    end
    
    def destroy(source_name, partition, obj = {})
      send_objects(:push_deletes, source_name, partition, obj)
    end
    
    # update, create, it doesn't matter :)
    alias :update :create
    
    def set_auth_callback(callback)
      process(:post, "/api/set_auth_callback", { :callback => callback })
    end
    
    def set_query_callback(source_name, callback)
      process(:post, "/api/set_query_callback", 
        { 
          :source_id => source_name,
          :callback => callback 
        }
      )
    end

    protected 
    
    def validate_args(source_name, partition, obj = {}) # :nodoc:
      raise ArgumentError.new("Missing object id for #{obj.inspect}") unless obj['id']
      raise ArgumentError.new("Missing source_name.") unless source_name or source_name.empty?
      raise ArgumentError.new("Missing partition for #{model}.") unless partition or partition.empty?
    end
    
    def send_objects(action, source_name, partition, obj = {}) # :nodoc:
      validate_args(source_name, partition, obj)
      
      process(:post, "/api/source/#{action}",
        {
          :source_id => source_name,
          :user_id => partition,
          :objects => action == :push_deletes ? [obj['id'].to_s] : { obj['id'] => obj }
        }
      )
    end
    
    def resource(path) # :nodoc:
      RestClient::Resource.new(@uri)[path]
    end
    
    def process(method, path, payload = nil) # :nodoc:
      headers = api_headers
      unless method == :get
        payload  = payload.merge!(:api_token => @token).to_json
        headers = api_headers.merge(:content_type => 'application/json')
      end
      args     = [method, payload, headers].compact
      response = resource(path).send(*args)
      response
    end
    
    def api_headers   # :nodoc:
      {
        'User-Agent'           => Rhosync::VERSION,
        'X-Ruby-Version'       => RUBY_VERSION,
        'X-Ruby-Platform'      => RUBY_PLATFORM
      }
    end
        
  end
end