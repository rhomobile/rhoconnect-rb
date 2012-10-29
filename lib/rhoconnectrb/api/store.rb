module Rhoconnectrb
  module API
    class Store
      
      def self.klass
        self.to_s.underscore.split('/')[2]
      end
      
      def self.method_missing method_name, *args
        action = method_name.to_s.split("_")
        if action.size == 1
          resp = Base.send(action[0],"/#{klass}/#{args[0]}",args[1])
        else
        
          verb = action.delete_at(0)
          #if posting without parameters just post with data else contruct url
          if verb == 'post' and !args[1]
            resp = Base.send(verb,"/#{klass}/#{action[0]}",args[0])
          else
            if args[0].class.to_s == 'String'
              url = "/#{klass}/#{args[0]}/#{action[0]}"
            else
              url = klass
              args[0].each_with_index do |value,index|
                url += "/#{value}"
                url += "/#{action[index]}" if action[index]
              end
            end
            resp = Base.send(verb,url,args[1])  
          end
        end
        resp
      end
      
    end
  end
end