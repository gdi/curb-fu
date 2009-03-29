require File.dirname(__FILE__) + '/../../spec_helper'
require 'htmlentities'

describe CurbFu::Response::Base do
  describe "successes" do
    it "should create a success (200) response" do
      mock_curb = mock(Object, :response_code => 200, :body_str => 'OK')
      r = CurbFu::Response::Base.create(mock_curb)
      r.should be_a_kind_of(CurbFu::Response::Base)
      r.should be_a_kind_of(CurbFu::Response::Success)
      r.should be_a_kind_of(CurbFu::Response::OK)
      r.should_not be_a_kind_of(CurbFu::Response::Created)
    end
    it "should create a success (201) response" do
      mock_curb = mock(Object, :response_code => 201, :body_str => 'OK')
      r = CurbFu::Response::Base.create(mock_curb)
      r.should be_a_kind_of(CurbFu::Response::Base)
      r.should be_a_kind_of(CurbFu::Response::Success)
      r.should be_a_kind_of(CurbFu::Response::Created)
    end
  end
  it "should create a 400 response" do
    mock_curb = mock(Object, :response_code => 404, :body_str => 'OK')
    r = CurbFu::Response::Base.create(mock_curb)
    r.should be_a_kind_of(CurbFu::Response::Base)
    r.should be_a_kind_of(CurbFu::Response::ClientError)
  end
  it "should create a 500 response" do
    mock_curb = mock(Object, :response_code => 503, :body_str => 'OK')
    r = CurbFu::Response::Base.create(mock_curb)
    r.should be_a_kind_of(CurbFu::Response::Base)
    r.should be_a_kind_of(CurbFu::Response::ServerError)
  end
end