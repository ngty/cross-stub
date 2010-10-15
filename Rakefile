require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.name = "cross-stub"
    gem.summary = %Q{Simple cross process stubbing}
    gem.description = %Q{}
    gem.email = "ngty77@gmail.com"
    gem.homepage = "http://github.com/ngty/cross-stub"
    gem.authors = ["NgTzeYang"]
    gem.add_development_dependency "bacon", ">= 0.0.0"
    gem.add_development_dependency "otaku", ">= 0.4.0"
    gem.add_dependency "ruby2ruby", ">= 1.2.5"
    gem.add_dependency "sexp_processor", ">= 3.0.5"
    gem.add_dependency "sourcify", ">= 0.4.0"
    gem.required_ruby_version = '>= 1.8.6'
    # TODO: How do we declare the following optional dependencies ??
    # 1. gem.add_dependency "memcache-client", "= 1.8.5"
    # 2. gem.add_dependency "redis", "= 2.0.3"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |spec|
    spec.libs << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :spec => :check_dependencies

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cross-stub #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
