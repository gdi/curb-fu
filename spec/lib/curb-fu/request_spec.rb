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
    it "should be able to post stuff successfully" # do
     #      response = CurbFu::Request.post(
     #        {:host => "google.com", :port => 80, :path => "/search"},
     #        { 'q' => 'derek' })
     #      
     #      puts (class << response; self; end).ancestors.join(", ")
     #    end
  end
end