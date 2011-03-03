$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rhosync-rb'

# define ActiveRecord and DM here for testing
module ActiveRecord
  class Base
    
    class << self
      attr_accessor :create_callback,:destroy_callback,:update_callback
      
      def after_create(callback)
        @create_callback = callback
      end
    
      def after_destroy(callback)
        @destroy_callback = callback
      end
    
      def after_update(callback)
        @update_callback = callback
      end
    end
  end
end

module DataMapper
  module Resource
    
    def self.included(model)
      model.extend(ClassMethods)
    end
    
    module ClassMethods
      attr_accessor :rhosync_callbacks
      
      def after(action, callback)
        @rhosync_callbacks ||= {}
        @rhosync_callbacks[action] = callback
      end
    end
  end
  
  module Serialize; end
end