# frozen_string_literal: true

require 'yaml'
require 'compliance_engine'
require 'compliance_engine/data_loader'

def topdir
  return @topdir if @topdir

  fullpath = File.expand_path(__dir__).split(File::SEPARATOR)

  fullpath.map.with_index { |_p, i| File.join(fullpath[0..i]) }.reverse_each do |dir|
    next if dir.empty?

    return @topdir = dir if File.exist?(File.join(dir, 'metadata.json'))
  end

  nil
end

def compliance_data
  @compliance_data ||= ComplianceEngine::Data.new(topdir)
end

def profiles
  compliance_data.profiles.select { |_, value| value.ces&.count&.positive? || value.controls&.count&.positive? }
end
