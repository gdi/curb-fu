require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

require 'spec'
require 'spec/rake/spectask'

Gem::manage_gems
spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "curb-fu"
    s.version   =   "0.0.2"
    s.author    =   "Phil Green, Derek Kastner, Matt Wilson"
    s.email     =   "support@greenviewdata.com"
    s.summary   =   "Friendly wrapper for curb"
    s.files     =   FileList['lib/**/*.rb', 'config/**/*'].to_a
    s.require_path  =   "lib"
    s.test_files = Dir.glob('spec/**/*') + Dir.glob('stories/**/*')
    s.has_rdoc  =   false
    s.add_dependency('curb',   '>= 0.1.4')
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end

Spec::Rake::SpecTask.new do |t|
  ENV["cluster_env"] ||= "test"
  t.warning = false
  t.spec_opts = ['--options', 'spec/spec.opts']
  unless ENV['NO_RCOV']
    t.spec_files = FileList['spec/**/*.rb']
    #t.rcov = true
    #t.rcov_opts = ['--exclude', 'rspec,spec,stories']
  end
end

namespace :gem do
  task :reset do
    system('rm -rf pkg/*.*')
    Rake::Task['gem'].invoke
    system('gem uninstall super_cluster')
    system("gem install #{`ls pkg/*.gem`}")
  end
end

#Rake::Task[:spec].enhance [:reset_memcached]

namespace :spec do
  desc "Run story runner"
  task :stories do
    require File.join('stories','all.rb')
  end
end
