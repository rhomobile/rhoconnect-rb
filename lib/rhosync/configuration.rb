module Rhosync
  class Configuration
    attr_accessor :uri, :token, :authenticate, :sync_time_as_int
    
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
  end
end

Rhosync.configure { }