require 'rest_client'
require 'uri'

module Rhoconnectrb
  module API
    
    class Base
      def self.post(url,data)
        resp = resource[url].post data.to_json
        resp.body
      end
      
      def self.get(url,params=nil)
        if params
          params = {:params=>params} 
          resp = resource[url].get(params)
        else
          resp = resource[url].get self.content
        end
        resp.body
      end
      
      def self.put(url,data)
        resp = resource[url].put data.to_json
        resp.body
      end
      
      def self.delete(url,nothing=nil)
        resp = resource[url].delete
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
        RestClient::Resource.new(uri + "/rc/v1",:headers=>self.content)
      end
      
    end
  end
end