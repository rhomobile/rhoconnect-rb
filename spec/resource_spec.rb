require File.join(File.dirname(__FILE__), 'spec_helper')

describe Rhosync::Resource do
  
  it "should set resource partition to :app" do
    class TestModel1
      include Rhosync::Resource
      
      partition :app
    end
    
    TestModel1.get_partition.should == :app
  end
  
  it "should set resource partition with lambda" do
    class TestModel2
      include Rhosync::Resource
      
      partition lambda{ 'helloworld' }
    end
    
    TestModel2.get_partition.should == 'helloworld'
  end
  
  context "on create" do
    it "should register after_create callback" do
      class TestModel3
        include Rhosync::Resource

        partition :app
      end
      
      
    end
    
  end
end