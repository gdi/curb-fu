require 'rack'

module CurbFu
  module Test
    class Server
      def self.serve(&blk)
        Rack::Builder.app do
          run lambda { |env|
            CurbFu::Test::RequestLogger.log(env)
            yield(env) 
          }
        end
      end
  
      def self.error!(message)
        puts message
        raise StandardError, message
      end
    end
  end
end