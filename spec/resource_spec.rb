require File.join(File.dirname(__FILE__), 'spec_helper')

describe Rhoconnectrb::Resource do
  
  context "on set partition" do
    it "should set resource partition to :app" do
      class TestModel1 < ActiveRecord::Base
        include Rhoconnectrb::Resource
      
        def partition 
          :app
        end
      end
    
      TestModel1.new.get_partition.should == :app
    end
  
    it "should set resource partition with lambda" do
      class TestModel2 < ActiveRecord::Base
        include Rhoconnectrb::Resource
      
        def partition 
          lambda{ 'helloworld' }
        end
      end
    
      TestModel2.new.get_partition.should == 'helloworld'
    end
  end
  
  context "on initialize" do
    it "should raise exception if DataMapper or ActiveRecord::Base are missing" do
      lambda { class TestModel3
                 include Rhoconnectrb::Resource
               end
      }.should raise_error("Rhoconnectrb::Resource only supports ActiveRecord or DataMapper at this time.")
    end
    
    it "should register callbacks for ActiveRecord::Base" do
      class TestModel4 < ActiveRecord::Base
        include Rhoconnectrb::Resource
      end
    
      TestModel4.create_callback.should == :rhoconnect_create
      TestModel4.destroy_callback.should == :rhoconnect_destroy
      TestModel4.update_callback.should == :rhoconnect_update
    end
  
    it "should register callbacks for DataMapper::Resource" do
      class TestModel5
        include DataMapper::Resource
        include Rhoconnectrb::Resource
      end
        
      TestModel5.rhoconnect_callbacks[:create].should == :rhoconnect_create
      TestModel5.rhoconnect_callbacks[:destroy].should == :rhoconnect_destroy
      TestModel5.rhoconnect_callbacks[:update].should == :rhoconnect_update
    end
    
    it "should raise exception if dm-serializer is missing" do
      class TestModel6
        include DataMapper::Resource
        include Rhoconnectrb::Resource
      end
      TestModel6.stub!(:is_defined?).and_return(false)
      lambda { 
        TestModel6.install_callbacks
      }.should raise_error("Rhoconnectrb::Resource requires dm-serializer to work with DataMapper. Install with `gem install dm-serializer` and add to your application.")
    end
  end
  
  context "on create update delete" do
    
    it "should call create update delete hook" do
      class TestModel7 < ActiveRecord::Base
        include Rhoconnectrb::Resource
        def partition 
          :app
        end
      end
      client = mock('Rhoconnectrb::Client')
      client.stub!(:send)
      Rhoconnectrb::Client.stub!(:new).and_return(client)
      [:create, :update, :destroy].each do |action|
        client.should_receive(:send).with(
          action, "TestModel7", :app, {"name"=>"John", "created_at"=>"1299636666", "updated_at"=>"1299636666", "id"=>1}
        )
        TestModel7.new.send("rhoconnect_#{action}".to_sym)
      end
    end
    
    it "should warn on RestClient::Exception" do
      class TestModel8 < ActiveRecord::Base
        include Rhoconnectrb::Resource
        def partition 
          :app
        end
      end
      client = mock('Rhoconnectrb::Client')
      exception = RestClient::Exception.new(
        RestClient::Response.create("error connecting to server", nil, nil), 500
      )
      exception.message = "Internal Server Error"
      client.stub!(:send).and_return { raise exception }
      Rhoconnectrb::Client.stub!(:new).and_return(client)
      tm = TestModel8.new
      tm.should_receive(:warn).with(
        "TestModel8: rhoconnect_create returned error: Internal Server Error - error connecting to server"
      )
      tm.rhoconnect_create
    end
    
    it "should warn on Exception" do
      class TestModel8 < ActiveRecord::Base
        include Rhoconnectrb::Resource
        def partition 
          :app
        end
      end
      client = mock('Rhoconnectrb::Client')
      client.stub!(:send).and_return { raise Exception.new("error connecting to server") }
      Rhoconnectrb::Client.stub!(:new).and_return(client)
      tm = TestModel8.new
      tm.should_receive(:warn).with("TestModel8: rhoconnect_create returned unexpected error: error connecting to server")
      tm.rhoconnect_create
    end
  end
end