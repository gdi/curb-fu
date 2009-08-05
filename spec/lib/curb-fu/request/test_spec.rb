require File.dirname(__FILE__) + '/../../../spec_helper'

def test_file_path
  File.dirname(__FILE__) + "/../../../fixtures/foo.txt"
end

describe CurbFu::Request::Test do
  before :each do
    @a_server = mock(Object, :call => [200, { 'Content-Type' => 'spec/testcase' }, ["A is for Archer, an excellent typeface."]])
    @b_server = mock(Object, :call => [200, {},["B is for Ballyhoo, like what happened when Twitter switched to Scala"]])
    @c_server = mock(Object, :call => [200, {}, ["C is for Continuous, as in Integration"]])
    
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
  
  describe "process_headers" do
    it "should convert http headers into their upcased, HTTP_ prepended form for the Rack environment" do
      CurbFu::Request.process_headers({'X-Mirror-Request' => 'true'}).should == {"HTTP_X_MIRROR_REQUEST" => "true"}
    end
    it "should handle a whole hashful of headers" do
      CurbFu::Request.process_headers({
        'X-Mirror-Request' => 'true',
        'Accept-Encoding' => '*/*',
        'X-Forwarded-For' => 'greenviewdata.com'
      }).should == {
        "HTTP_X_MIRROR_REQUEST" => "true",
        "HTTP_ACCEPT_ENCODING" => "*/*",
        "HTTP_X_FORWARDED_FOR" => "greenviewdata.com"
      }
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
  
  describe "build_request_options" do
    it "should parse headers" do
      CurbFu::Request.build_request_options({:host => 'd.example.com', :path => '/big/white/dog', :headers => { 'Accept' => 'beer/pilsner' }}).
        should include(:headers => { 'Accept' => 'beer/pilsner' })
    end
    it "should parse url" do
      CurbFu::Request.build_request_options({:host => 'd.example.com', :path => '/big/white/dog'}).
        should include(:url => 'http://d.example.com/big/white/dog')
    end
    it "should parse username and password" do
      CurbFu::Request.build_request_options({:host => 'd.example.com', :path => '/big/white/dog', :username => 'bill', :password => 's3cr3t' }).
        should include(:username => 'bill', :password => 's3cr3t')
    end
    it "should get an interface" do
      CurbFu::Request.build_request_options({:host => 'c.example.com', :path => '/big/white/dog'}).
        should include(:interface => CurbFu.stubs['c.example.com'])
    end
  end
  
  describe "get_interface" do
    it "should parse a string" do
      CurbFu::Request.get_interface('http://a.example.com').app.should == @a_server
    end
    it "should parse a hash" do
      CurbFu::Request.get_interface({:host => 'a.example.com'}).app.should == @a_server
    end
  end
  
  describe "respond" do
    it "should convert headers to uppercase, underscorized" do
      CurbFu::Response::Base.stub!(:from_rack_response)
      mock_interface = mock(Object, :send => mock(Object, :status => 200), :hostname= => nil, :hostname => 'a.example.com')
      mock_interface.should_receive(:header).with('HTTP_X_MONARCHY','false')
      mock_interface.should_receive(:header).with('HTTP_X_ANARCHO_SYNDICALIST_COMMUNE','true')
      
      CurbFu::Request.respond(mock_interface, :get, 'http://a.example.com/', {}, 
        {'X-Anarcho-Syndicalist-Commune' => 'true', 'X-Monarchy' => 'false'}, nil, nil)
    end
  end
  
  describe "hashify_params" do
    it "should turn a URL-formatted query string into a hash of parameters" do
      hash = CurbFu::Request.hashify_params("color=red&shape=round")
      hash.should include('color' => 'red')
      hash.should include('shape' => 'round')
    end
    it "should convert array-formatted params into a hash of arrays" do
      hash = CurbFu::Request.hashify_params("make[]=Chevrolet&make[]=Pontiac&make[]=GMC")
      hash.should  == {'make' => ['Chevrolet','Pontiac','GMC']}
    end
    it "should convert hash parameters into a hash of hashes" do
      hash = CurbFu::Request.hashify_params("car[make]=Chevrolet&car[color]=red&car[wheel_shape]=round")
      hash.should  == {'car' => {
        'make' => 'Chevrolet',
        'color' => 'red',
        'wheel_shape' => 'round'
      }}
    end
    it 'should remove any leading ?s' do
      hash = CurbFu::Request.hashify_params("?q=134&dave=astronaut")
      hash.keys.should_not include('?q')
    end
  end
  
  describe "get" do
    it 'should delegate the get request to the Rack::Test instance' do
      CurbFu.stubs['a.example.com'].should_receive(:get).with('http://a.example.com/gimme/html', anything, anything).and_return(@mock_rack_response)
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
  end
  
  describe "post" do
    it 'should delegate the post request to the Rack::Test instance' do
      CurbFu.stubs['b.example.com'].should_receive(:post).
        with('http://b.example.com/html/backatcha', {'html' => 'CSRF in da house! <script type="text/compromise">alert("gotcha!")</script>'}, anything).
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
  end
  
  describe "post_file" do
    it 'should delegate the post request to the Rack::Test instance' do
      CurbFu.stubs['b.example.com'].should_receive(:post).
        with('http://b.example.com/html/backatcha', {"file_0"=>anything, "filename"=>"asdf ftw"}, anything).
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
  end
  
  describe "put" do
    it 'should delegate the put request to the Rack::Test instance' do
      CurbFu.stubs['a.example.com'].should_receive(:put).with('http://a.example.com/gimme/html', anything, anything).and_return(@mock_rack_response)
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
  end
  
  describe "delete" do
    it 'should delegate the delete request to the Rack::Test instance' do
      CurbFu.stubs['a.example.com'].should_receive(:delete).with('http://a.example.com/gimme/html', anything, anything).and_return(@mock_rack_response)
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
  end
end
