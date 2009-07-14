spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "curb-fu"
    s.version   =   "0.3.0"
    s.author    =   "Phil Green, Derek Kastner, Matt Wilson"
    s.email     =   "support@greenviewdata.com"
    s.summary   =   "Friendly wrapper for curb"
    s.files     =   Dir.glob('lib/**/*.rb')
    s.require_path  =   "lib"
    s.test_files = Dir.glob('spec/**/*') + Dir.glob('stories/**/*')
    s.has_rdoc  =   false
    s.add_dependency('taf2-curb',   '>= 0.2.8.0')
    s.add_dependency('rack-test',   '>= 0.2.0')
end
