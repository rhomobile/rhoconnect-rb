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
  
  context "on create update delete" do
    
    it "should call create update delete hook" do
      class TestModel7 < ActiveRecord::Base
        include Rhosync::Resource
        partition :app
      end
      client = mock('Rhosync::Client')
      client.stub!(:send)
      Rhosync::Client.stub!(:new).and_return(client)
      [:create, :update, :destroy].each do |action|
        client.should_receive(:send).with(
          action, "TestModel7", :app, {"name"=>"John", "created_at"=>1299636666, "updated_at"=>1299636666, "id"=>1}
        )
        TestModel7.new.send("rhosync_#{action}".to_sym)
      end
    end
    
    it "should warn on RestClient::Exception" do
      class TestModel8 < ActiveRecord::Base
        include Rhosync::Resource
        partition :app
      end
      client = mock('Rhosync::Client')
      exception = RestClient::Exception.new(
        RestClient::Response.create("error connecting to server", nil, nil), 500
      )
      exception.message = "Internal Server Error"
      client.stub!(:send).and_return { raise exception }
      Rhosync::Client.stub!(:new).and_return(client)
      tm = TestModel8.new
      tm.should_receive(:warn).with(
        "TestModel8: rhosync_create returned error: Internal Server Error - error connecting to server"
      )
      tm.rhosync_create
    end
    
    it "should warn on Exception" do
      class TestModel8 < ActiveRecord::Base
        include Rhosync::Resource
        partition :app
      end
      client = mock('Rhosync::Client')
      client.stub!(:send).and_return { raise Exception.new("error connecting to server") }
      Rhosync::Client.stub!(:new).and_return(client)
      tm = TestModel8.new
      tm.should_receive(:warn).with("TestModel8: rhosync_create returned unexpected error: error connecting to server")
      tm.rhosync_create
    end
  end
end