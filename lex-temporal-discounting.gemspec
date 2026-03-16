# frozen_string_literal: true

require_relative 'lib/legion/extensions/temporal_discounting/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-temporal-discounting'
  spec.version       = Legion::Extensions::TemporalDiscounting::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Temporal Discounting'
  spec.description   = 'Hyperbolic temporal discounting model for brain-modeled agentic AI planning and impulse control'
  spec.homepage      = 'https://github.com/LegionIO/lex-temporal-discounting'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-temporal-discounting'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-temporal-discounting'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-temporal-discounting'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-temporal-discounting/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-temporal-discounting.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
