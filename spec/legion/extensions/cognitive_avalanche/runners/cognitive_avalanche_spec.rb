# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAvalanche::Runners::CognitiveAvalanche do
  let(:engine) { Legion::Extensions::CognitiveAvalanche::Helpers::AvalancheEngine.new }
  let(:runner) { Object.new.extend(described_module) }

  def described_module
    Legion::Extensions::CognitiveAvalanche::Runners::CognitiveAvalanche
  end

  let(:unstable_snowpack_id) do
    engine.create_snowpack(
      snowpack_type: :ideas,
      domain:        :creativity,
      content:       'cascading concept',
      stability:     0.1
    )[:snowpack_id]
  end

  let(:stable_snowpack_id) do
    engine.create_snowpack(
      snowpack_type: :memories,
      domain:        :identity,
      content:       'core belief',
      stability:     0.95
    )[:snowpack_id]
  end

  describe '#create_snowpack' do
    it 'creates a snowpack with valid params' do
      result = runner.create_snowpack(snowpack_type: :emotions, domain: :fear, content: 'baseline anxiety', engine: engine)
      expect(result[:success]).to be(true)
      expect(result[:snowpack_id]).not_to be_nil
    end

    it 'returns failure when snowpack_type is missing' do
      result = runner.create_snowpack(domain: :test, content: 'x', engine: engine)
      expect(result[:success]).to be(false)
      expect(result[:error]).to match(/snowpack_type/)
    end

    it 'returns failure when domain is missing' do
      result = runner.create_snowpack(snowpack_type: :ideas, content: 'x', engine: engine)
      expect(result[:success]).to be(false)
      expect(result[:error]).to match(/domain/)
    end

    it 'returns failure when content is missing' do
      result = runner.create_snowpack(snowpack_type: :ideas, domain: :test, engine: engine)
      expect(result[:success]).to be(false)
      expect(result[:error]).to match(/content/)
    end

    it 'passes depth to engine' do
      result = runner.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'x', depth: 0.4, engine: engine)
      expect(engine.snowpacks[result[:snowpack_id]].depth).to eq(0.4)
    end

    it 'passes stability to engine' do
      result = runner.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.3, engine: engine)
      expect(engine.snowpacks[result[:snowpack_id]].stability).to eq(0.3)
    end

    it 'accepts extra kwargs without error' do
      result = runner.create_snowpack(
        snowpack_type: :impulses, domain: :test, content: 'x', engine: engine, irrelevant: true
      )
      expect(result[:success]).to be(true)
    end
  end

  describe '#trigger' do
    before { unstable_snowpack_id && stable_snowpack_id }

    it 'triggers a cascade for an unstable snowpack' do
      result = runner.trigger(snowpack_id: unstable_snowpack_id, force: 0.5, engine: engine)
      expect(result[:success]).to be(true)
      expect(result[:triggered]).to be(true)
    end

    it 'returns no trigger for stable snowpack with low force' do
      result = runner.trigger(snowpack_id: stable_snowpack_id, force: 0.01, engine: engine)
      expect(result[:success]).to be(true)
      expect(result[:triggered]).to be(false)
    end

    it 'returns failure when snowpack_id is missing' do
      result = runner.trigger(force: 0.5, engine: engine)
      expect(result[:success]).to be(false)
      expect(result[:error]).to match(/snowpack_id/)
    end

    it 'returns failure for unknown snowpack_id' do
      result = runner.trigger(snowpack_id: 'ghost', force: 0.5, engine: engine)
      expect(result[:success]).to be(false)
    end

    it 'defaults force to 0.5' do
      result = runner.trigger(snowpack_id: unstable_snowpack_id, engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'accepts custom cascade_type' do
      result = runner.trigger(
        snowpack_id: unstable_snowpack_id, force: 0.5,
        cascade_type: :analytical, engine: engine
      )
      expect(result[:cascade][:cascade_type]).to eq(:analytical) if result[:triggered]
    end

    it 'accepts extra kwargs without error' do
      result = runner.trigger(snowpack_id: unstable_snowpack_id, force: 0.5, engine: engine, trace: 'debug')
      expect(result[:success]).to be(true)
    end
  end

  describe '#accumulate' do
    before { unstable_snowpack_id }

    it 'returns success' do
      result = runner.accumulate(engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'reports packs_accumulated' do
      result = runner.accumulate(engine: engine)
      expect(result[:packs_accumulated]).to eq(1)
    end

    it 'accepts custom rate' do
      result = runner.accumulate(rate: 0.1, engine: engine)
      expect(result[:rate]).to eq(0.1)
    end

    it 'uses default ACCUMULATION_RATE when not specified' do
      result = runner.accumulate(engine: engine)
      expect(result[:rate]).to eq(Legion::Extensions::CognitiveAvalanche::Helpers::Constants::ACCUMULATION_RATE)
    end
  end

  describe '#list_snowpacks' do
    before { unstable_snowpack_id && stable_snowpack_id }

    it 'returns success' do
      result = runner.list_snowpacks(engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'includes snowpacks array' do
      result = runner.list_snowpacks(engine: engine)
      expect(result[:snowpacks]).to be_an(Array)
      expect(result[:snowpacks].size).to eq(2)
    end

    it 'includes count' do
      result = runner.list_snowpacks(engine: engine)
      expect(result[:count]).to eq(2)
    end

    it 'returns hash representations of snowpacks' do
      result = runner.list_snowpacks(engine: engine)
      expect(result[:snowpacks].first).to have_key(:id)
      expect(result[:snowpacks].first).to have_key(:stability)
    end

    it 'returns empty list when no snowpacks' do
      empty_engine = Legion::Extensions::CognitiveAvalanche::Helpers::AvalancheEngine.new
      result = runner.list_snowpacks(engine: empty_engine)
      expect(result[:count]).to eq(0)
    end
  end

  describe '#terrain_status' do
    before { unstable_snowpack_id && stable_snowpack_id }

    it 'returns success' do
      result = runner.terrain_status(engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'includes total_snowpacks' do
      result = runner.terrain_status(engine: engine)
      expect(result[:total_snowpacks]).to eq(2)
    end

    it 'includes cascade_history' do
      runner.trigger(snowpack_id: unstable_snowpack_id, force: 0.5, engine: engine)
      result = runner.terrain_status(engine: engine)
      expect(result[:cascade_history]).to be >= 1
    end

    it 'includes avg_stability' do
      result = runner.terrain_status(engine: engine)
      expect(result[:avg_stability]).to be_a(Float)
    end

    it 'includes most_unstable_id' do
      result = runner.terrain_status(engine: engine)
      expect(result[:most_unstable_id]).to eq(unstable_snowpack_id)
    end
  end

  describe 'default engine isolation' do
    it 'each runner instance has its own default engine' do
      r1 = Object.new.extend(described_module)
      r2 = Object.new.extend(described_module)
      r1.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'isolated')
      expect(r2.terrain_status[:total_snowpacks]).to eq(0)
    end
  end
end
