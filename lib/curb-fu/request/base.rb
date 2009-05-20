module CurbFu
  class Request
    module Base
      include Common
      
      def build(url_params, query_params = {})
        curb = Curl::Easy.new(build_url(url_params, query_params))
        unless url_params.is_a?(String)
          curb.userpwd = "#{url_params[:username]}:#{url_params[:password]}" if url_params[:username]
          if url_params[:authtype]
            curb.http_auth_types = url_params[:authtype]
          elsif url_params[:username]
            curb.http_auth_types = CurbFu::Authentication::BASIC
          end

          curb.headers = url_params[:headers] || {}
        end

        curb.timeout = @timeout

        curb
      end
      
      def get(url, params = {})
        curb = self.build(url, params)
        curb.http_get
        CurbFu::Response::Base.from_curb_response(curb)
      end

      def put(url, params = {})
        fields = create_put_fields(params)

        curb = self.build(url)
        curb.http_put(fields)
        CurbFu::Response::Base.from_curb_response(curb)
      end

      def post(url, params = {})
        fields = create_post_fields(params)

        curb = self.build(url)
        curb.headers["Expect:"] = ''
        curb.http_post(*fields)
        CurbFu::Response::Base.from_curb_response(curb)
      end

      def post_file(url, params = {}, filez = {})
        fields = create_post_fields(params)
        fields += create_file_fields(filez)

        curb = self.build(url)
        curb.multipart_form_post = true
        curb.http_post(*fields)
        CurbFu::Response::Base.from_curb_response(curb)
      end

      def delete(url)
        curb = self.build(url)
        curb.http_delete
        CurbFu::Response::Base.from_curb_response(curb)
      end

    private
      def create_post_fields(params)
        return params if params.is_a? String
        
        fields = []
        params.each do |name, value|
          value_string = value if value.is_a?(String)
          value_string = value.join(',') if value.is_a?(Array)
          value_string ||= value.to_s

          fields << Curl::PostField.content(name,value_string)
        end
        return fields
      end
      
      def create_put_fields(params)
        return params if params.is_a? String
        
        params.inject([]) do |list, (k,v)|
          v = v.is_a?(Array) ? v.join(',') : v
          list << "#{k}=#{v}"
          list
        end.join('&')
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