# frozen_string_literal: true

source ENV.fetch('GEM_SOURCE', 'https://rubygems.org')

group :development do
  gem 'pry-byebug', '~> 3.12', require: false
end

group :syntax do
  gem 'scelint', '~> 0.6.1', require: false
  gem 'voxpupuli-rubocop', '~> 5.3', require: false
end

# Used by both the unit and acceptance tests (spec/spec_helper_sce.rb)
group :test, :system_tests do
  gem 'compliance_engine', '~> 1.1', require: false
end

group :test do
  gem 'puppet_metadata', '~> 6.4', require: false
  gem 'voxpupuli-test', '~> 15.0', require: false

  # facterdb needs jgrep, and jgrep < 1.6 (the last that supports Ruby < 3.3)
  # calls JSON.create_id=, which json 3 removed.
  gem 'json', '< 3', require: false if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.3')
end

group :system_tests do
  gem 'voxpupuli-acceptance', '~> 4.4', require: false
end

# CI sets OPENVOX_GEM_VERSION. Otherwise, match the Ruby version that each
# OpenVox release ships with (Ruby 3.2 for OpenVox 8, Ruby 4.0 for OpenVox 9).
openvox_version = ENV.fetch('OPENVOX_GEM_VERSION') { RUBY_VERSION.start_with?('3.') ? '~> 8.19' : '~> 9.0' }
gem 'openvox', openvox_version, require: false
