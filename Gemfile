# frozen_string_literal: true

source ENV.fetch('GEM_SOURCE', 'https://rubygems.org')

group :development do
  gem 'pry-byebug', '~> 3.12.0', require: false
end

group :syntax do
  gem 'scelint', '~> 0.4.0', require: false
  gem 'voxpupuli-rubocop', '~> 1.3.0', require: false
end

group :test do
  gem 'compliance_engine', '~> 0.2.0', require: false
  gem 'puppet_metadata', '~> 6.0.0', require: false
  gem 'voxpupuli-test', '~> 13.2.0', require: false
end

group :system_tests do
  gem 'voxpupuli-acceptance', '~> 4.3.0', require: false
end

gem 'openvox', ENV.fetch('OPENVOX_VERSION', '~> 8.19'), require: false
