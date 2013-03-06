require 'json'
require 'rest_client'
require 'rhoconnectrb/version'
require 'rhoconnectrb/configuration'
require 'rhoconnectrb/client'
require 'rhoconnectrb/resource'
require 'rhoconnectrb/endpoints'
require 'rhoconnectrb/railtie' if defined?(Rails)
require 'rhoconnectrb/api/base'
require 'rhoconnectrb/api/clients'
require 'rhoconnectrb/api/read_state'
require 'rhoconnectrb/api/resource'
require 'rhoconnectrb/api/sources'
require 'rhoconnectrb/api/store'
require 'rhoconnectrb/api/system'
require 'rhoconnectrb/api/users'

unless defined?(Rails)
  class String
    def underscore
      self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end
  end
end