module Rhosync
  module Resource
    
    def self.included(model)
      model.extend(ClassMethods)
    end
    
    
    module ClassMethods
      def partition(p)
        @partition = p
      end
      
      def get_partition
        @partition.is_a?(Proc) ? @partition.call : @partition
      end
    end
  end
end
