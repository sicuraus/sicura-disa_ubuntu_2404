# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker(modules: :fixtures) do |host|
  # Copy the module under test to the node
  # Works around limitations in puppet-modulebuilder
  target = File.join(
    host.puppet_configprint['modulepath'].split(':').first,
    JSON.parse(File.read('metadata.json'))['name'].split(%r{[-/]}).last,
  )

  # This block runs before any modules are installed, so the modulepath may
  # not exist yet, and rsync will not create missing parent directories.
  on(host, "mkdir -p #{target}")

  rsync_to(host, '.', File.join(target, '.'))
end
