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
    fh.puts <<~END
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
    END
  end
  @hiera_yaml
end

RSpec.configure do |c|
  c.hiera_config = hiera_yaml
end

describe 'sicura', type: :class do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      compliance_data.facts = os_facts.dup.transform_keys(&:to_s)
      profiles.each_key do |profile|
        context "with compliance profile #{profile}" do
          before(:each) do
            File.open(File.join(datadir, 'common.yaml'), 'w') do |fh|
              fh.puts <<~END
                ---
                compliance_engine::enforcement:
                  - "%{facts.test_profile}"
              END
            end
          end

          let(:facts) { os_facts }

          let(:hiera_config) { hiera_yaml }

          let(:pre_condition) do
            <<~END
              include 'sicura'
            END
          end

          it { is_expected.to compile }
        end
      end
    end
  end
end
