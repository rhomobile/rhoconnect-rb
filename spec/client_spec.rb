require File.join(File.dirname(__FILE__), 'spec_helper')

describe Rhosync::Client do
  
  context "on initialize" do
    it "should initialize with RHOSYNC_URL environment var" do
      ENV['RHOSYNC_URL'] = "http://token@test.rhosync.com"
      c = Rhosync::Client.new
      c.token.should == 'token'
      c.uri.should == 'http://test.rhosync.com'
      ENV.delete('RHOSYNC_URL')
    end
  
    it "should initialize with :uri parameter" do
      c = Rhosync::Client.new(:uri => "http://token@test.rhosync.com")
      c.token.should == 'token'
      c.uri.should == 'http://test.rhosync.com'
    end
  
    it "should initialize with :token parameter" do
      c = Rhosync::Client.new(:uri => "http://test.rhosync.com", :token => "token")
      c.token.should == 'token'
      c.uri.should == 'http://test.rhosync.com'
    end
    
    it "should initialize with configure block" do
      Rhosync.configure do |config|
        config.uri = "http://test.rhosync.com"
        config.token = "token"
      end
      begin
        c = Rhosync::Client.new
        c.token.should == 'token'
        c.uri.should == 'http://test.rhosync.com'
      ensure
        Rhosync.configure do |config|
          config.uri = nil
          config.token = nil   
        end
      end
    end
  
    it "should raise ArgumentError if uri is missing" do
      lambda { Rhosync::Client.new }.should raise_error(ArgumentError, "Please provide a :uri or set RHOSYNC_URL")
    end
  
    it "should raise ArugmentError if token is missing" do
      lambda { 
        Rhosync::Client.new(:uri => "http://test.rhosync.com") 
      }.should raise_error(ArgumentError, "Please provide a :token or set it in uri")
    end
  end
  
  context "on create update destroy" do
    before(:each) do
      @client = Rhosync::Client.new(:uri => "http://token@test.rhosync.com")
    end
    
    it "should create an object" do
      stub_request(:post, "http://test.rhosync.com/api/push_objects").with(
        :headers => {"Content-Type" => "application/json"}
      ).to_return(:status => 200, :body => "done")
      resp = @client.create("Person", "user1", 
        {
          'id' => 1,
          'name' => 'user1'
        }
      )
      resp.body.should == "done"
      resp.code.should == 200
    end
    
    it "should update an object" do
      stub_request(:post, "http://test.rhosync.com/api/push_objects").with(
        :headers => {"Content-Type" => "application/json"}
      ).to_return(:status => 200, :body => "done")
      resp = @client.update("Person", "user1", 
        {
          'id' => 1,
          'name' => 'user1'
        }
      )
      resp.body.should == "done"
      resp.code.should == 200
    end
    
    it "should destroy an object" do
      stub_request(:post, "http://test.rhosync.com/api/push_deletes").with(
        :headers => {"Content-Type" => "application/json"}
      ).to_return(:status => 200, :body => "done")
      resp = @client.destroy("Person", "user1", 
        {
          'id' => 1,
          'name' => 'user1'
        }
      )
      resp.body.should == "done"
      resp.code.should == 200
    end
  end
  
  context "on set callbacks" do
    before(:each) do
      @client = Rhosync::Client.new(:uri => "http://token@test.rhosync.com")
    end
    
    it "should set auth callback" do
      stub_request(:post, "http://test.rhosync.com/api/set_auth_callback").with(
        :headers => {"Content-Type" => "application/json"}
      ).to_return(:status => 200, :body => "done")
      resp = @client.set_auth_callback("http://example.com/callback")
      resp.body.should == "done"
      resp.code.should == 200
    end
    
    it "should set query callback" do
      stub_request(:post, "http://test.rhosync.com/api/set_query_callback").with(
        :headers => {"Content-Type" => "application/json"}
      ).to_return(:status => 200, :body => "done")
      resp = @client.set_query_callback("Person", "http://example.com/callback")
      resp.body.should == "done"
      resp.code.should == 200
    end
  end
end