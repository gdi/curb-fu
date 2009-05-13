require File.dirname(__FILE__) + '/../../../spec_helper'

def test_file_path
  File.dirname(__FILE__) + "/../../../fixtures/foo.txt"
end

describe CurbFu::Request::Test do
  before :each do
    @a_server = mock(Object, :call => [200, { 'Content-Type' => 'spec/testcase' }, "A is for Archer, an excellent typeface."])
    @b_server = mock(Object, :call => [200, {}, "B is for Ballyhoo, like what happened when Twitter switched to Scala"])
    @c_server = mock(Object, :call => [200, {}, "C is for Continuous, as in Integration"])
    
    CurbFu.stubs = {
      'a.example.com' => @a_server,
      'b.example.com' => @b_server,
      'c.example.com' => @c_server
    }
    
    @mock_rack_response = mock(Rack::MockResponse, :status => 200, :headers => {}, :body => "C is for Continuous, as in Integration")
  end
  
  describe "module inclusion" do
    it "should define a 'get' method" do
      class Test
        include CurbFu::Request::Test
      end
      Test.should respond_to(:get)
    end
  end
  
  describe "parse_hostname" do
    it "should return just the hostname from a full URL" do
      CurbFu::Request.parse_hostname('http://a.example.com/foo/bar?transaxle=true').
        should == 'a.example.com'
    end
    it 'should return the hostname if just a hostname is given' do
      CurbFu::Request.parse_hostname('b.example.com').
        should == 'b.example.com'
    end
  end
  
  describe "match_host" do
    it "should return the appropriate Rack::Test instance to delegate the request to" do
      CurbFu::Request.match_host("a.example.com").app.should == @a_server
    end
    it "should return nil if no match is made" do
      CurbFu::Request.match_host("m.google.com").should be_nil
    end
  end
  
  describe "get" do
    it 'should delegate the get request to the Rack::Test instance' do
      CurbFu.stubs['a.example.com'].should_receive(:get).with('http://a.example.com/gimme/html', anything).and_return(@mock_rack_response)
      @a_server.should respond_to(:call)
      CurbFu::Request.get('http://a.example.com/gimme/html')
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.get('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
    it 'should return a CurbFu::Response object' do
      response = CurbFu::Request.get('http://a.example.com/gimme/html')
      response.should be_a_kind_of(CurbFu::Response::Base)
      response.status.should == 200
      response.headers.should == { 'Content-Type' => 'spec/testcase' }
      response.body.should == "A is for Archer, an excellent typeface."
    end
    it 'should accept a url that is a hash along with query params' do
      CurbFu::Request.should_receive(:get_host_and_interface).with('http://a.example.com/gimme/shelter?when=now')
      CurbFu::Request.stub!(:respond)
      
      CurbFu::Request.get({ :host => 'a.example.com', :path => '/gimme/shelter' },{ :when => 'now' })
    end
    it 'should accept a url that is a hash and has no query params' do
      CurbFu::Request.should_receive(:get_host_and_interface).with('http://a.example.com/gimme/shelter')
      CurbFu::Request.stub!(:respond)
      
      CurbFu::Request.get(:host => 'a.example.com', :path => '/gimme/shelter')
    end
    it 'should handle http authentication' do
      CurbFu::Request.should_receive(:respond).with(anything, :get, 'http://a.example.com/gimme/shelter', {}, 'floyd', 'barber')
      
      CurbFu::Request.get(:host => 'a.example.com', :path => '/gimme/shelter', :username => 'floyd', :password => 'barber')
    end
  end
  
  describe "post" do
    it 'should delegate the post request to the Rack::Test instance' do
      CurbFu.stubs['b.example.com'].should_receive(:post).
        with('http://b.example.com/html/backatcha', {'html' => 'CSRF in da house! <script type="text/compromise">alert("gotcha!")</script>'}).
        and_return(@mock_rack_response)
      CurbFu::Request.post('http://b.example.com/html/backatcha',
        {'html' => 'CSRF in da house! <script type="text/compromise">alert("gotcha!")</script>'})
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.post('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
    it 'should return a CurbFu::Response object' do
      response = CurbFu::Request.post('http://a.example.com/gimme/html')
      response.should be_a_kind_of(CurbFu::Response::Base)
      response.status.should == 200
      response.headers.should == { 'Content-Type' => 'spec/testcase' }
      response.body.should == "A is for Archer, an excellent typeface."
    end
    it 'should accept a url that is a hash' do
      CurbFu::Request.should_receive(:get_host_and_interface).with('http://a.example.com/gimme/shelter')
      CurbFu::Request.stub!(:respond)
      
      CurbFu::Request.post(:host => 'a.example.com', :path => '/gimme/shelter')
    end
  end
  
  describe "post_file" do
    it 'should delegate the post request to the Rack::Test instance' do
      CurbFu.stubs['b.example.com'].should_receive(:post).
        with('http://b.example.com/html/backatcha', {"file_0"=>anything, "filename"=>"asdf ftw"}).
        and_return(@mock_rack_response)
      CurbFu::Request.post_file('http://b.example.com/html/backatcha', {'filename' => 'asdf ftw'}, {'foo.txt' => test_file_path })
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.post_file('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
    it 'should return a CurbFu::Response object' do
      response = CurbFu::Request.post_file('http://a.example.com/gimme/html')
      response.should be_a_kind_of(CurbFu::Response::Base)
      response.status.should == 200
      response.headers.should == { 'Content-Type' => 'spec/testcase' }
      response.body.should == "A is for Archer, an excellent typeface."
    end
    it 'should accept a url that is a hash' do
      CurbFu::Request.should_receive(:get_host_and_interface).with('http://a.example.com/gimme/shelter')
      CurbFu::Request.stub!(:respond)
      
      CurbFu::Request.post_file(:host => 'a.example.com', :path => '/gimme/shelter')
    end
  end
  
  describe "put" do
    it 'should delegate the get request to the Rack::Test instance' do
      CurbFu.stubs['a.example.com'].should_receive(:put).with('http://a.example.com/gimme/html', anything).and_return(@mock_rack_response)
      CurbFu::Request.put('http://a.example.com/gimme/html')
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.put('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
    it 'should return a CurbFu::Response object' do
      response = CurbFu::Request.put('http://a.example.com/gimme/html')
      response.should be_a_kind_of(CurbFu::Response::Base)
      response.status.should == 200
      response.headers.should == { 'Content-Type' => 'spec/testcase' }
      response.body.should == "A is for Archer, an excellent typeface."
    end
    it 'should accept a url that is a hash' do
      CurbFu::Request.should_receive(:get_host_and_interface).with('http://a.example.com/gimme/shelter')
      CurbFu::Request.stub!(:respond)
      
      CurbFu::Request.put(:host => 'a.example.com', :path => '/gimme/shelter')
    end
  end
  
  describe "delete" do
    it 'should delegate the get request to the Rack::Test instance' do
      CurbFu.stubs['a.example.com'].should_receive(:delete).with('http://a.example.com/gimme/html', anything).and_return(@mock_rack_response)
      @a_server.should respond_to(:call)
      CurbFu::Request.delete('http://a.example.com/gimme/html')
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.delete('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
    it 'should return a CurbFu::Response object' do
      response = CurbFu::Request.delete('http://a.example.com/gimme/html')
      response.should be_a_kind_of(CurbFu::Response::Base)
      response.status.should == 200
      response.headers.should == { 'Content-Type' => 'spec/testcase' }
      response.body.should == "A is for Archer, an excellent typeface."
    end
    it 'should accept a url that is a hash' do
      CurbFu::Request.should_receive(:get_host_and_interface).with('http://a.example.com/gimme/shelter')
      CurbFu::Request.stub!(:respond)
      
      CurbFu::Request.delete(:host => 'a.example.com', :path => '/gimme/shelter')
    end
  end
end
