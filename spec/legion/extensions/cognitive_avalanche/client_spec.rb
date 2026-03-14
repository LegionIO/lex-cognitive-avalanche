# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAvalanche::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates an AvalancheEngine by default' do
      expect(client.engine).to be_a(Legion::Extensions::CognitiveAvalanche::Helpers::AvalancheEngine)
    end

    it 'accepts an injected engine' do
      custom_engine = Legion::Extensions::CognitiveAvalanche::Helpers::AvalancheEngine.new
      c = described_class.new(engine: custom_engine)
      expect(c.engine).to be(custom_engine)
    end
  end

  describe '#create_snowpack' do
    it 'creates a snowpack via the client' do
      result = client.create_snowpack(snowpack_type: :ideas, domain: :creativity, content: 'spark')
      expect(result[:success]).to be(true)
    end

    it 'persists the snowpack in the engine' do
      result = client.create_snowpack(snowpack_type: :emotions, domain: :fear, content: 'dread')
      expect(client.engine.snowpacks).to have_key(result[:snowpack_id])
    end
  end

  describe '#trigger' do
    let(:pack_id) do
      client.create_snowpack(
        snowpack_type: :impulses, domain: :action, content: 'urgent impulse', stability: 0.05
      )[:snowpack_id]
    end

    it 'triggers a cascade for unstable snowpack' do
      result = client.trigger(snowpack_id: pack_id, force: 0.8)
      expect(result[:success]).to be(true)
      expect(result[:triggered]).to be(true)
    end

    it 'returns failure for unknown id' do
      result = client.trigger(snowpack_id: 'nonexistent', force: 0.5)
      expect(result[:success]).to be(false)
    end
  end

  describe '#accumulate' do
    before { client.create_snowpack(snowpack_type: :associations, domain: :network, content: 'linked nodes') }

    it 'accumulates all snowpacks' do
      result = client.accumulate
      expect(result[:success]).to be(true)
      expect(result[:packs_accumulated]).to eq(1)
    end
  end

  describe '#list_snowpacks' do
    it 'returns empty list on fresh client' do
      result = client.list_snowpacks
      expect(result[:success]).to be(true)
      expect(result[:count]).to eq(0)
    end

    it 'lists created snowpacks' do
      client.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'a')
      client.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'b')
      result = client.list_snowpacks
      expect(result[:count]).to eq(2)
    end
  end

  describe '#terrain_status' do
    it 'returns success with stats' do
      result = client.terrain_status
      expect(result[:success]).to be(true)
      expect(result[:total_snowpacks]).to eq(0)
    end

    it 'reflects created snowpacks' do
      client.create_snowpack(snowpack_type: :memories, domain: :past, content: 'childhood')
      result = client.terrain_status
      expect(result[:total_snowpacks]).to eq(1)
    end
  end

  describe 'client isolation' do
    it 'two clients do not share state' do
      c1 = described_class.new
      c2 = described_class.new
      c1.create_snowpack(snowpack_type: :ideas, domain: :test, content: 'isolated idea')
      expect(c2.terrain_status[:total_snowpacks]).to eq(0)
    end
  end
end
