module Rhoconnectrb
  module API
    class Sources

      def self.klass
        self.to_s.underscore.split('/')[2]
      end  

      def self.method_missing method_name, *args
        action = method_name.to_s.split("_")
        #handle CRUD operations
        if action.size == 1
          if action[0] =~ /put|delete/
            resp = Base.send(action[0],"/#{klass}/#{args[0]}",args[1])
          else
            url = args.size > 0 ? "/#{klass}/#{args[0]}" : klass
            resp = Base.send(action[0],url,args[1])
          end
        end
  
        if action.size > 1
          verb = action.delete_at(0)
          #if posting without parameters just post with data else contruct url
          if verb == 'post' and !args[1]
            resp = Base.send(verb,"/#{klass}/#{action[0]}",args[0])
          elsif action[0] =~ /type/
            #special case currently for this one call, refactor after rhoconnect is refactored.  check for array or string passed
            partition_type =  args[0].is_a?(Array) ? args[0].first.to_sym : args[0].to_sym
            resp = Base.send(verb,"/#{klass}/#{action[0]}/#{partition_type}")
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