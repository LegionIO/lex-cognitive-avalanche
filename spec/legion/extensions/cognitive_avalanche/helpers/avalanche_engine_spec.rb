# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAvalanche::Helpers::AvalancheEngine do
  subject(:engine) { described_class.new }

  let(:snowpack_id) do
    engine.create_snowpack(
      snowpack_type: :ideas,
      domain:        :creativity,
      content:       'divergent thinking spiral',
      stability:     0.3
    )[:snowpack_id]
  end

  let(:stable_snowpack_id) do
    engine.create_snowpack(
      snowpack_type: :memories,
      domain:        :identity,
      content:       'foundational self-concept',
      stability:     0.9
    )[:snowpack_id]
  end

  describe '#create_snowpack' do
    it 'creates a snowpack and returns success' do
      result = engine.create_snowpack(snowpack_type: :emotions, domain: :fear, content: 'anticipatory dread')
      expect(result[:success]).to be(true)
      expect(result[:snowpack_id]).not_to be_nil
    end

    it 'returns a snowpack hash in the result' do
      result = engine.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'x')
      expect(result[:snowpack]).to be_a(Hash)
      expect(result[:snowpack][:domain]).to eq(:test)
    end

    it 'stores the snowpack in @snowpacks' do
      result = engine.create_snowpack(snowpack_type: :impulses, domain: :action, content: 'do it now')
      expect(engine.snowpacks).to have_key(result[:snowpack_id])
    end

    it 'returns failure for invalid snowpack_type' do
      result = engine.create_snowpack(snowpack_type: :invalid, domain: :test, content: 'x')
      expect(result[:success]).to be(false)
      expect(result[:error]).to match(/unknown snowpack_type/)
    end

    it 'enforces MAX_SNOWPACKS limit' do
      100.times { |i| engine.create_snowpack(snowpack_type: :ideas, domain: :test, content: "x#{i}") }
      result = engine.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'overflow')
      expect(result[:success]).to be(false)
      expect(result[:error]).to match(/snowpack limit/)
    end

    it 'respects custom depth' do
      result = engine.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'x', depth: 0.5)
      expect(engine.snowpacks[result[:snowpack_id]].depth).to eq(0.5)
    end

    it 'respects custom stability' do
      result = engine.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.2)
      expect(engine.snowpacks[result[:snowpack_id]].stability).to eq(0.2)
    end
  end

  describe '#trigger' do
    it 'triggers a cascade when force + instability >= threshold' do
      result = engine.trigger(snowpack_id: snowpack_id, force: 0.5)
      expect(result[:success]).to be(true)
      expect(result[:triggered]).to be(true)
      expect(result[:cascade_id]).not_to be_nil
    end

    it 'returns no trigger when combined force+instability is below threshold' do
      result = engine.trigger(snowpack_id: stable_snowpack_id, force: 0.01)
      expect(result[:success]).to be(true)
      expect(result[:triggered]).to be(false)
    end

    it 'returns failure for unknown snowpack_id' do
      result = engine.trigger(snowpack_id: 'ghost-uuid', force: 0.5)
      expect(result[:success]).to be(false)
      expect(result[:error]).to match(/snowpack not found/)
    end

    it 'includes cascade hash in triggered result' do
      result = engine.trigger(snowpack_id: snowpack_id, force: 0.5)
      expect(result[:cascade]).to be_a(Hash)
      expect(result[:cascade][:cascade_type]).not_to be_nil
    end

    it 'accepts custom cascade_type' do
      result = engine.trigger(snowpack_id: snowpack_id, force: 0.5, cascade_type: :creative)
      expect(result[:cascade][:cascade_type]).to eq(:creative)
    end

    it 'records cascade in cascade_history' do
      engine.trigger(snowpack_id: snowpack_id, force: 0.5)
      expect(engine.cascade_history).not_to be_empty
    end

    it 'destabilizes the snowpack' do
      pack = engine.snowpacks[snowpack_id]
      before_stability = pack.stability
      engine.trigger(snowpack_id: snowpack_id, force: 0.2)
      expect(pack.stability).to be < before_stability
    end

    it 'adds snowpack content to cascade debris' do
      result = engine.trigger(snowpack_id: snowpack_id, force: 0.5)
      expect(result[:cascade][:debris]).to include('divergent thinking spiral')
    end

    it 'includes instability in result' do
      result = engine.trigger(snowpack_id: snowpack_id, force: 0.5)
      expect(result).to have_key(:instability)
    end
  end

  describe '#accumulate_all!' do
    before { snowpack_id && stable_snowpack_id }

    it 'returns success' do
      result = engine.accumulate_all!
      expect(result[:success]).to be(true)
    end

    it 'reports packs_accumulated count' do
      result = engine.accumulate_all!
      expect(result[:packs_accumulated]).to eq(2)
    end

    it 'increases depth of all snowpacks' do
      packs = engine.snowpacks.values
      before_depths = packs.map(&:depth)
      engine.accumulate_all!
      packs.each_with_index do |pack, i|
        expect(pack.depth).to be >= before_depths[i]
      end
    end

    it 'uses custom rate when provided' do
      result = engine.accumulate_all!(rate: 0.1)
      expect(result[:rate]).to eq(0.1)
    end
  end

  describe '#melt_all!' do
    before do
      engine.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'x', depth: 0.5)
      engine.create_snowpack(snowpack_type: :emotions, domain: :test, content: 'y', depth: 0.5)
    end

    it 'returns success' do
      result = engine.melt_all!
      expect(result[:success]).to be(true)
    end

    it 'reports packs_melted count' do
      result = engine.melt_all!
      expect(result[:packs_melted]).to eq(2)
    end

    it 'decreases depth of all snowpacks' do
      packs  = engine.snowpacks.values
      before = packs.map(&:depth)
      engine.melt_all!
      packs.each_with_index do |pack, i|
        expect(pack.depth).to be <= before[i]
      end
    end
  end

  describe '#active_cascades' do
    it 'returns empty array with no history' do
      expect(engine.active_cascades).to eq([])
    end

    it 'returns only active cascades' do
      engine.trigger(snowpack_id: snowpack_id, force: 0.5)
      expect(engine.active_cascades).not_to be_empty
    end
  end

  describe '#most_unstable' do
    it 'returns nil when no snowpacks exist' do
      expect(engine.most_unstable).to be_nil
    end

    it 'returns the snowpack with lowest stability' do
      snowpack_id
      stable_snowpack_id
      expect(engine.most_unstable.id).to eq(snowpack_id)
    end
  end

  describe '#terrain_report' do
    before { snowpack_id && stable_snowpack_id }

    it 'includes total_snowpacks' do
      report = engine.terrain_report
      expect(report[:total_snowpacks]).to eq(2)
    end

    it 'includes critical_count' do
      report = engine.terrain_report
      expect(report).to have_key(:critical_count)
    end

    it 'includes unstable_count' do
      report = engine.terrain_report
      expect(report).to have_key(:unstable_count)
    end

    it 'includes stable_count' do
      report = engine.terrain_report
      expect(report).to have_key(:stable_count)
    end

    it 'includes active_cascades count' do
      report = engine.terrain_report
      expect(report).to have_key(:active_cascades)
    end

    it 'includes cascade_history count' do
      engine.trigger(snowpack_id: snowpack_id, force: 0.5)
      report = engine.terrain_report
      expect(report[:cascade_history]).to be >= 1
    end

    it 'includes avg_stability' do
      report = engine.terrain_report
      expect(report[:avg_stability]).to be_a(Float)
    end

    it 'includes avg_depth' do
      report = engine.terrain_report
      expect(report[:avg_depth]).to be_a(Float)
    end

    it 'includes most_unstable_id' do
      report = engine.terrain_report
      expect(report[:most_unstable_id]).to eq(snowpack_id)
    end

    it 'includes recent_cascades array' do
      report = engine.terrain_report
      expect(report[:recent_cascades]).to be_an(Array)
    end

    it 'caps recent_cascades at 5' do
      10.times { engine.trigger(snowpack_id: snowpack_id, force: 0.5) }
      report = engine.terrain_report
      expect(report[:recent_cascades].size).to be <= 5
    end
  end

  describe 'cascade_history cap' do
    it 'caps cascade_history at MAX_CASCADE_HISTORY' do
      pack_id = engine.create_snowpack(
        snowpack_type: :impulses, domain: :stress, content: 'persistent trigger', stability: 0.0
      )[:snowpack_id]

      510.times do
        engine.send(:record_cascade,
                    Legion::Extensions::CognitiveAvalanche::Helpers::Cascade.new(
                      cascade_type:   :chaotic,
                      trigger_source: pack_id,
                      magnitude:      0.5
                    ))
      end

      expect(engine.cascade_history.size).to eq(500)
    end
  end
end
