# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{moqueue}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel DeLeo"]
  s.date = %q{2011-02-05}
  s.description = %q{Mocktacular Companion to AMQP Library. Happy TATFTing!}
  s.email = %q{dan@kallistec.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "CONTRIBUTORS.rdoc",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/moqueue.rb",
    "lib/moqueue/fibers18.rb",
    "lib/moqueue/matchers.rb",
    "lib/moqueue/mock_broker.rb",
    "lib/moqueue/mock_exchange.rb",
    "lib/moqueue/mock_headers.rb",
    "lib/moqueue/mock_queue.rb",
    "lib/moqueue/object_methods.rb",
    "lib/moqueue/overloads.rb",
    "moqueue.gemspec",
    "spec/examples/ack_spec.rb",
    "spec/examples/basic_usage_spec.rb",
    "spec/examples/example_helper.rb",
    "spec/examples/logger_spec.rb",
    "spec/examples/ping_pong_spec.rb",
    "spec/examples/stocks_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/unit/matchers_spec.rb",
    "spec/unit/mock_broker_spec.rb",
    "spec/unit/mock_exchange_spec.rb",
    "spec/unit/mock_headers_spec.rb",
    "spec/unit/mock_queue_spec.rb",
    "spec/unit/moqueue_spec.rb",
    "spec/unit/object_methods_spec.rb",
    "spec/unit/overloads_spec.rb"
  ]
  s.homepage = %q{http://github.com/danielsdeleo/moqueue}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{moqueue}
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{Mocktacular Companion to AMQP Library. Happy TATFTing!}
  s.test_files = [
    "spec/examples/ack_spec.rb",
    "spec/examples/basic_usage_spec.rb",
    "spec/examples/example_helper.rb",
    "spec/examples/logger_spec.rb",
    "spec/examples/ping_pong_spec.rb",
    "spec/examples/stocks_spec.rb",
    "spec/spec_helper.rb",
    "spec/unit/matchers_spec.rb",
    "spec/unit/mock_broker_spec.rb",
    "spec/unit/mock_exchange_spec.rb",
    "spec/unit/mock_headers_spec.rb",
    "spec/unit/mock_queue_spec.rb",
    "spec/unit/moqueue_spec.rb",
    "spec/unit/object_methods_spec.rb",
    "spec/unit/overloads_spec.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<amqp>, [">= 0"])
    else
      s.add_dependency(%q<amqp>, [">= 0"])
    end
  else
    s.add_dependency(%q<amqp>, [">= 0"])
  end
end

