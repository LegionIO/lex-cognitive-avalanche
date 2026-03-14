# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAvalanche
      module Helpers
        module Constants
          MAX_SNOWPACKS      = 100
          MAX_CASCADE_HISTORY = 500
          TRIGGER_THRESHOLD  = 0.75
          ACCUMULATION_RATE  = 0.06
          MELT_RATE          = 0.02

          SNOWPACK_TYPES = %i[ideas emotions memories associations impulses].freeze
          CASCADE_TYPES  = %i[creative emotional analytical chaotic convergent].freeze

          STABILITY_LABELS = {
            (0.0...0.2) => :catastrophic,
            (0.2...0.4) => :critical,
            (0.4...0.6) => :unstable,
            (0.6...0.8) => :moderate,
            (0.8..1.0)  => :bedrock
          }.freeze

          MAGNITUDE_LABELS = {
            (0.0...0.2) => :minor,
            (0.2...0.4) => :moderate,
            (0.4...0.6) => :significant,
            (0.6...0.8) => :major,
            (0.8..1.0)  => :devastating
          }.freeze

          def self.label_for(table, value)
            const_get(table).find { |range, _| range.cover?(value.clamp(0.0, 1.0)) }&.last || :unknown
          end
        end
      end
    end
  end
end
