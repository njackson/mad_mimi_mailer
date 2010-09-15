require 'bundler'
Bundler.setup

require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mad_mimi_mailer"
    gem.summary = %Q{Rails3 ActionMailer delivery method for Mad Mimi}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "nate.d.jackson@gmail.com"
    gem.homepage = "http://github.com/njackson/mad_mimi_mailer"
    gem.authors = ["Nate Jackson"]
    gem.add_development_dependency "rspec", ">= 2.0.0.beta.20"
    gem.add_bundler_dependencies
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov => :cleanup_rcov_files) do |spec|
  spec.rcov = true
  spec.rcov_opts =  %[-Ilib -Ispec --exclude "spec/spec_helper.rb"]
  spec.rcov_opts << %[--no-html --aggregate coverage.data]
end

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

task :clobber do
  rm_rf 'pkg'
  rm_rf 'tmp'
  rm_rf 'coverage'
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mad_mimi_mailer #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
