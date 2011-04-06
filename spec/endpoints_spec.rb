require File.join(File.dirname(__FILE__), 'spec_helper')

describe Rhosync::EndpointHelpers do
  class AuthTest; end
  
  def setup_auth_test(success)
    AuthTest.stub!(:do_auth).and_return(success)
    AuthTest.should_receive(:do_auth).with(@creds)
    
    Rhosync.configure do |config|
      config.uri = "http://test.rhosync.com"
      config.token = "token"
      config.authenticate = lambda {|credentials|
        AuthTest.do_auth(credentials)
      }  
    end
  end
  
  context "on Rails authenticate" do
    before(:each) do
      @creds = {'user' => 'john', 'pass' => 'secret'}
      strio = mock("StringIO")
      strio.stub!(:read).and_return(JSON.generate(@creds))
      @env = mock("env")
      @env.stub!(:body).and_return(strio)
      @env.stub!(:content_type).and_return('application/json')
      Rack::Request.stub!(:new).and_return(@env)
    end
    
    it "should call configured authenticate block" do
      setup_auth_test(true)
      Rhosync::Authenticate.call(@env).should == [
        200, {'Content-Type' => 'text/plain'}, [""]
      ]
    end
    
    it "should call configured authenticate block with 401" do
      setup_auth_test(false)
      Rhosync::Authenticate.call(@env).should == [
        401, {'Content-Type' => 'text/plain'}, [""]
      ]
    end
    
    it "should return true if no authenticate block exists" do
      Rhosync.configure do |config|
        config.uri = "http://test.rhosync.com"
        config.token = "token" 
      end
      Rhosync.configuration.authenticate.should be_nil
      Rhosync::Authenticate.call(@env).should == [
        200, {'Content-Type' => 'text/plain'}, [""]
      ]
    end
  end
  
  context "on Sinatra authenticate" do
    before(:each) do
      @creds = {'user' => 'john', 'pass' => 'secret'}
      strio = mock("StringIO")
      strio.stub!(:read).and_return(JSON.generate(@creds))      
      req = mock("request")
      req.stub!(:body).and_return(strio)
      req.stub!(:env).and_return('CONTENT_TYPE' => 'application/json')
      Sinatra::RhosyncEndpoints.stub!(:request).and_return(req)
      Sinatra::RhosyncEndpoints.stub!(:params).and_return(:partition => "testuser", :resource => "Product")
      Rhosync::EndpointHelpers.stub!(:query)
      @app = mock("app")
      @app.stub!(:post).and_yield
    end
    
    it "should call configured authenticate block" do
      setup_auth_test(true)
      Sinatra::RhosyncEndpoints.registered(@app).should == [
        200, {'Content-Type' => 'text/plain'}, [""]
      ]
    end
    
    it "should call configured authenticate block with 401" do
      setup_auth_test(false)
      Sinatra::RhosyncEndpoints.registered(@app).should == [
        401, {'Content-Type' => 'text/plain'}, [""]
      ]
    end
        
    it "should return true if no authenticate block exists" do
      Rhosync.configure do |config|
        config.uri = "http://test.rhosync.com"
        config.token = "token" 
      end
      Sinatra::RhosyncEndpoints.registered(@app).should == [
        200, {'Content-Type' => 'text/plain'}, [""]
      ]
    end
  end
end