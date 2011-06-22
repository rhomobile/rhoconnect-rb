module Rhosync
  class Configuration
    attr_accessor :uri, :token, :authenticate, :sync_time_as_int, :app_endpoint, :http_proxy
    
    def initialize
      @sync_time_as_int = true
    end
      
  end

  class << self
    attr_accessor :configuration
  end

  # Configure RhoSync in an initializer:
  # like config/initializers/rhosync.rb
  #
  # Setup the RhoSync uri and api token.  
  # Use rhosync:get_token to get the token value.
  #
  #   config.uri   = "http://myrhosync.com"
  #   config.token = "secrettoken"
  #   config.authenticate = lambda { |credentials| 
  #     User.authenticate(credentials) 
  #   }
  #
  # @example
  #   Rhosync.configure do |config|
  #     config.uri   = "http://myrhosync.com"
  #     config.token = "secrettoken"
  #   end
  def self.configure
    self.configuration = Configuration.new
    yield(configuration)
    # make a call to rhoconnect instance to set app url
    endpoint_url = self.configuration.app_endpoint || ENV['APP_ENDPOINT']
    uri          = self.configuration.uri || ENV['URI']
    if uri
      uri = URI.parse(uri)
      token    = uri.user
      uri.user = nil
      uri      = uri.to_s
    end
    token  ||=  ENV['token'] || self.configuration.token
    Rhosync::Client.set_app_endpoint(uri + "/api/source/save_adapter?attributes[adapter_url]=#{endpoint_url}&api_token=#{token}") if endpoint_url && uri && token
  end
end

Rhosync.configure { }