# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

# Installs everything in spec/fixtures/modules, including this module.
configure_beaker(modules: :fixtures) do |host|
  # puppet-modulebuilder only packages the standard module directories, so the
  # compliance data in SIMP/ is missing from the installed copy of this module.
  # This block runs after the fixtures are installed.
  moduledir = File.join(
    host.puppet_configprint['modulepath'].split(':').first,
    JSON.parse(File.read('metadata.json'))['name'].split(%r{[-/]}).last,
  )
  on(host, "mkdir -p #{moduledir}")
  scp_to(host, 'SIMP', moduledir)
end
