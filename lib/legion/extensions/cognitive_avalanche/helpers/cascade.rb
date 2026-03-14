# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveAvalanche
      module Helpers
        class Cascade
          include Constants

          attr_reader :id, :cascade_type, :trigger_source, :started_at
          attr_accessor :magnitude, :propagation_speed, :debris

          def initialize(cascade_type:, trigger_source:, magnitude:, propagation_speed: 0.5, debris: [], **)
            raise ArgumentError, "unknown cascade_type: #{cascade_type}" unless Constants::CASCADE_TYPES.include?(cascade_type)

            @id                = SecureRandom.uuid
            @cascade_type      = cascade_type
            @trigger_source    = trigger_source
            @magnitude         = magnitude.clamp(0.0, 1.0)
            @propagation_speed = propagation_speed.clamp(0.0, 1.0)
            @debris            = Array(debris).dup
            @active            = true
            @started_at        = Time.now.utc
          end

          def propagate!(rate = 0.1)
            return unless @active

            @magnitude = (@magnitude + rate.abs).clamp(0.0, 1.0).round(10)
          end

          def dissipate!(rate = 0.08)
            @magnitude = (@magnitude - rate.abs).clamp(0.0, 1.0).round(10)
            @active    = false if @magnitude <= 0.0
          end

          def active?
            @active && @magnitude > 0.0
          end

          def spent?
            !@active || @magnitude <= 0.0
          end

          def magnitude_label
            Constants.label_for(:MAGNITUDE_LABELS, @magnitude)
          end

          def add_debris(item)
            @debris << item
          end

          def to_h
            {
              id:                @id,
              cascade_type:      @cascade_type,
              trigger_source:    @trigger_source,
              magnitude:         @magnitude,
              magnitude_label:   magnitude_label,
              propagation_speed: @propagation_speed,
              debris:            @debris.dup,
              active:            @active,
              started_at:        @started_at
            }
          end
        end
      end
    end
  end
end
