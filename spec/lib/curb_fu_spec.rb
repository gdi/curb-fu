require File.dirname(__FILE__) + '/../spec_helper'

describe CurbFu do
  describe "stubs=" do
    it 'should insert the CurbFu::Request::Test module into CurbFu::Request' do
      CurbFu.stubs = { 'example.com' => mock(Object, :call => [200, {}, "Hello, World"] ) }
      CurbFu::Request.should include(CurbFu::Request::Test)
    end
    it 'should not insert the CurbFu::StubbedRequest module into CurbFu::Request if it is already there' do
      CurbFu::Request.stub!(:include?).and_return(false, true)
      CurbFu::Request.should_receive(:include).once
      CurbFu.stubs = { 'example.com' => mock(Object, :call => [200, {}, "Hello, World"] ) }
      CurbFu.stubs = { 'example.net' => mock(Object, :call => [404, {}, "not found"] ) }
    end
    it 'should not insert the CurbFu::StubbedRequest module if the method is given nil instead of a hash' do
      CurbFu::Request.should_not_receive(:include)
      CurbFu.stubs = nil
    end
  end
  
  describe 'stubs' do
    it 'should return nil by default' do
      CurbFu.stubs.should be_nil
    end
    it 'should return a hash of hostnames pointing to CurbFu::StubbedRequest::TestInterfaces' do
      CurbFu.stubs = { 'example.com' => mock(Object, :call => [200, {}, "Hello, World"] ) }
      CurbFu.stubs['example.com'].should be_a_kind_of(CurbFu::Request::Test::Interface)
    end
    it 'should set the hostname on each interface' do
      CurbFu.stubs = {
        'ysthevanishedomens.com' => mock(Object)
      }
      
      CurbFu.stubs['ysthevanishedomens.com'].hostname.should == 'ysthevanishedomens.com'
    end
  end
end