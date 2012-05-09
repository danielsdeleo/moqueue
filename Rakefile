# encoding: utf-8

require 'rubygems'
require "spec/rake/spectask"
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'jeweler'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "moqueue"
    gem.homepage    = "https://github.com/customink/moqueue"
    gem.license     = "MIT"
    gem.summary     = "Mocktacular Companion to AMQP Library. Happy TATFTing!"
    gem.description = gem.summary
    gem.email       = ["dan@kallistec.com"]
    gem.authors     = ["Daniel DeLeo"]
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

task :default => :spec

desc "Run all of the specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.fail_on_error = false
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "shipping_helper #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end