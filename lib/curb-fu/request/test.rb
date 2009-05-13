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
          url_string = build_url(url, params)
          username, password = get_auth(url)
          host, interface = get_host_and_interface(url_string)
          
          respond(interface, :get, url_string, params, username, password)
        end
        
        def post(url, params = {})
          url_string = build_url(url)
          host, interface = get_host_and_interface(url_string)
          respond(interface, :post, url_string, params)
        end
        
        def post_file(url, params = {}, filez = {})
          url_string = build_url(url)
          host, interface = get_host_and_interface(url_string)
          uploaded_files = filez.inject({}) { |hsh, f| hsh["file_#{hsh.keys.length}"] = Rack::Test::UploadedFile.new(f.last); hsh }
          respond(interface, :post, url_string, params.merge(uploaded_files))
        end
        
        def put(url, params = {})
          url_string = build_url(url)
          host, interface = get_host_and_interface(url_string)
          respond(interface, :put, url_string, params)
        end
        
        def delete(url, params = {})
          url_string = build_url(url)
          host, interface = get_host_and_interface(url_string)
          respond(interface, :delete, url_string, params)
        end
        
        def respond(interface, operation, url, params, username = nil, password = nil)
          if interface.nil?
            raise Curl::Err::ConnectionFailedError
          else
            interface.authorize(username, password) unless username.nil?
            response = interface.send(operation, url, params)
            CurbFu::Response::Base.from_rack_response(response)
          end
        end
        
        def get_host_and_interface(url)
          if url.is_a?(Hash)
            host = url[:hostname]
          else
            host = parse_hostname(url)
          end
          interface = match_host(host)
          [host, interface]
        end
        
        def parse_hostname(uri)
          parsed_hostname = URI.parse(uri)
          parsed_hostname.host || parsed_hostname.path
        end
        
        def match_host(host)
          match = CurbFu.stubs.find { |(hostname, interface)| hostname == host }
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