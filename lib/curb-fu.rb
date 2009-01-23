dir = File.dirname(__FILE__)
$:.unshift(dir) unless $:.include?(dir)
require 'curb-fu/response'
require 'curb-fu/request'

module CurbFu; end