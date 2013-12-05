require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc "validate the gemspec"
task :gemspec do
  gemspec.validate
end

task :default => :spec