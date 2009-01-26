require File.dirname(__FILE__) + '/../../spec_helper'
require 'htmlentities'

describe CurbFu::Request do
  describe "get" do
    it "should get the google" do
      CurbFu::Request.get("http://www.google.com").should be_a_kind_of(CurbFu::Response::OK)
    end
    it "should return a status code" do
      CurbFu::Request.get("http://www.google.com").status.should == 200
    end
    it "should return a body" do
      CurbFu::Request.get("http://www.google.com").body.should =~ /html/
    end
    it "should return a 404 code correctly" do
      CurbFu::Request.get("http://www.google.com/ponies_and_pirates").status.should == 404
      CurbFu::Request.get("http://www.google.com/ponies_and_pirates").should be_a_kind_of(CurbFu::Response::NotFound)
    end
  end
  
  describe "get (with_hash)" do
    it "should get google from {:host => \"www.google.com\", :port => 80}" do
      CurbFu::Request.get({:host => "www.google.com", :port => 80}).should be_a_kind_of(CurbFu::Response::OK)
    end
    
    it "should set authorization username and password if provided" do
      CurbFu::Request.get({:host => "control.greenviewdata.com", :port => 80, :username => "archiver", :password => "test"}).
        should be_a_kind_of(CurbFu::Response::OK)
    end
  end
  
  describe "post" do
    it "should send each parameter to Curb#http_post" do
      @mock_curb = mock(Curl::Easy, :headers= => nil, :headers => {}, :response_code => 200, :body_str => 'yeeeah')
      Curl::Easy.stub!(:new).and_return(@mock_curb)
      @mock_q = Curl::PostField.content('q','derek')
      @mock_r = Curl::PostField.content('r','matt')
      Curl::PostField.stub!(:content).with('q','derek').and_return(@mock_q)
      Curl::PostField.stub!(:content).with('r','matt').and_return(@mock_r)
      
      @mock_curb.should_receive(:http_post).with(@mock_q,@mock_r)
      
      response = CurbFu::Request.post(
        {:host => "google.com", :port => 80, :path => "/search"},
        { 'q' => 'derek', 'r' => 'matt' })
    end
    
    it "should handle params that contain arrays" do
      @mock_curb = mock(Curl::Easy, :headers= => nil, :headers => {}, :response_code => 200, :body_str => 'yeeeah')
      Curl::Easy.stub!(:new).and_return(@mock_curb)
      @mock_q = Curl::PostField.content('q','derek,matt')
      Curl::PostField.stub!(:content).with('q','derek,matt').and_return(@mock_q)
      
      @mock_curb.should_receive(:http_post).with(@mock_q)
      
      response = CurbFu::Request.post(
        {:host => "google.com", :port => 80, :path => "/search"},
        { 'q' => ['derek','matt'] })
    end
    
    it "should handle params that contain any non-Array or non-String data" do
      @mock_curb = mock(Curl::Easy, :headers= => nil, :headers => {}, :response_code => 200, :body_str => 'yeeeah')
      Curl::Easy.stub!(:new).and_return(@mock_curb)
      @mock_q = Curl::PostField.content('q','1')
      Curl::PostField.stub!(:content).with('q','1').and_return(@mock_q)
      
      @mock_curb.should_receive(:http_post).with(@mock_q)
      
      response = CurbFu::Request.post(
        {:host => "google.com", :port => 80, :path => "/search"},
        { 'q' => 1 })
    end
  end
end