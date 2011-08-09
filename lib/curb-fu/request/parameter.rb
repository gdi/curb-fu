module CurbFu
  class Request
    class Parameter
      attr_accessor :name, :value
      
      def initialize(name, value)
        self.name = name
        self.value = value
      end
      
      def self.build_uri_params(param_hash)
        param_hash.to_param_pair
      end
      
      def self.build_post_fields(param_hash)
        param_hash.to_post_fields
      end
      
      def to_uri_param
        value.to_param_pair(name)
      end
      
      def to_curl_post_field
        field_string = value.to_param_pair(name)
        fields = field_string.split('&').collect do |field_value_pair|
          field_name, field_value = field_value_pair.split('=')
          Curl::PostField.content(field_name, CGI::unescape(field_value))
        end
        fields.length == 1 ? fields[0] : fields
      end
    end
  end
end
