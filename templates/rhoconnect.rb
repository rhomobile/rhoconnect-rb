# Configure your Rhoconnect-rb plugin
Rhoconnectrb.configure do |config|

  # `uri` defines the location of your rhoconnect instance.
  config.uri    = "http://localhost:9292"

  # `token` is the rhoconnect token for your rhoconnect instance.
  # You can find the value for this token in your rhoconnect web console.
  config.token  = "my-rhoconnect-token"

  # `app_endpoint` is the url of this rails app.  It is used to notify the
  # rhoconnect instance where this rails app is located on startup.
  # If you do not define `app_endpoint`, you will have to set this variable
  # manually using the rhoconnect web console.
  config.app_endpoint = "http://localhost:3000"


  # Use `authenticate` to define your authentication logic.
  # credentials are passed in as a hash:
  # {
  #   :login => 'someusername',
  #   :password => 'somepassword'
  # }
  config.authenticate = lambda { |credentials|
    return true
  }
end