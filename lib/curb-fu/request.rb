require 'rubygems'
require 'curb'

module CurbFu
  class Request
    class << self
      def timeout=(val)
        @timeout = val
      end

      def timeout
        @timeout.nil? ? 60 : @timeout
      end

      def build(url_params, query_params = {})
        curb = Curl::Easy.new(build_url(url_params, query_params))
        unless url_params.is_a?(String)
          curb.userpwd = "#{url_params[:username]}:#{url_params[:password]}" if url_params[:username]
          curb.headers = url_params[:headers] || {}
        end

        curb.timeout = @timeout

        curb
      end

      def build_url(url_params, query_params = {})
        if url_params.is_a? String
          built_url = url_params
        else
          built_url = "http://#{url_params[:host]}"
          built_url += ":" + url_params[:port].to_s if url_params[:port]
          built_url += url_params[:path] if url_params[:path]
        end
        built_url += build_query_string(query_params) unless query_params.empty?
        built_url
      end

      def build_query_string(params)
        string = "?"
        string += params.inject([]) { |ary, (name, value)| ary << [name,value].join('=') }.join('&')
      end

      def get(url, params = {})
        curb = self.build(url, params)
        curb.http_get
        CurbFu::Response::Base.create(curb)
      end

      def put(url, params = {})
        fields = params.collect do |k,v|
          v = v.is_a?(Array) ? v.join(',') : v
          "#{k}=#{v}"
        end

        curb = self.build(url)
        curb.http_put(*fields)
        CurbFu::Response::Base.create(curb)
      end

      def post(url, params = {})
        fields = create_fields(params)

        curb = self.build(url)
        curb.headers["Expect:"] = ''
        curb.http_post(*fields)
        CurbFu::Response::Base.create(curb)
      end

      def post_file(url, params = {}, filez = {})
        fields = create_fields(params)
        fields += create_file_fields(filez)

        curb = self.build(url)
        curb.multipart_form_post = true
        curb.http_post(*fields)
        CurbFu::Response::Base.create(curb)
      end

      def delete(url)
        curb = self.build(url)
        curb.http_delete
        CurbFu::Response::Base.create(curb)
      end

      def create_fields(params)
        fields = []
        params.each do |name, value|
          value_string = value if value.is_a?(String)
          value_string = value.join(',') if value.is_a?(Array)
          value_string ||= value.to_s

          fields << Curl::PostField.content(name,value_string)
        end
        return fields
      end

      def create_file_fields(filez)
        fields = []
        filez.each do |name, path|
          fields << Curl::PostField.file(name, path)
        end
        fields
      end
    end
  end
end
