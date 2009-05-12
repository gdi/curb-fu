require File.dirname(__FILE__) + '/../../../spec_helper'

def test_file_path
  File.dirname(__FILE__) + "/../../../fixtures/foo.txt"
end

describe CurbFu::Request::Test do
  before :each do
    @a_server = mock(Object, :call => [200, {}, "A is for Archer, an excellent typeface."])
    @b_server = mock(Object, :call => [200, {}, "B is for Ballyhoo, like what happened when Twitter switched to Scala"])
    @c_server = mock(Object, :call => [200, {}, "C is for Continuous, as in Integration"])
    
    CurbFu.stubs = {
      'a.example.com' => @a_server,
      'b.example.com' => @b_server,
      'c.example.com' => @c_server
    }
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
      CurbFu.stubs['a.example.com'].should_receive(:get).with('http://a.example.com/gimme/html', anything)
      @a_server.should respond_to(:call)
      CurbFu::Request.get('http://a.example.com/gimme/html')
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.get('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
  end
  
  describe "post" do
    it 'should delegate the post request to the Rack::Test instance' do
      CurbFu.stubs['b.example.com'].should_receive(:post).with('http://b.example.com/html/backatcha', {'html' => 'CSRF in da house! <script type="text/compromise">alert("gotcha!")</script>'})
      CurbFu::Request.post('http://b.example.com/html/backatcha', {'html' => 'CSRF in da house! <script type="text/compromise">alert("gotcha!")</script>'})
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.post('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
  end
  
  describe "post_file" do
    it 'should delegate the post request to the Rack::Test instance' do
      CurbFu.stubs['b.example.com'].should_receive(:post).with('http://b.example.com/html/backatcha', {"file_0"=>anything, "filename"=>"asdf ftw"})
      CurbFu::Request.post_file('http://b.example.com/html/backatcha', {'filename' => 'asdf ftw'}, {'foo.txt' => test_file_path })
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.post_file('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
  end
  
  describe "put" do
    it 'should delegate the get request to the Rack::Test instance' do
      CurbFu.stubs['a.example.com'].should_receive(:put).with('http://a.example.com/gimme/html', anything)
      CurbFu::Request.put('http://a.example.com/gimme/html')
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.put('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
  end
  
  describe "delete" do
    it 'should delegate the get request to the Rack::Test instance' do
      CurbFu.stubs['a.example.com'].should_receive(:delete).with('http://a.example.com/gimme/html', anything)
      @a_server.should respond_to(:call)
      CurbFu::Request.delete('http://a.example.com/gimme/html')
    end
    it 'should raise Curl::Err::ConnectionFailedError if hostname is not defined in stub list' do
      lambda { CurbFu::Request.delete('http://m.google.com/gimme/html') }.should raise_error(Curl::Err::ConnectionFailedError)
    end
  end
end
