require 'rack/test'

module CurbFu
  class Request
    module Test
      include Common
      
      def self.included(target)
        target.extend(ClassMethods)
      end

      module ClassMethods
        def get(url, params = {})
          request_options = build_request_options(url)
          respond(request_options[:interface], :get, request_options[:url],
            params, request_options[:headers], request_options[:username], request_options[:password])
        end
        
        def post(url, params = {})
          request_options = build_request_options(url)
          respond(request_options[:interface], :post, request_options[:url],
            params, request_options[:headers], request_options[:username], request_options[:password])
        end
        
        def post_file(url, params = {}, filez = {})
          request_options = build_request_options(url)
          uploaded_files = filez.inject({}) { |hsh, f| hsh["file_#{hsh.keys.length}"] = Rack::Test::UploadedFile.new(f.last); hsh }
          respond(request_options[:interface], :post, request_options[:url], 
            params.merge(uploaded_files), request_options[:headers], request_options[:username], request_options[:password])
        end
        
        def put(url, params = {})
          request_options = build_request_options(url)
          respond(request_options[:interface], :put, request_options[:url],
            params, request_options[:headers], request_options[:username], request_options[:password])
        end
        
        def delete(url, params = {})
          request_options = build_request_options(url)
          respond(request_options[:interface], :delete, request_options[:url],
            params, request_options[:headers], request_options[:username], request_options[:password])
        end
        
        def build_request_options(url)
          options = {}
          options[:headers] = (url.is_a?(String)) ? nil : url.delete(:headers)
          options[:url] = build_url(url)
          options[:username], options[:password] = get_auth(url)
          options[:interface] = get_interface(url)
          options
        end
        
        def respond(interface, operation, url, params, headers, username = nil, password = nil)
          if interface.nil?
            raise Curl::Err::ConnectionFailedError
          else
            unless headers.nil?
              process_headers(headers).each do |name, value|
                interface.header(name, value)
              end
            end
            interface.authorize(username, password) unless username.nil?
            response = interface.send(operation, url, params)
            CurbFu::Response::Base.from_rack_response(response)
          end
        end
        
        def process_headers(headers)
          headers.inject({}) do |accum, (header_name, value)|
            key = header_name.gsub("-", "_").upcase
            key = "HTTP_" + key unless key =~ /^HTTP_/
            accum[key] = value
            accum
          end
        end
        
        def get_interface(url)
          if url.is_a?(Hash)
            host = url[:host]
          else
            host = parse_hostname(url)
          end
          match_host(host)
        end
        
        def parse_hostname(uri)
          parsed_hostname = URI.parse(uri)
          parsed_hostname.host || parsed_hostname.path
        end
        
        def match_host(host)
          match = CurbFu.stubs.find do |(hostname, interface)|
            hostname == host
          end
          match.last unless match.nil?
        end
        
        def get_auth(url)
          username = password = nil
          if url.is_a?(Hash) && url[:username]
            username = url[:username]
            password = url[:password]
          end
          [username, password]
        end
      end
    
      class Interface
        include Rack::Test::Methods
        
        attr_accessor :app
        
        def initialize(app)
          @app = app
        end
      end
    end
  end
end