dir = File.dirname(__FILE__)
$:.unshift(dir) unless $:.include?(dir)
require 'curb-fu/response'
require 'curb-fu/request'

module CurbFu
  def self.get(*args)
    CurbFu::Request.get(*args)
  end
  
  def self.post(*args)
    CurbFu::Request.post(*args)
  end
  
  def self.put(*args)
    CurbFu::Request.put(*args)
  end
  
  def self.delete(*args)
    CurbFu::Request.delete(*args)
  end
end