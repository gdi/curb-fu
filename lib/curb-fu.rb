dir = File.dirname(__FILE__)
$:.unshift(dir) unless $:.include?(dir)
require 'curb-fu/response'
require 'curb-fu/request'
require 'curb-fu/authentication'
require 'curb-fu/core_ext'

module CurbFu
  class << self
    def get(*args, &block)
      CurbFu::Request.get(*args, &block)
    end

    def post(*args, &block)
      CurbFu::Request.post(*args, &block)
    end

    def put(*args, &block)
      CurbFu::Request.put(*args, &block)
    end

    def delete(*args, &block)
      CurbFu::Request.delete(*args, &block)
    end
  
    attr_accessor :stubs
    
    def stubs=(val)
      if val
        @stubs = {}
        val.each do |hostname, rack_app|
          stub(hostname, rack_app)
        end
      
        unless CurbFu::Request.include?(CurbFu::Request::Test)
          CurbFu::Request.send(:include, CurbFu::Request::Test)
        end
      else
        @stubs = nil
      end
    end

    def stub(hostname, rack_app)
      raise "You must use CurbFu.stubs= to define initial stubs before using stub()" if @stubs.nil?
      @stubs[hostname] = CurbFu::Request::Test::Interface.new(rack_app, hostname)
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
