module Rhosync
  module Resource
    
    def self.included(model)
      model.extend(ClassMethods)
      model.extend(HelperMethods)
      
      model.send(:include, InstanceMethods)
      model.send(:include, Callbacks)
    end
    
    
    module ClassMethods
      def partition(p)
        @partition = p
      end
      
      def get_partition
        @partition.is_a?(Proc) ? @partition.call : @partition
      end
    end
    
    module InstanceMethods
      
      def rhosync_create
        payload = is_datamapper? ? self.to_json : self.serializable_hash.to_json
        post("/api/create_objects", payload)
      end
      
      def rhosync_destroy
        "destroyed me #{self.inspect}"
      end
      
      def rhosync_update
        "updated me #{self.inspect}"
      end
      
    end
    
    module Callbacks  
        
      def self.included(model)
        model.class_eval do
          install_callbacks
        end
      end
      
      def foo
      end
    end
  
    module HelperMethods
      
      def install_callbacks
        if is_datamapper?
          # test for dm-serializer
          if not is_defined?(DataMapper::Serialize)
            raise "Rhosync::Resource requires dm-serializer to work with DataMapper. Install with `gem install dm-serializer` and add to your application."
          end
          after :create, :rhosync_create
          after :destroy, :rhosync_destroy
          after :update, :rhosync_update
        elsif is_activerecord?
          after_create :rhosync_create
          after_destroy :rhosync_destroy
          after_update :rhosync_update
        else
          raise "Rhosync::Resource only supports ActiveRecord or DataMapper at this time."  
        end
      end
      
      private
      
      def is_defined?(const)
        defined?(const)
      end
      
      def is_datamapper?
        self.included_modules.include?(DataMapper::Resource) rescue false
      end
      
      def is_activerecord?
        self.superclass == ActiveRecord::Base rescue false
      end
    end
  end
end
