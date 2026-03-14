# frozen_string_literal: true

require 'securerandom'

require 'legion/extensions/cognitive_avalanche/version'
require 'legion/extensions/cognitive_avalanche/helpers/constants'
require 'legion/extensions/cognitive_avalanche/helpers/snowpack'
require 'legion/extensions/cognitive_avalanche/helpers/cascade'
require 'legion/extensions/cognitive_avalanche/helpers/avalanche_engine'
require 'legion/extensions/cognitive_avalanche/runners/cognitive_avalanche'
require 'legion/extensions/cognitive_avalanche/client'

module Legion
  module Extensions
    module CognitiveAvalanche
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
