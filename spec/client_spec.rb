require File.join(File.dirname(__FILE__), 'spec_helper')

require 'rhosync/client'

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
  
    it "should raise ArgumentError if uri is missing" do
      lambda { Rhosync::Client.new }.should raise_error(ArgumentError, "Please provide a :uri or set RHOSYNC_URL")
    end
  
    it "should rais ArugmentError if token is missing" do
      lambda { 
        Rhosync::Client.new(:uri => "http://test.rhosync.com") 
      }.should raise_error(ArgumentError, "Please provide a :token or set it in uri")
    end
  end
  
  context "on create" do
    before(:each) do
      @client = Rhosync::Client.new(:uri => "http://token@test.rhosync.com")
    end
    
    it "should create an object" do
      stub_request(:post, "http://test.rhosync.com/api/push_objects"
      ).with(:headers => {"Content-Type" => "application/json"}).to_return(:status => 200, :body => "done")
      resp = @client.create("Person", "user1", 
        {
          'id' => 1,
          'name' => 'user1'
        }
      )
      resp.body.should == "done"
      resp.code.should == 200
    end
  end
end