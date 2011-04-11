require File.dirname(__FILE__) + '/../../spec_helper'
require 'htmlentities'

describe CurbFu::Response::Base do
  describe "from_rack_response" do
    it "should create a new CurbFu::Response object out of a rack response (array)" do
      rack = mock(Object, :status => 200, :headers => { 'Expires' => '05-12-2034' }, :body => "This will never go out of style")
      response = CurbFu::Response::Base.from_rack_response(rack)
      response.should be_a_kind_of(CurbFu::Response::OK)
      response.body.should == "This will never go out of style"
      response.headers.should include('Expires' => '05-12-2034')
    end
  end
  
  describe "from_curb_response" do
    it "should create a new CurbFu::Response object out of a curb response object" do
      curb = mock(Curl::Easy, :body_str => "Miscellaneous Facts About Curb", :header_str => "HTTP/1.1 200 OK\r\nCache-Control: private, max-age=0\r\nDate: Tue, 17 Mar 2009 17:34:08 GMT\r\nExpires: -1\r\n", :response_code => 200 )
      response = CurbFu::Response::Base.from_curb_response(curb)
      response.should be_a_kind_of(CurbFu::Response::OK)
      response.body.should == "Miscellaneous Facts About Curb"
      response.headers.should include("Expires" => '-1', "Cache-Control" => 'private, max-age=0')
      response.status.should == 200
    end
  end
  
  describe "successes" do
    it "should create a success (200) response" do
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => "")
      r = CurbFu::Response::Base.from_curb_response(mock_curb)
      r.should be_a_kind_of(CurbFu::Response::Base)
      r.should be_a_kind_of(CurbFu::Response::Success)
      r.should be_a_kind_of(CurbFu::Response::OK)
      r.should_not be_a_kind_of(CurbFu::Response::Created)
    end
    it "should create a success (201) response" do
      mock_curb = mock(Object, :response_code => 201, :body_str => 'OK', :header_str => "")
      r = CurbFu::Response::Base.from_curb_response(mock_curb)
      r.should be_a_kind_of(CurbFu::Response::Base)
      r.should be_a_kind_of(CurbFu::Response::Success)
      r.should be_a_kind_of(CurbFu::Response::Created)
    end
  end
  it "should create a 400 response" do
    mock_curb = mock(Object, :response_code => 404, :body_str => 'OK', :header_str => "", :timeout= => nil)
    r = CurbFu::Response::Base.from_curb_response(mock_curb)
    r.should be_a_kind_of(CurbFu::Response::Base)
    r.should be_a_kind_of(CurbFu::Response::ClientError)
  end
  it "should create a 500 response" do
    mock_curb = mock(Object, :response_code => 503, :body_str => 'OK', :header_str => "", :timeout= => nil)
    r = CurbFu::Response::Base.from_curb_response(mock_curb)
    r.should be_a_kind_of(CurbFu::Response::Base)
    r.should be_a_kind_of(CurbFu::Response::ServerError)
  end
  
  describe "response modules" do
    describe ".to_i" do
      it "should return the status code represented by the module" do
        CurbFu::Response::OK.to_i.should == 200
        CurbFu::Response::NotFound.to_i.should == 404
      end
    end
    describe "#message" do
      it "should return a string indicating the english translation of the status code" do
        r = CurbFu::Response::Base.new(200, {}, "text")
        r.message.should == "OK"
        r = CurbFu::Response::Base.new(404, {}, "text")
        r.message.should == "Not Found"
        r = CurbFu::Response::Base.new(302, {}, "text")
        r.message.should == "Found"
        r = CurbFu::Response::Base.new(505, {}, "text")
        r.message.should == "Version Not Supported"
      end
    end
  end
  
  describe "parse_headers" do
    before(:each) do
    end
    
    describe "test data" do
      it "should parse all of Google's headers" do
        headers = "HTTP/1.1 200 OK\r\nCache-Control: private, max-age=0\r\nDate: Tue, 17 Mar 2009 17:34:08 GMT\r\nExpires: -1\r\nContent-Type: text/html; charset=ISO-8859-1\r\nSet-Cookie: PREF=ID=16472704f58eb437:TM=1237311248:LM=1237311248:S=KrWlq33vvam8d_De; expires=Thu, 17-Mar-2011 17:34:08 GMT; path=/; domain=.google.com\r\nServer: gws\r\nTransfer-Encoding: chunked\r\n\r\n"
        mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
        @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
        
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
        @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
        
        @cf.headers['Server'].should == 'nginx/0.6.34'
        @cf.headers['Date'].should == 'Tue, 17 Mar 2009 05:40:32 GMT'
        @cf.headers['Content-Type'].should == 'text/json'
        @cf.headers['Connection'].should == 'close'
        @cf.headers['Content-Length'].should == '18'
        @cf.headers.keys.length.should == 5
      end

      it "should use an array to store values for headers fields with multiple instances" do
        headers = "HTTP/1.1 200 OK\r\nSet-Cookie: first cookie value\r\nSet-Cookie: second cookie value\r\n\r\n"
        mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
        @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
        @cf.headers['Set-Cookie'].should == ["first cookie value", "second cookie value"]
      end
    end
  end

  describe "get_fields" do

    before(:each) do
      headers = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=ISO-8859-1\r\nContent-Length: 18\r\nSet-Cookie: first cookie value\r\nServer: gws\r\nTransfer-Encoding: chunked\r\nSet-Cookie: second cookie value\r\n\r\n"
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
      @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
    end

    it "should return an array containing all matching field values" do
      @cf.get_fields("Set-Cookie").should == ["first cookie value", "second cookie value"]
      @cf.get_fields("Content-Length").should == ["18"]
    end

    it "should do a case-insensitive match of the key to header fields" do
      @cf.get_fields("content-length").should == ["18"]
    end

    it "should return empty array when key matches no header field" do
      @cf.get_fields("non-existent").should == []
    end

  end

  describe "[]" do

    before(:each) do
      headers = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=ISO-8859-1\r\nContent-Length: 18\r\nSet-Cookie: first cookie value\r\nServer: gws\r\nTransfer-Encoding: chunked\r\nSet-Cookie: second cookie value\r\n\r\n"
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
      @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
    end

    it "should return the last matching field value" do
      @cf["Set-Cookie"].should == "second cookie value"
    end

    it "should return the entire header value" do
      @cf["Content-Type"].should == "text/html; charset=ISO-8859-1"
    end

    it "should return the header value as a string" do
      @cf["Content-Length"].should == "18"
    end

    it "should do a case-insensitive match of the key to header fields" do
      @cf["content-length"].should == "18"
    end

    it "should return nil when key matches no header field" do
      @cf["non-existent"].should == nil
    end

  end

  describe "content_type" do

    it "should return the content-type as a mime type, disgarding charset or other info found in the content-type header" do
      headers = "HTTP/1.1 200 OK\r\nContent-Length: 18\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n"
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
      @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
      @cf.content_type.should == "text/html"
    end

    it "should return the content-type from the last header field value" do
      headers = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=ISO-8859-1\r\nContent-Length: 18\r\nContent-Type: application/xhtml+xml; charset=UTF-8\r\n\r\n"
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
      @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
      @cf.content_type.should == "application/xhtml+xml"
    end

    it "should return nil when the response doesn't contain a content-type header" do
      headers = "HTTP/1.1 200 OK\r\nr\nContent-Length: 18r\n\r\n"
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
      @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
      @cf.content_type.should == nil
    end

  end

  describe "content_length" do

    it "should return the last content-length header field value, as an integer" do
      headers = "HTTP/1.1 200 OK\r\nContent-Length: 100\r\nContent-Length: 18\r\n\r\n"
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
      @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
      @cf.content_length.should == 18
    end

    it "should return nil when the response doesn't contain a content-length header" do
      headers = "HTTP/1.1 200 OK\r\nr\nContent-Type: text/htmlr\n\r\n"
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK', :header_str => headers, :timeout= => nil)
      @cf = CurbFu::Response::Base.from_curb_response(mock_curb)
      @cf.content_length.should == nil
    end

  end

end
