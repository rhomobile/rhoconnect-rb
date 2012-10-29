module Rhoconnectrb
  module Resource
    
    def self.included(model)
      model.extend(ClassMethods)
      model.extend(HelperMethods)
      
      model.send(:include, InstanceMethods)
      model.send(:include, Callbacks)
    end
    
    
    module ClassMethods
      def rhoconnect_receive_create(partition, attributes)
        instance = self.send(:new)
        instance.send(:rhoconnect_apply_attributes, partition, attributes)
        instance.skip_rhoconnect_callbacks = true
        instance.save
        instance.id #=> return object id
      end
      
      def rhoconnect_receive_update(partition, attributes)
        object_id = attributes.delete('id')
        instance = self.send(is_datamapper? ? :get : :find, object_id)
        instance.send(:rhoconnect_apply_attributes, partition, attributes)
        instance.skip_rhoconnect_callbacks = true
        instance.save
        object_id
      end
      
      def rhoconnect_receive_delete(partition, attributes)
        object_id = attributes['id']
        instance = self.send(is_datamapper? ? :get : :find, object_id)      
        instance.skip_rhoconnect_callbacks = true
        instance.destroy
        object_id
      end
    end
    
    module InstanceMethods
      attr_accessor :skip_rhoconnect_callbacks

      def get_partition
        @partition = partition
        @partition.is_a?(Proc) ? @partition.call : @partition
      end
      
      def rhoconnect_create
        call_client_method(:create)
      end
      
      def rhoconnect_destroy
        call_client_method(:destroy)
      end
      
      def rhoconnect_update
        call_client_method(:update)
      end
      
      def rhoconnect_query(partition, attributes = nil)
        #return all objects for this partition 
      end
      
      # By default we ignore partition
      # TODO: Document - this is user-facing function
      def rhoconnect_apply_attributes(partition, attributes)
        self.attributes = attributes
      end
      
      # Return Rhoconnect-friendly attributes list
      def normalized_attributes
        attribs = self.attributes.dup
        attribs.each do |key,value|
          attribs[key] = Time.parse(value.to_s).to_i.to_s if value.is_a?(Time) or value.is_a?(DateTime)
        end if Rhoconnectrb.configuration.sync_time_as_int
        attribs
      end
      
      private
        
      def call_client_method(action)
        unless self.skip_rhoconnect_callbacks
          attribs = self.normalized_attributes
          begin
            Rhoconnectrb::Client.new.send(action, self.class.to_s, self.get_partition, attribs)
          rescue RestClient::Exception => re
            warn "#{self.class.to_s}: rhoconnect_#{action} returned error: #{re.message} - #{re.http_body}"
          rescue Exception => e
            warn "#{self.class.to_s}: rhoconnect_#{action} returned unexpected error: #{e.message}"
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
            raise "Rhoconnectrb::Resource requires dm-serializer to work with DataMapper. Install with `gem install dm-serializer` and add to your application."
          end
          after :create, :rhoconnect_create
          after :destroy, :rhoconnect_destroy
          after :update, :rhoconnect_update
        elsif is_activerecord?
          after_create :rhoconnect_create
          after_destroy :rhoconnect_destroy
          after_update :rhoconnect_update
        else
          raise "Rhoconnectrb::Resource only supports ActiveRecord or DataMapper at this time."
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
