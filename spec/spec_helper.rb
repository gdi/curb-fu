require "rubygems"
require 'spec'

dir = File.dirname(__FILE__)
lib_path = File.expand_path(File.join(dir,'..','lib'))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

Dir.glob(File.join(dir,'helpers','**','*')).each { |helper| require helper }

require 'curb-fu'