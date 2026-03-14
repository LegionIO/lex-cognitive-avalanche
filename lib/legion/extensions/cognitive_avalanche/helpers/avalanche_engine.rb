# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAvalanche
      module Helpers
        class AvalancheEngine
          include Constants

          attr_reader :snowpacks, :cascade_history

          def initialize
            @snowpacks       = {}
            @cascade_history = []
          end

          def create_snowpack(snowpack_type:, domain:, content:, depth: 0.0, stability: 1.0, **)
            raise ArgumentError, 'snowpack limit reached' if @snowpacks.size >= Constants::MAX_SNOWPACKS

            pack = Snowpack.new(
              snowpack_type: snowpack_type,
              domain:        domain,
              content:       content,
              depth:         depth,
              stability:     stability
            )
            @snowpacks[pack.id] = pack
            { success: true, snowpack_id: pack.id, snowpack: pack.to_h }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def trigger(snowpack_id:, force:, cascade_type: :chaotic, **)
            pack = @snowpacks[snowpack_id]
            raise ArgumentError, "snowpack not found: #{snowpack_id}" unless pack

            pack.destabilize!(force)
            instability = pack.instability

            return { success: true, triggered: false, instability: instability, reason: :below_threshold } \
              if (force + instability) < Constants::TRIGGER_THRESHOLD

            cascade = Cascade.new(
              cascade_type:      cascade_type,
              trigger_source:    snowpack_id,
              magnitude:         ((force + instability) / 2.0).clamp(0.0, 1.0).round(10),
              propagation_speed: instability.round(10),
              debris:            [pack.content]
            )
            record_cascade(cascade)
            { success: true, triggered: true, cascade_id: cascade.id, cascade: cascade.to_h, instability: instability }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def accumulate_all!(rate: Constants::ACCUMULATION_RATE, **)
            count = 0
            @snowpacks.each_value do |pack|
              pack.accumulate!(rate)
              count += 1
            end
            { success: true, packs_accumulated: count, rate: rate }
          end

          def melt_all!(rate: Constants::MELT_RATE, **)
            count = 0
            @snowpacks.each_value do |pack|
              pack.melt!(rate)
              count += 1
            end
            { success: true, packs_melted: count, rate: rate }
          end

          def active_cascades
            @cascade_history.select(&:active?)
          end

          def most_unstable
            @snowpacks.values.min_by(&:stability)
          end

          def terrain_report
            packs           = @snowpacks.values
            active_cascades = self.active_cascades
            critical_packs  = packs.select(&:critical?)
            unstable_packs  = packs.select(&:unstable?)

            {
              total_snowpacks:  packs.size,
              critical_count:   critical_packs.size,
              unstable_count:   unstable_packs.size,
              stable_count:     packs.count(&:stable?),
              active_cascades:  active_cascades.size,
              cascade_history:  @cascade_history.size,
              avg_stability:    avg_stability(packs),
              avg_depth:        avg_depth(packs),
              most_unstable_id: most_unstable&.id,
              recent_cascades:  recent_cascades(5)
            }
          end

          private

          def record_cascade(cascade)
            @cascade_history << cascade
            @cascade_history.shift if @cascade_history.size > Constants::MAX_CASCADE_HISTORY
          end

          def avg_stability(packs)
            return 0.0 if packs.empty?

            (packs.sum(&:stability) / packs.size.to_f).round(10)
          end

          def avg_depth(packs)
            return 0.0 if packs.empty?

            (packs.sum(&:depth) / packs.size.to_f).round(10)
          end

          def recent_cascades(count)
            @cascade_history.last(count).map(&:to_h)
          end
        end
      end
    end
  end
end
