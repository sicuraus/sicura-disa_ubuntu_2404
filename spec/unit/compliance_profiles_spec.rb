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

# Recursively verify that every key/value pair in +expected+ is present in
# +actual+.  Extra keys in +actual+ are allowed at every nesting level.
def deep_subset?(expected, actual)
  return false unless actual.is_a?(Hash)

  expected.all? do |k, v|
    actual.key?(k) && (v.is_a?(Hash) ? deep_subset?(v, actual[k]) : actual[k] == v)
  end
end

# Hash parameters may have keys merged in from other data, so only the
# expected keys need to be present.
RSpec::Matchers.define :match_parameter do |expected|
  match { |actual| expected.is_a?(Hash) ? deep_subset?(expected, actual) : actual == expected }
end

RSpec.configure do |c|
  c.hiera_config = hiera_yaml
end

# Hiera keys whose values are class lists rather than class parameters
def class_parameters
  ['simp::classes', 'sicura::classes']
end

def required_classes(hiera)
  knockout(class_parameters.map { |key| Array(hiera[key]) }.reduce(:|))
end

describe 'sicura', type: :class do # rubocop:disable RSpec/DescribeClass
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do # rubocop:disable RSpec/ContextWording
      profiles.each_key do |profile|
        context "with compliance profile #{profile}" do
          # Used only to decide which examples to generate.
          compliance_data.facts = os_facts.merge(test_profile: profile).transform_keys(&:to_s)
          profile_hiera = compliance_data.hiera([profile])

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

          let(:compliance_hiera) do
            compliance_data.facts = facts.transform_keys(&:to_s)
            compliance_data.hiera([profile])
          end

          it { is_expected.to compile.with_all_deps }

          it 'has hiera data that loads classes' do
            expect(required_classes(compliance_hiera)).not_to be_empty
          end

          required_classes(profile_hiera).each do |klass|
            it { is_expected.to contain_class(klass) }
          end

          profile_hiera.except(*class_parameters).each_key do |key|
            it "sets #{key}" do
              classname, _, parameter = key.rpartition('::')
              actual = catalogue.resource('Class', classname)&.[](parameter.to_sym)
              expect(actual).to match_parameter(compliance_hiera[key])
            end
          end
        end
      end
    end
  end
end
