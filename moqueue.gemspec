# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{moqueue}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel DeLeo"]
  s.date = %q{2009-07-09}
  s.description = %q{Mocktacular Companion to AMQP Library. Happy TATFTing!}
  s.email = %q{dan@kallistec.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["lib", "moqueue.gemspec", "Rakefile", "README.rdoc", "spec", "VERSION.yml", "lib/moqueue", "lib/moqueue/fibers18.rb", "lib/moqueue/matchers.rb", "lib/moqueue/mock_broker.rb", "lib/moqueue/mock_exchange.rb", "lib/moqueue/mock_headers.rb", "lib/moqueue/mock_queue.rb", "lib/moqueue/object_methods.rb", "lib/moqueue/overloads.rb", "lib/moqueue.rb", "spec/examples", "spec/examples/ack_spec.rb", "spec/examples/basic_usage_spec.rb", "spec/examples/example_helper.rb", "spec/examples/logger_spec.rb", "spec/examples/ping_pong_spec.rb", "spec/examples/stocks_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit", "spec/unit/matchers_spec.rb", "spec/unit/mock_broker_spec.rb", "spec/unit/mock_exchange_spec.rb", "spec/unit/mock_headers_spec.rb", "spec/unit/mock_queue_spec.rb", "spec/unit/moqueue_spec.rb", "spec/unit/object_methods_spec.rb", "spec/unit/overloads_spec.rb"]
  s.homepage = %q{http://github.com/danielsdeleo/moqueue}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Mocktacular Companion to AMQP Library. Happy TATFTing!}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
