require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__),"../lib","rhoconnect-rb.rb")
require File.join(File.dirname(__FILE__),"../lib/rhoconnectrb/api","base.rb")
require File.join(File.dirname(__FILE__),"../lib/rhoconnectrb/api","resource.rb")
require File.join(File.dirname(__FILE__),"../lib/rhoconnectrb/api","users.rb")
require File.join(File.dirname(__FILE__),"../lib/rhoconnectrb/api","store.rb")
require File.join(File.dirname(__FILE__),"../lib/rhoconnectrb/api","system.rb")
require File.join(File.dirname(__FILE__),"../lib/rhoconnectrb/api","sources.rb")
require File.join(File.dirname(__FILE__),"../lib/rhoconnectrb/api","read_state.rb")
require File.join(File.dirname(__FILE__),"../lib/rhoconnectrb/api","clients.rb")

describe Rhoconnectrb::API do
  include WebMock::API
  
  before(:each) do
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/users").to_return(:body => "testuser")
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/users/testuser/clients").to_return(:body=>'clientslist')
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/users/testuser/sources/product/docnames").to_return(:body=>'docnames')
    stub_request(:post, "http://mytoken:@testurl.com/rc/v1/read_state/users/testuser/sources/product").to_return(:body=>'readstate sources')
    stub_request(:post, "http://mytoken:@testurl.com/rc/v1/users/testuser").to_return(:body => "testuser")
    stub_request(:put, "http://mytoken:@testurl.com/rc/v1/users/testuser").to_return(:body => 'testuser')
    stub_request(:delete, "http://mytoken:@testurl.com/rc/v1/users/testuser").to_return(:body => 'testuser')
    stub_request(:post, "http://mytoken:@testurl.com/rc/v1/system/login").to_return(:body=>'login')
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/system/appserver").to_return(:body=>'appserver')
    stub_request(:post, "http://mytoken:@testurl.com/rc/v1/store/testdoc").to_return(:body=>'post store')
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/store/testdoc").to_return(:body=>'get store')
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/sources/type/app").to_return(:body=>'app sources')
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/sources/Product").to_return(:body=>'Product')
    stub_request(:put, "http://mytoken:@testurl.com/rc/v1/sources/Product").to_return(:body=>'put Product')
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/clients/client_id/sources/source_id/docnames").to_return(:body=>'client sources docname')
    stub_request(:get, "http://mytoken:@testurl.com/rc/v1/clients/client_id/sources/source_id/docs/docname").to_return(:body=>'client sources docs')
    stub_request(:post, "http://mytoken:@testurl.com/rc/v1/clients/client_id/sources/source_id/docs/docname").to_return(:body=>'post client sources docs')
    stub_request(:post, "http://mytoken:@testurl.com/app/v1/Product/push_objects").to_return(:body=>'push product object')
    ENV['RHOCONNECT_URL'] = 'http://mytoken@testurl.com'
  end
  
  context "on base" do
    it "should get token and url from env" do
      Rhoconnectrb::API::Base.token.should == 'mytoken'
      Rhoconnectrb::API::Base.resource.to_s.should == 'http://mytoken@testurl.com/rc/v1'
    end
  end
  context "on users" do
    it "should format get request url" do
      resp = Rhoconnectrb::API::Users.get
      resp.body.should == 'testuser'
    end
    
    it "should format post request" do
      data = {:id=>'1'}
      resp = Rhoconnectrb::API::Users.post('testuser',data)
      resp.body.should == 'testuser'
    end
    
    it "should format put request" do
      data = {:id=>'1'}
      resp = Rhoconnectrb::API::Users.put('testuser',data)
      resp.body.should == 'testuser'
    end
    
    it "should format delete request" do
      resp = Rhoconnectrb::API::Users.delete('testuser')
      resp.body.should == 'testuser'
    end
    
    it "should format user clients" do
      resp = Rhoconnectrb::API::Users.get_clients('testuser')
      resp.body.should == 'clientslist'
    end
    
    it "should format user sources docname" do
      resp = Rhoconnectrb::API::Users.get_sources_docnames(['testuser','product'])
      resp.body.should == 'docnames'
    end
  end
  context "read state" do
    it "should return readsate for user" do
      data = {:refresh_time => 20}
      resp = Rhoconnectrb::API::ReadState.post_users_sources(['testuser','product'],data)
      resp.body.should == 'readstate sources'
    end
  end
  
  context "on system" do
    it "should login to system" do
      data = {:login=>'test',:password=>'password'}
      resp = Rhoconnectrb::API::System.post_login(data)
      resp.body.should == 'login'
    end
    
    it "should get appserver" do
      resp = Rhoconnectrb::API::System.get_appserver
      resp.body.should == 'appserver'
    end
  end
  
  context "on store" do
    it "should store doc" do
      data = {:data=>{:mydata=>'testdata'},:append=>'false'}
      resp = Rhoconnectrb::API::Store.post('testdoc',data)
      resp.body.should == 'post store'
    end
    
    it "should get store doc" do
      resp = Rhoconnectrb::API::Store.get('testdoc')
      resp.body.should == 'get store'
    end
  end
  
  context "on source" do
    it "should get partition type" do
      resp = Rhoconnectrb::API::Sources.get_type('app')
      resp.body.should == 'app sources'
    end
    
    it "should get source" do
      resp = Rhoconnectrb::API::Sources.get('Product')
      resp.body.should == 'Product'
    end
    
    it "should update source" do
      data = {:user_name =>"testuser",:data=>{:poll_interval=>20}}
      resp = Rhoconnectrb::API::Sources.put('Product',data)
      resp.body.should == 'put Product'
    end
  end
  
  context "on client" do
    it "should get client sources docnames" do
      resp = Rhoconnectrb::API::Clients.get_sources_docnames(['client_id','source_id'])
      resp.body.should == 'client sources docname'
    end
    
    it "should get clients docs" do
      resp = Rhoconnectrb::API::Clients.get_sources_docs(['client_id','source_id','docname'])
      resp.body.should == 'client sources docs'
    end
    
    it "should post clients sources doc" do
      data = {:data=>{:mydata=>'testdata'},:append=>'false'}
      resp = Rhoconnectrb::API::Clients.post_sources_docs(['client_id','source_id','docname'],data)
      resp.body.should == 'post client sources docs'
    end
  end
  
  context "on resources" do
    it "should push source objects" do
      data = {:data=>{:mydata=>'testdata'},:append=>'false'}
      resp = Rhoconnectrb::API::Resource.post_push_objects('Product',data)
      resp.body.should == 'push product object'
    end
    
  end
  
end