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
      attr_accessor :skip_rhosync_callbacks
      
      def rhosync_create
        call_client_method(:create)
      end
      
      def rhosync_destroy
        call_client_method(:destroy)
      end
      
      def rhosync_update
        call_client_method(:update)
      end
      
      def rhosync_query(partition)
        #return all objects for this partition 
      end
      
      def normalized_attributes
        attribs = self.attributes.dup
        attribs.each do |key,value|
          attribs[key] = Time.parse(value.to_s).to_i.to_s if value.is_a?(Time) or value.is_a?(DateTime)
        end if Rhosync.configuration.sync_time_as_int
        attribs    
      end
      
      private
        
      def call_client_method(action)
        unless self.skip_rhosync_callbacks
          attribs = self.normalized_attributes
          begin
            Rhosync::Client.new.send(action, self.class.to_s, self.class.get_partition, attribs)
          rescue RestClient::Exception => re
            warn "#{self.class.to_s}: rhosync_#{action} returned error: #{re.message} - #{re.http_body}"
          rescue Exception => e
            warn "#{self.class.to_s}: rhosync_#{action} returned unexpected error: #{e.message}"
          end
        end
      end
      
    end
    
    module Callbacks  
        
      def self.included(model)
        model.class_eval do
          install_callbacks
        end
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
      
      def is_defined?(const) # :nodoc:
        defined?(const)
      end
      
      def is_datamapper? # :nodoc:
        self.included_modules.include?(DataMapper::Resource) rescue false
      end
      
      def is_activerecord? # :nodoc:
        self.superclass == ActiveRecord::Base rescue false
      end
    end
  end
end
