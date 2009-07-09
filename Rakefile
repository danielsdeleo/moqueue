require "spec/rake/spectask"

task :default => :spec

desc "Run all of the specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.fail_on_error = false
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "moqueue"
    s.summary = "Mocktacular Companion to AMQP Library. Happy TATFTing!"
    s.email = "dan@kallistec.com"
    s.homepage = "http://github.com/danielsdeleo/moqueue"
    s.description = "Mocktacular Companion to AMQP Library. Happy TATFTing!"
    s.authors = ["Daniel DeLeo"]
    s.files =  FileList["[A-Za-z]*", "{lib,spec}/**/*"]
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

