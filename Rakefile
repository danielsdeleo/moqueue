require "spec/rake/spectask"
require "rake/rdoctask"

task :default => :spec

desc "Run all of the specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.fail_on_error = false
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "faqueue"
    s.summary = "Mocktacular Companion to AMQP Library. Happy TATFTing!"
    s.email = "dan@kallistec.com"
    s.homepage = "http://github.com/danielsdeleo/faqueue"
    s.description = "Mocktacular Companion to AMQP Library. Happy TATFTing!"
    s.authors = ["Daniel DeLeo"]
    s.files =  FileList["[A-Za-z]*", "{lib,spec}/**/*"]
    s.rubyforge_project = "faqueue"
    s.add_dependency("amqp")
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

# These are new tasks
begin
  require 'jeweler/rubyforge_tasks'
  require 'rake/contrib/sshpublisher'
  
  Jeweler::RubyforgeTasks.new
  
  namespace :rubyforge do

    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]

    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/faqueue/"
        local_dir = 'rdoc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end
