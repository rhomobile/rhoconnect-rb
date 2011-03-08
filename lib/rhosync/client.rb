require 'rest_client'
require 'uri'
require 'rhosync/version'

module Rhosync
  class Client
    attr_accessor :uri, :token
    
    def initialize(params = {})
      uri = ENV['RHOSYNC_URL'] || params[:uri]
      raise ArgumentError.new("Please provide a :uri or set RHOSYNC_URL") unless uri
      uri = URI.parse(uri)
      
      @token = uri.user || params[:token]
      uri.user = nil; @uri = uri.to_s      
      raise ArgumentError.new("Please provide a :token or set it in uri") unless @token
      
      RestClient.proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
    end
    
    def create(source_name, partition, obj = {})
      raise ArgumentError.new("Missing object id for #{obj.inspect}") unless obj['id']
      raise ArgumentError.new("Missing source_name.") unless source_name or source_name.empty?
      raise ArgumentError.new("Missing partition for #{model}.") unless partition or partition.empty?
      
      process(:post, "/api/push_objects", 
        {
          :source_id => source_name,
          :user_id => partition,
          :objects => { obj['id'] => obj }
        }
      )
    end
    
    def set_auth_callback(callback)
      process(:post, "/api/set_auth_callback")
    end
    
    def set_query_callback
    end

    protected 
    
    def resource(path)
      RestClient::Resource.new(@uri)[path]
    end
    
    def process(method, path, payload = nil)
      headers = api_headers
      unless method == :get
        payload  = payload.merge!(:api_token => @token).to_json
        headers = api_headers.merge(:content_type => 'application/json')
      end
      args     = [method, payload, headers].compact
      response = resource(path).send(*args)
      response
    end
    
    def get(path)    # :nodoc:
      process(:get, path)
    end

    def post(path, payload="")    # :nodoc:
      process(:post, path, payload)
    end

    def put(path, payload)    # :nodoc:
      process(:put, path, payload)
    end

    def delete(path)    # :nodoc:
      process(:delete, path)
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