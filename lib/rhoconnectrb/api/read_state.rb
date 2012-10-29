#READSTATE is special class that does not have resource id so logic changes to account for nil id inherint to every request
module Rhoconnectrb
  module API
    class ReadState
      
      def self.klass
        self.to_s.underscore.split('/')[2]
      end
      
      def self.method_missing method_name, *args
        action = method_name.to_s.split("_")
      
        if action.size > 1
          verb = action.delete_at(0)
          
          if args[0].class.to_s == 'String'
            url = "/#{klass}/#{action[0]}/#{args[0]}"
          else
            url = klass
            args[0].each_with_index do |value,index|
              url += "/#{action[index]}" if action[index]
              url += "/#{value}"
            end
          end
          Base.send(verb,url,args[1])
        end
      end
    end
  end
end