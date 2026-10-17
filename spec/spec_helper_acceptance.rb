# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

# Installs everything in spec/fixtures/modules, including this module.
configure_beaker(modules: :fixtures)
