require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'curb-fu/core_ext'

describe CurbFu::Request::Parameter do
  describe "initialize" do
    it "should accept a key and value pair" do
      param = CurbFu::Request::Parameter.new("simple", "value")
      param.name.should == "simple"
      param.value.should == "value"
    end
    it "should accept a hash" do
      lambda { CurbFu::Request::Parameter.new("policy",
        { "archive_length_units" => "eons", "to" => "cthulhu@goo.org" }) }.should_not raise_error
    end
  end
  
  describe "to_uri_param" do
    it "should serialize the key and value into an acceptable uri format" do
      param = CurbFu::Request::Parameter.new("simple", "value")
      param.to_uri_param.should == "simple=value"
    end
    describe "complex cases" do
      it "should convert a hash parameter into the appropriate set of name-value pairs" do
        params = CurbFu::Request::Parameter.new("policy", { "archive_length_units" => "eons", "to" => "cthulhu@goo.org" })
        params.to_uri_param.should =~ /policy\[archive_length_units\]=eons/
        params.to_uri_param.should =~ /policy\[to\]=cthulhu\%40goo\.org/
        params.to_uri_param.should =~ /.+&.+/
      end
      it "should even handle cases where one of the hash parameters is an array" do
        params = CurbFu::Request::Parameter.new("messages", { "failed" => [2134, 123, 4325], "policy_id" => 45 })
        params.to_uri_param.should =~ /messages\[failed\]\[\]=2134/
        params.to_uri_param.should =~ /messages\[failed\]\[\]=123/
        params.to_uri_param.should =~ /messages\[failed\]\[\]=4325/
        params.to_uri_param.should =~ /messages\[policy_id\]=45/
        params.to_uri_param.should =~ /.+&.+&.+&.+/
      end
    end
  end
  
  describe "to_curl_post_field" do
    it "should serialize the key and value into an acceptable uri format" do
      param = CurbFu::Request::Parameter.new("simple", "value")
      field = param.to_curl_post_field
      field.name.should == 'simple'
      field.content.should == 'value'
    end
    describe "complex cases" do
      it "should convert a hash parameter into the appropriate set of name-value pairs" do
        params = CurbFu::Request::Parameter.new("policy",
          { "archive_length_units" => "eons", "to" => "cthulhu@goo.org" })
        fields = params.to_curl_post_field
        fields.find { |f| f.name == 'policy[archive_length_units]' && f.content == 'eons'}.should_not be_nil
        fields.find { |f| f.name == 'policy[to]' && f.content == 'cthulhu@goo.org'}.should_not be_nil
      end
      it "should even handle cases where one of the hash parameters is an array" do
        params = CurbFu::Request::Parameter.new("messages", { "failed" => [2134, 123, 4325], "policy_id" => 45 }).
          to_curl_post_field
        params.find { |p| p.name == 'messages[failed][]' && p.content == '2134' }.should_not be_nil
        params.find { |p| p.name == 'messages[failed][]' && p.content == '123' }.should_not be_nil
        params.find { |p| p.name == 'messages[failed][]' && p.content == '4325' }.should_not be_nil
        params.find { |p| p.name == 'messages[policy_id]' && p.content == '45' }.should_not be_nil
      end
      it "should not send a CGI-escaped value to Curl::PostField" do
        field = CurbFu::Request::Parameter.new("messages", "uh-oh! We've failed!").
          to_curl_post_field
          
        field.content.should == "uh-oh! We've failed!"
      end
      it "should not CGI-escape @ symbols" do
        field = CurbFu::Request::Parameter.new("messages", "bob@apple.com").
          to_curl_post_field
          
        field.content.should == "bob@apple.com"
      end
    end
  end
end