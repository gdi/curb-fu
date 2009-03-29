require File.dirname(__FILE__) + '/../../spec_helper'
require 'htmlentities'

describe CurbFu::Response::Base do
  describe "successes" do
    it "should create a success (200) response" do
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => "")
      r = CurbFu::Response::Base.create(mock_curb)
      r.should be_a_kind_of(CurbFu::Response::Base)
      r.should be_a_kind_of(CurbFu::Response::Success)
      r.should be_a_kind_of(CurbFu::Response::OK)
      r.should_not be_a_kind_of(CurbFu::Response::Created)
    end
    it "should create a success (201) response" do
      mock_curb = mock(Object, :response_code => 201, :body_str => 'OK', :header_str => "")
      r = CurbFu::Response::Base.create(mock_curb)
      r.should be_a_kind_of(CurbFu::Response::Base)
      r.should be_a_kind_of(CurbFu::Response::Success)
      r.should be_a_kind_of(CurbFu::Response::Created)
    end
  end
  it "should create a 400 response" do
    mock_curb = mock(Object, :response_code => 404, :body_str => 'OK', :header_str => "", :timeout= => nil)
    r = CurbFu::Response::Base.create(mock_curb)
    r.should be_a_kind_of(CurbFu::Response::Base)
    r.should be_a_kind_of(CurbFu::Response::ClientError)
  end
  it "should create a 500 response" do
    mock_curb = mock(Object, :response_code => 503, :body_str => 'OK', :header_str => "", :timeout= => nil)
    r = CurbFu::Response::Base.create(mock_curb)
    r.should be_a_kind_of(CurbFu::Response::Base)
    r.should be_a_kind_of(CurbFu::Response::ServerError)
  end
  
  describe "parse_headers" do
    before(:each) do
    end
    
    describe "test data" do
      it "should parse all of Google's headers" do
        headers = "HTTP/1.1 200 OK\r\nCache-Control: private, max-age=0\r\nDate: Tue, 17 Mar 2009 17:34:08 GMT\r\nExpires: -1\r\nContent-Type: text/html; charset=ISO-8859-1\r\nSet-Cookie: PREF=ID=16472704f58eb437:TM=1237311248:LM=1237311248:S=KrWlq33vvam8d_De; expires=Thu, 17-Mar-2011 17:34:08 GMT; path=/; domain=.google.com\r\nServer: gws\r\nTransfer-Encoding: chunked\r\n\r\n"
        mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
        @cf = CurbFu::Response::Base.create(mock_curb)
        
        @cf.headers['Cache-Control'].should == 'private, max-age=0'
        @cf.headers['Date'].should == 'Tue, 17 Mar 2009 17:34:08 GMT'
        @cf.headers['Expires'].should == '-1'
        @cf.headers['Content-Type'].should == 'text/html; charset=ISO-8859-1'
        @cf.headers['Set-Cookie'].should == 'PREF=ID=16472704f58eb437:TM=1237311248:LM=1237311248:S=KrWlq33vvam8d_De; expires=Thu, 17-Mar-2011 17:34:08 GMT; path=/; domain=.google.com'
        @cf.headers['Server'].should == 'gws'
        @cf.headers['Transfer-Encoding'].should == 'chunked'
        @cf.headers.keys.length.should == 7
      end
      
      it "should parse our json headers from the data_store" do
        headers = "HTTP/1.1 200 OK\r\nServer: nginx/0.6.34\r\nDate: Tue, 17 Mar 2009 05:40:32 GMT\r\nContent-Type: text/json\r\nConnection: close\r\nContent-Length: 18\r\n\r\n"
        mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
        @cf = CurbFu::Response::Base.create(mock_curb)
        
        @cf.headers['Server'].should == 'nginx/0.6.34'
        @cf.headers['Date'].should == 'Tue, 17 Mar 2009 05:40:32 GMT'
        @cf.headers['Content-Type'].should == 'text/json'
        @cf.headers['Connection'].should == 'close'
        @cf.headers['Content-Length'].should == '18'
        @cf.headers.keys.length.should == 5
      end
    end
  end
end