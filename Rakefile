require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--exclude-pattern \'spec/**/*suite_spec.rb\''
end

task default: :spec

require "yard"
YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/oslg/oslog.rb"]
end
