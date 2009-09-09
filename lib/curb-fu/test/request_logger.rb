module CurbFu
  module Test
    class RequestLogger
      class << self
        def entries(host)
          @entries ||= {}
          @entries[host] ||= []
        end
    
        def log(env)
          req = Rack::Request.new(env)
          url = env['PATH_INFO']
          post_params = req.POST
          host = env['HTTP_HOST'] || env['SERVER_NAME']
          entries(host) << { :url => url, :params => post_params }
        end
        def requested?(host, url, params = nil)
          url_found = (url.is_a?(String)) ?
            !entries(host).find { |entry| entry[:url] == url }.nil? :
            !entries(host).find { |entry| entry[:url] =~ url }.nil?
          if params.nil?
            return url_found
          else
            params_found = !entries(host).find { |entry| entry[:params] == params }.nil?
            url_found && params_found
          end
        end
      end
    end
  end
end