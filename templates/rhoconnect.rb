Rhoconnectrb.configure do |config|
  # Rhconnect.configure is used to set the url and token to your rhoconnect instance.
  # If you are connecting to a rhconnect instance provisioned from Heroku the uri and token are already defined.  Just leave commented out.
  
  #config.uri          = "http://myrhoconnect-server.com"
  #config.token        = "secrettoken"
  
  # app_endpoint is the url of this rails app.  It is used to tell the rhoconnect instance where this rails app is located.  A rest call is sent on the startup of this rails app
  # which will set the rhoconnect instance to point to this rails app.
  # If you do not define app_endpoint, you will have to set this variable manually using the rhoconnect console.
  
  #config.app_endpoint = "http://myapp.heroku.com"
  
  # authenticate allows you to define your own custom authentication.  credentials is a hash = {:login => login, :password => password}.  Leave commented out or return true if you do not wish to authenticate yourself.
  
  #config.authenticate = lambda { |credentials|
  #        return true
  #}
end