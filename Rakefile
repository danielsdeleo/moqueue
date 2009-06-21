require "spec/rake/spectask"

task :default => :spec

desc "Run all of the specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"spec/spec.opts\""]
  t.fail_on_error = false
end

