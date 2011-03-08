require File.join(File.dirname(__FILE__), 'spec_helper')

describe Rhosync::Resource do
  
  context "on set partition" do
    it "should set resource partition to :app" do
      class TestModel1 < ActiveRecord::Base
        include Rhosync::Resource
      
        partition :app
      end
    
      TestModel1.get_partition.should == :app
    end
  
    it "should set resource partition with lambda" do
      class TestModel2 < ActiveRecord::Base
        include Rhosync::Resource
      
        partition lambda{ 'helloworld' }
      end
    
      TestModel2.get_partition.should == 'helloworld'
    end
  end
  
  context "on initialize" do
    it "should raise exception if DataMapper or ActiveRecord::Base are missing" do
      lambda { class TestModel3
                 include Rhosync::Resource
               end
      }.should raise_error("Rhosync::Resource only supports ActiveRecord or DataMapper at this time.")
    end
    
    it "should register callbacks for ActiveRecord::Base" do
      class TestModel4 < ActiveRecord::Base
        include Rhosync::Resource
      end
    
      TestModel4.create_callback.should == :rhosync_create
      TestModel4.destroy_callback.should == :rhosync_destroy
      TestModel4.update_callback.should == :rhosync_update
    end
  
    it "should register callbacks for DataMapper::Resource" do
      class TestModel5
        include DataMapper::Resource
        include Rhosync::Resource
      end
        
      TestModel5.rhosync_callbacks[:create].should == :rhosync_create
      TestModel5.rhosync_callbacks[:destroy].should == :rhosync_destroy
      TestModel5.rhosync_callbacks[:update].should == :rhosync_update
    end
    
    it "should raise exception if dm-serializer is missing" do
      class TestModel6
        include DataMapper::Resource
        include Rhosync::Resource
      end
      TestModel6.stub!(:is_defined?).and_return(false)
      lambda { 
        TestModel6.install_callbacks
      }.should raise_error("Rhosync::Resource requires dm-serializer to work with DataMapper. Install with `gem install dm-serializer` and add to your application.")
    end
  end
  
  context "on create" do
    
  end
end