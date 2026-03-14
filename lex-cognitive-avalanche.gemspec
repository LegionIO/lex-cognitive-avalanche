# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_avalanche/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-avalanche'
  spec.version       = Legion::Extensions::CognitiveAvalanche::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Avalanche'
  spec.description   = 'Cascading thought-chain model for LegionIO — snowpack stability, trigger events, ' \
                       'cascade propagation, and debris fields model how small perturbations become massive cognitive avalanches'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-avalanche'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-cognitive-avalanche'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-cognitive-avalanche'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-cognitive-avalanche'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-cognitive-avalanche/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
