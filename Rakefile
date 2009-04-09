require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'

require 'spec'
require 'spec/rake/spectask'

gemspec = nil
File.open(File.join(File.dirname(__FILE__), 'curb-fu.gemspec')) do |f|
  eval("gemspec = #{f.read}")
end

Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
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
    system('gem uninstall curb-fu')
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
