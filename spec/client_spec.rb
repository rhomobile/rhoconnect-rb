require File.join(File.dirname(__FILE__), 'spec_helper')

describe Rhoconnect::Client do
  
  context "on initialize" do
    it "should initialize with Rhoconnect_URL environment var" do
      ENV['RHOCONNECT_URL'] = "http://token@test.rhoconnect.com"
      c = Rhoconnect::Client.new
      c.token.should == 'token'
      c.uri.should == 'http://test.rhoconnect.com'
      ENV.delete('Rhoconnect_URL')
    end
  
    it "should initialize with :uri parameter" do
      c = Rhoconnect::Client.new(:uri => "http://token@test.rhoconnect.com")
      c.token.should == 'token'
      c.uri.should == 'http://test.rhoconnect.com'
    end
  
    it "should initialize with :token parameter" do
      c = Rhoconnect::Client.new(:uri => "http://test.rhoconnect.com", :token => "token")
      c.token.should == 'token'
      c.uri.should == 'http://test.rhoconnect.com'
    end
    
    it "should initialize with configure block" do
      Rhoconnect.configure do |config|
        config.uri = "http://test.rhoconnect.com"
        config.token = "token"
      end
      begin
        c = Rhoconnect::Client.new
        c.token.should == 'token'
        c.uri.should == 'http://test.rhoconnect.com'
      ensure
        Rhoconnect.configure do |config|
          config.uri = nil
          config.token = nil   
        end
      end
    end
  
    it "should raise ArgumentError if uri is missing" do
      ENV['RHOCONNECT_URL'] = nil
      lambda { Rhoconnect::Client.new }.should raise_error(ArgumentError, "Please provide a :uri or set RHOCONNECT_URL")
    end
  
    it "should raise ArugmentError if token is missing" do
      lambda { 
        Rhoconnect::Client.new(:uri => "http://test.rhoconnect.com")
      }.should raise_error(ArgumentError, "Please provide a :token or set it in uri")
    end
  end
  
  context "on create update destroy" do
    before(:each) do
      @client = Rhoconnect::Client.new(:uri => "http://token@test.rhoconnect.com")
    end
    
    it "should create an object" do
      stub_request(:post, "http://test.rhoconnect.com/app/v1/Person/push_objects").with(
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
      stub_request(:post, "http://test.rhoconnect.com/app/v1/Person/push_objects").with(
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
      stub_request(:post, "http://test.rhoconnect.com/app/v1/Person/push_deletes").with(
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
      @client = Rhoconnect::Client.new(:uri => "http://token@test.rhoconnect.com")
    end
    
    it "should set auth callback" do
      stub_request(:post, "http://test.rhoconnect.com/api/set_auth_callback").with(
        :headers => {"Content-Type" => "application/json"}
      ).to_return(:status => 200, :body => "done")
      resp = @client.set_auth_callback("http://example.com/callback")
      resp.body.should == "done"
      resp.code.should == 200
    end
    
    it "should set query callback" do
      stub_request(:post, "http://test.rhoconnect.com/api/set_query_callback").with(
        :headers => {"Content-Type" => "application/json"}
      ).to_return(:status => 200, :body => "done")
      resp = @client.set_query_callback("Person", "http://example.com/callback")
      resp.body.should == "done"
      resp.code.should == 200
    end
  end
end