require 'rack/test'

module CurbFu
  class Request
    module Test
      def self.included(target)
        target.extend(ClassMethods)
      end
    
    
      module ClassMethods
        def get(url, params = {})
          host = parse_hostname(url)
          interface = match_host(host)
          if interface.nil?
            raise Curl::Err::ConnectionFailedError
          else
            interface.get(url, params)
          end
        end
        
        def post(url, params = {})
          host = parse_hostname(url)
          interface = match_host(host)
          if interface.nil?
            raise Curl::Err::ConnectionFailedError
          else
            interface.post(url, params)
          end
        end
        
        def post_file(url, params = {}, filez = {})
          host = parse_hostname(url)
          interface = match_host(host)
          uploaded_files = filez.inject({}) { |hsh, f| hsh["file_#{hsh.keys.length}"] = Rack::Test::UploadedFile.new(f.last); hsh }
          if interface.nil?
            raise Curl::Err::ConnectionFailedError
          else
            interface.post(url, params.merge(uploaded_files))
          end
        end
        
        def put(url, params = {})
          host = parse_hostname(url)
          interface = match_host(host)
          if interface.nil?
            raise Curl::Err::ConnectionFailedError
          else
            interface.put(url, params)
          end
        end
        
        def delete(url, params = {})
          host = parse_hostname(url)
          interface = match_host(host)
          if interface.nil?
            raise Curl::Err::ConnectionFailedError
          else
            interface.delete(url, params)
          end
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