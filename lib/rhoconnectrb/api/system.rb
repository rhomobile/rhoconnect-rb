module Rhoconnectrb
  module API
    class System
      
      def self.klass
        self.to_s.underscore.split('/')[2]
      end
      
      def self.method_missing method_name, *args
        action = method_name.to_s.split("_")
        Base.send(action[0],"/#{klass}/#{action[1]}",args[0])
      end
      
    end
  end
end