$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec'
require 'rhosync-rb'
require 'webmock/rspec'

include WebMock::API

# define ActiveRecord and DM here for testing
module ActiveRecord
  class Base
    
    def attributes
      {
        "name" => "John", 
        "created_at" => Time.parse("Wed Mar 09 02:11:06 UTC 2011"),
        "updated_at" => Time.parse("Wed Mar 09 02:11:06 UTC 2011"), 
        "id" => 1
      }
    end
    
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
    
    def attributes
      {
        :created_at => DateTime.parse("Wed Mar 09 02:11:06 UTC 2011"), 
        :updated_at => DateTime.parse("Wed Mar 09 02:11:06 UTC 2011"),
        :name => "John", 
        :id => 1
      }
    end
    
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