# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAvalanche
      module Runners
        module CognitiveAvalanche
          extend self

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_snowpack(snowpack_type: nil, domain: nil, content: nil,
                              depth: 0.0, stability: 1.0, engine: nil, **)
            raise ArgumentError, 'snowpack_type is required' if snowpack_type.nil?
            raise ArgumentError, 'domain is required'        if domain.nil?
            raise ArgumentError, 'content is required'       if content.nil?

            avalanche_engine(engine).create_snowpack(
              snowpack_type: snowpack_type,
              domain:        domain,
              content:       content,
              depth:         depth,
              stability:     stability
            )
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def trigger(snowpack_id: nil, force: 0.5, cascade_type: :chaotic, engine: nil, **)
            raise ArgumentError, 'snowpack_id is required' if snowpack_id.nil?

            avalanche_engine(engine).trigger(
              snowpack_id:  snowpack_id,
              force:        force,
              cascade_type: cascade_type
            )
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def accumulate(rate: Helpers::Constants::ACCUMULATION_RATE, engine: nil, **)
            avalanche_engine(engine).accumulate_all!(rate: rate)
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def list_snowpacks(engine: nil, **)
            eng   = avalanche_engine(engine)
            packs = eng.snowpacks.values.map(&:to_h)
            { success: true, snowpacks: packs, count: packs.size }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def terrain_status(engine: nil, **)
            report = avalanche_engine(engine).terrain_report
            { success: true }.merge(report)
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          private

          def avalanche_engine(engine)
            engine || @avalanche_engine ||= Helpers::AvalancheEngine.new
          end
        end
      end
    end
  end
end
