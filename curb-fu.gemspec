spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "curb-fu"
    s.version   =   "0.6.0"
    s.author    =   "Derek Kastner, Matt Wilson"
    s.email     =   "development@greenviewdata.com"
    s.summary   =   "Friendly wrapper for curb"
    s.files     =   Dir.glob('lib/**/*.rb')
    s.require_path  =   "lib"
    s.test_files = Dir.glob('spec/**/*') + Dir.glob('stories/**/*')
    s.has_rdoc  =   false
    s.add_dependency('curb',   '>= 0.5.4.0')
    s.add_dependency('rack-test',   '>= 0.2.0')
    
    s.add_development_dependency('rspec', '1.3.2')
    s.add_development_dependency('htmlentities')
end
