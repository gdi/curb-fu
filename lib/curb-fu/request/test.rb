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
          url = build_url(url, params)
          host, interface = get_host_and_interface(url)
          respond(interface, :get, url, params)
        end
        
        def post(url, params = {})
          url = build_url(url)
          host, interface = get_host_and_interface(url)
          respond(interface, :post, url, params)
        end
        
        def post_file(url, params = {}, filez = {})
          url = build_url(url)
          host, interface = get_host_and_interface(url)
          uploaded_files = filez.inject({}) { |hsh, f| hsh["file_#{hsh.keys.length}"] = Rack::Test::UploadedFile.new(f.last); hsh }
          respond(interface, :post, url, params.merge(uploaded_files))
        end
        
        def put(url, params = {})
          url = build_url(url)
          host, interface = get_host_and_interface(url)
          respond(interface, :put, url, params)
        end
        
        def delete(url, params = {})
          url = build_url(url)
          host, interface = get_host_and_interface(url)
          respond(interface, :delete, url, params)
        end
        
        def respond(interface, operation, url, params)
          if interface.nil?
            raise Curl::Err::ConnectionFailedError
          else
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