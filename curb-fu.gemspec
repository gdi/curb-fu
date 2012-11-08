# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'curb-fu/version'

Gem::Specification.new do |s|
  s.platform        = Gem::Platform::RUBY
  s.name            = "curb-fu"
  s.version         = CurbFu::VERSION
  s.author          = "Derek Kastner, Matt Wilson"
  s.email           = "development@greenviewdata.com"
  s.summary         = "Friendly wrapper for curb"
  s.has_rdoc        = false

  s.files           = `git ls-files`.split("\n")
  s.test_files      = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables     = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths   = ["lib"]

  s.add_dependency('curb',   '>= 0.5.4.0')
  s.add_dependency('rack-test',   '>= 0.2.0')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('htmlentities')
end
