dir = File.dirname(__FILE__)
$:.unshift(dir) unless $:.include?(dir)
require 'curb-fu/response'
require 'curb-fu/request'
require 'curb-fu/authentication'
require 'curb-fu/core_ext'

module CurbFu
  class << self
    def get(*args)
      CurbFu::Request.get(*args)
    end

    def post(*args)
      CurbFu::Request.post(*args)
    end

    def put(*args)
      CurbFu::Request.put(*args)
    end

    def delete(*args)
      CurbFu::Request.delete(*args)
    end
  
    attr_accessor :stubs
    
    def stubs=(val)
      if val
        @stubs = val.inject({}) do |hsh, (hostname, rack_app)|
          hsh[hostname] = CurbFu::Request::Test::Interface.new(rack_app, hostname)
          hsh
        end
      
        unless CurbFu::Request.include?(CurbFu::Request::Test)
          CurbFu::Request.send(:include, CurbFu::Request::Test)
        end
      else
        @stubs = nil
      end
    end
    
    def stubs
      @stubs
    end
    
    def debug=(val)
      @debug = val ? true : false
    end
    
    def debug?
      @debug
    end
  end
end
