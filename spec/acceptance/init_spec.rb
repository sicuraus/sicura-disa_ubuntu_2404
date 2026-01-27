# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'spec_helper_sce'
require 'json'

describe 'sicura' do
  let(:hiera_yaml) do
    <<~END
      ---
      version: 5
      hierarchy:
        - name: Common
          path: common.yaml
        - name: 'Compliance Engine'
          lookup_key: compliance_engine::enforcement
    END
  end

  hosts.each do |host|
    compliance_data.facts = JSON.parse(on(host, 'facter --json').stdout)
    profiles.each_key do |profile|
      context "with compliance profile #{profile}" do
        let(:hieradata) do
          <<~END
            ---
            compliance_engine::enforcement:
              - #{profile}
          END
        end

        before(:each) do
          # FIXME: These helper methods are available in simp-beaker-helpers,
          # but they do not work on Ubuntu hosts.
          # set_hiera_config_on(host, hiera_yaml)
          # set_hieradata_on(host, hieradata)
          create_remote_file(host, '/etc/puppetlabs/code/environments/production/hiera.yaml', hiera_yaml)
          create_remote_file(host, '/etc/puppetlabs/code/environments/production/data/common.yaml', hieradata)
        end

        it_behaves_like 'an idempotent resource' do
          let(:manifest) { 'include sicura' }
        end
      end
    end
  end
end
