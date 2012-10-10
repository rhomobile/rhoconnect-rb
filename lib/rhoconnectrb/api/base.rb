require 'rest_client'
require 'uri'

module Rhoconnectrb
  module API
    
    class Base
      def self.post(url,data)
        resp = resource[url].post data.to_json, self.content
        resp.body
      end
      
      def self.get(url,nothing=nil)
        resp = resource[url].get self.content
        resp.body
      end
      
      def self.put(url,data)
        resp = resource[url].put data.to_json, self.content
        resp.body
      end
      
      def self.delete(url,nothing=nil)
        resp = resource[url].delete self.content
        resp.body
      end
      
      def self.token
        url = Rhoconnectrb.configuration.uri || ENV['RHOCONNECT_URL']
        uri = URI.parse(url)
        Rhoconnectrb.configuration.token || uri.user
      end
      
      def self.content
        {'X-RhoConnect-API-TOKEN'=> self.token, :content_type => :json, :accept => :json}
      end
      
      def self.resource
        uri = Rhoconnectrb.configuration.uri || ENV['RHOCONNECT_URL']
        RestClient::Resource.new(uri + "/rc/v1")
      end
      
    end
  end
end