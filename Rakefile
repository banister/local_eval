dlext = Config::CONFIG['DLEXT']
direc = File.dirname(__FILE__)

require 'rake/clean'
require 'rake/gempackagetask'
require "#{direc}/lib/local_eval/version"


CLEAN.include("ext/**/*.#{dlext}", "ext/**/*.log", "ext/**/*.o", "ext/**/*~", "ext/**/*#*", "ext/**/*.obj", "ext/**/*.def", "ext/**/*.pdb")
CLOBBER.include("**/*.#{dlext}", "**/*~", "**/*#*", "**/*.log", "**/*.o")

def apply_spec_defaults(s)
  s.name = "local_eval"
  s.summary = "instance_eval without changing self"
  s.version = LocalEval::VERSION
  s.date = Time.now.strftime '%Y-%m-%d'
  s.author = "John Mair (banisterfiend)"
  s.email = 'jrmair@gmail.com'
  s.description = s.summary
  s.require_path = 'lib'
  s.add_dependency("remix",">=0.4.6")
  s.add_dependency("object2module",">=0.4.3")
  s.homepage = "http://banisterfiend.wordpress.com"
  s.has_rdoc = 'yard'
  s.files = FileList["ext/**/extconf.rb", "ext/**/*.h", "ext/**/*.c", "lib/**/*.rb",
                     "test/*.rb", "CHANGELOG", "README.markdown", "Rakefile"].to_a
end

task :test do
  sh "bacon -k #{direc}/test/test.rb"
end

namespace :ruby do
  spec = Gem::Specification.new do |s|
    apply_spec_defaults(s)        
    s.platform = Gem::Platform::RUBY
  end
  
  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = false
    pkg.need_tar = false
  end
end

task :compile do
  build_for = proc do |pik_ver, ver|
    sh %{ \
          pik #{pik_ver} && \
          ruby extconf.rb && \
          make clean && \
          make && \
          cp *.so #{direc}/lib/#{ver} \
        }
  end
  
  chdir("#{direc}/ext/remix") do
    build_for.call("187", "1.8")
    build_for.call("default", "1.9")
  end
end

desc "build all platform gems at once"
task :gem => [:rmgems, "ruby:gem"]

desc "remove all platform gems"
task :rmgems => ["ruby:clobber_package"]

desc "build and push latest gems"
task :pushgems => :gems do
  chdir("#{direc}/pkg") do
    Dir["*.gem"].each do |gemfile|
      sh "gem push #{gemfile}"
    end
  end
end



