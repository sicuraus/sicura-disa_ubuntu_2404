# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker(modules: :fixtures) do |host|
  # Copy the module under test to the node
  # Works around limitations in puppet-modulebuilder
  rsync_to(
    host,
    '.',
    File.join(
      host.puppet_configprint['modulepath'].split(':').first,
      JSON.parse(File.read('metadata.json'))['name'].split(%r{[-/]}).last,
      '.',
    ),
  )
end
