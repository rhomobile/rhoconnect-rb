module Rhoconnectrb
  module API
    class Resource
      
      def self.method_missing method_name, *args
        action = method_name.to_s.split("_")
        method = "#{action[1]}_#{action[2]}"
        url = "/#{args[0]}/#{method}"
        self.send(action[0],url,args[1])  
      end
      
      private 
      
      def self.post(url,data)
        resp = resource[url].post data.to_json, self.content
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
         RestClient::Resource.new(uri + "/app/v1")
      end
      
    end
  end
end