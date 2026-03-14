# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAvalanche
      class Client
        include Runners::CognitiveAvalanche

        attr_reader :engine

        def initialize(engine: nil, **)
          @engine           = engine || Helpers::AvalancheEngine.new
          @avalanche_engine = @engine
        end
      end
    end
  end
end
