# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveAvalanche
      module Helpers
        class Snowpack
          include Constants

          attr_reader :id, :snowpack_type, :domain, :content, :created_at
          attr_accessor :depth, :stability

          def initialize(snowpack_type:, domain:, content:, depth: 0.0, stability: 1.0, **)
            raise ArgumentError, "unknown snowpack_type: #{snowpack_type}" unless Constants::SNOWPACK_TYPES.include?(snowpack_type)

            @id            = SecureRandom.uuid
            @snowpack_type = snowpack_type
            @domain        = domain
            @content       = content
            @depth         = depth.clamp(0.0, 1.0)
            @stability     = stability.clamp(0.0, 1.0)
            @created_at    = Time.now.utc
          end

          def accumulate!(rate = Constants::ACCUMULATION_RATE)
            @depth = (@depth + rate.abs).clamp(0.0, 1.0).round(10)
          end

          def compact!
            @stability = (@stability + 0.05).clamp(0.0, 1.0).round(10)
          end

          def destabilize!(force)
            @stability = (@stability - force.abs).clamp(0.0, 1.0).round(10)
          end

          def stable?
            @stability >= 0.6
          end

          def unstable?
            @stability < 0.4
          end

          def critical?
            @stability < 0.2
          end

          def stability_label
            Constants.label_for(:STABILITY_LABELS, @stability)
          end

          def instability
            (1.0 - @stability).round(10)
          end

          def to_h
            {
              id:            @id,
              snowpack_type: @snowpack_type,
              domain:        @domain,
              content:       @content,
              depth:         @depth,
              stability:     @stability,
              stable:        stable?,
              unstable:      unstable?,
              critical:      critical?,
              stability_label: stability_label,
              created_at:    @created_at
            }
          end
        end
      end
    end
  end
end
