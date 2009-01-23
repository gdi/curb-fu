require File.dirname(__FILE__) + '/../../spec_helper'
require 'htmlentities'

describe CurbFu::Response::Base do
  it "should create a success response" do
    mock_curb = mock(Object, :response_code => 200, :body_str => 'OK')
    r = CurbFu::Response::Base.create(mock_curb)
    r.should be_a_kind_of(CurbFu::Response::Base)
    r.should be_a_kind_of(CurbFu::Response::Success)
    r.should be_a_kind_of(CurbFu::Response::OK)
    r.should_not be_a_kind_of(CurbFu::Response::Created)
  end
end