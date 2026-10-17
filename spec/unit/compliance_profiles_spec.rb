# frozen_string_literal: true

require 'spec_helper'
require 'spec_helper_sce'
require 'fileutils'

def fixtures
  @fixtures ||= File.expand_path('../fixtures', __dir__)
end

def datadir
  return @datadir unless @datadir.nil?

  @datadir = File.join(fixtures, 'data')
  FileUtils.mkdir_p(@datadir)
  @datadir
end

def hiera_yaml
  return @hiera_yaml unless @hiera_yaml.nil?

  @hiera_yaml ||= File.join(fixtures, 'hiera.yaml')
  File.open(@hiera_yaml, 'w') do |fh|
    fh.puts <<~HIERA_YAML
      ---
      version: 5
      defaults:
        datadir: #{File.basename(datadir)}
        data_hash: yaml_data
      hierarchy:
        - name: Common
          path: common.yaml
        - name: 'Compliance Engine'
          lookup_key: compliance_engine::enforcement
    HIERA_YAML
  end
  @hiera_yaml
end

RSpec.configure do |c|
  c.hiera_config = hiera_yaml
end

describe 'sicura', type: :class do # rubocop:disable RSpec/DescribeClass
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do # rubocop:disable RSpec/ContextWording
      compliance_data.facts = os_facts.dup.transform_keys(&:to_s)
      profiles.each_key do |profile|
        context "with compliance profile #{profile}" do
          before do
            File.open(File.join(datadir, 'common.yaml'), 'w') do |fh|
              fh.puts <<~COMMON_YAML
                ---
                compliance_engine::enforcement:
                  - "%{facts.test_profile}"
              COMMON_YAML
            end
          end

          let(:facts) { os_facts.merge(test_profile: profile) }

          let(:hiera_config) { hiera_yaml }

          let(:pre_condition) do
            <<~MANIFEST
              include 'sicura'
            MANIFEST
          end

          it { is_expected.to compile }
        end
      end
    end
  end
end
