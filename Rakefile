# frozen_string_literal: true

begin
  require 'voxpupuli/test/rake'
rescue LoadError
  # Only available if gem group test is installed
end

begin
  require 'voxpupuli/acceptance/rake'
rescue LoadError
  # only available if gem group system_tests is installed
end

# The acceptance tests install the modules in spec/fixtures/modules, but
# `rake beaker` does not populate that directory on its own.
task beaker: 'fixtures:prep' if Rake::Task.task_defined?('beaker') && Rake::Task.task_defined?('fixtures:prep')
