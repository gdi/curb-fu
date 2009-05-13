module CurbFu
  class Request
    module Common
      def timeout=(val)
        @timeout = val
      end

      def timeout
        @timeout.nil? ? 60 : @timeout
      end

      def build_url(url_params, query_params = {})
        if url_params.is_a? String
          built_url = url_params
        else
          built_url = "http://#{url_params[:host]}"
          built_url += ":" + url_params[:port].to_s if url_params[:port]
          built_url += url_params[:path] if url_params[:path]
        end
        built_url += build_query_string(query_params)
        built_url
      end

      def build_query_string(params)
        if params.is_a?(Hash) && !params.empty?
          '?' + params.inject([]) { |ary, (name, value)| ary << [name,value].join('=') }.join('&')
        elsif params.is_a?(String)
          '?' + params.gsub(/^\?/,'')
        else
          ''
        end
      end
    end
  end
end