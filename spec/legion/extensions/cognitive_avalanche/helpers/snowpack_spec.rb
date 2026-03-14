# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAvalanche::Helpers::Snowpack do
  subject(:snowpack) do
    described_class.new(snowpack_type: :ideas, domain: :reasoning, content: 'recursive self-improvement')
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(snowpack.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets snowpack_type' do
      expect(snowpack.snowpack_type).to eq(:ideas)
    end

    it 'sets domain' do
      expect(snowpack.domain).to eq(:reasoning)
    end

    it 'sets content' do
      expect(snowpack.content).to eq('recursive self-improvement')
    end

    it 'defaults depth to 0.0' do
      expect(snowpack.depth).to eq(0.0)
    end

    it 'defaults stability to 1.0' do
      expect(snowpack.stability).to eq(1.0)
    end

    it 'records created_at timestamp' do
      expect(snowpack.created_at).to be_a(Time)
    end

    it 'clamps depth above 1.0 to 1.0' do
      sp = described_class.new(snowpack_type: :emotions, domain: :test, content: 'x', depth: 2.5)
      expect(sp.depth).to eq(1.0)
    end

    it 'clamps stability below 0.0 to 0.0' do
      sp = described_class.new(snowpack_type: :emotions, domain: :test, content: 'x', stability: -0.5)
      expect(sp.stability).to eq(0.0)
    end

    it 'raises ArgumentError for unknown snowpack_type' do
      expect do
        described_class.new(snowpack_type: :unknown_type, domain: :test, content: 'x')
      end.to raise_error(ArgumentError, /unknown snowpack_type/)
    end

    it 'accepts all valid snowpack_types' do
      %i[ideas emotions memories associations impulses].each do |type|
        expect do
          described_class.new(snowpack_type: type, domain: :test, content: 'x')
        end.not_to raise_error
      end
    end
  end

  describe '#accumulate!' do
    it 'increases depth by default rate' do
      expect { snowpack.accumulate! }.to change(snowpack, :depth).by(0.06)
    end

    it 'increases depth by given rate' do
      expect { snowpack.accumulate!(0.1) }.to change(snowpack, :depth).by(0.1)
    end

    it 'clamps depth at 1.0' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', depth: 0.98)
      sp.accumulate!(0.1)
      expect(sp.depth).to eq(1.0)
    end

    it 'uses absolute value of rate' do
      before = snowpack.depth
      snowpack.accumulate!(-0.05)
      expect(snowpack.depth).to eq((before + 0.05).round(10))
    end
  end

  describe '#compact!' do
    it 'increases stability by 0.05' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.5)
      before = sp.stability
      sp.compact!
      expect(sp.stability).to be_within(0.0001).of(before + 0.05)
    end

    it 'clamps stability at 1.0' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.98)
      sp.compact!
      expect(sp.stability).to eq(1.0)
    end
  end

  describe '#destabilize!' do
    it 'reduces stability by force' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.8)
      before = sp.stability
      sp.destabilize!(0.2)
      expect(sp.stability).to be_within(0.0001).of(before - 0.2)
    end

    it 'clamps stability at 0.0' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.1)
      sp.destabilize!(0.5)
      expect(sp.stability).to eq(0.0)
    end

    it 'uses absolute value of force' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.8)
      sp.destabilize!(-0.2)
      expect(sp.stability).to eq(0.6)
    end
  end

  describe '#stable?' do
    it 'returns true when stability >= 0.6' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.7)
      expect(sp.stable?).to be(true)
    end

    it 'returns false when stability < 0.6' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.5)
      expect(sp.stable?).to be(false)
    end

    it 'returns true at exactly 0.6' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.6)
      expect(sp.stable?).to be(true)
    end
  end

  describe '#unstable?' do
    it 'returns true when stability < 0.4' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.3)
      expect(sp.unstable?).to be(true)
    end

    it 'returns false when stability >= 0.4' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.5)
      expect(sp.unstable?).to be(false)
    end
  end

  describe '#critical?' do
    it 'returns true when stability < 0.2' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.1)
      expect(sp.critical?).to be(true)
    end

    it 'returns false when stability >= 0.2' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.2)
      expect(sp.critical?).to be(false)
    end
  end

  describe '#stability_label' do
    it 'returns :catastrophic for stability 0.1' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.1)
      expect(sp.stability_label).to eq(:catastrophic)
    end

    it 'returns :bedrock for stability 1.0' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 1.0)
      expect(sp.stability_label).to eq(:bedrock)
    end
  end

  describe '#instability' do
    it 'returns 1.0 - stability' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 0.7)
      expect(sp.instability).to eq(0.3)
    end

    it 'returns 0.0 when fully stable' do
      sp = described_class.new(snowpack_type: :ideas, domain: :test, content: 'x', stability: 1.0)
      expect(sp.instability).to eq(0.0)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = snowpack.to_h
      expect(h.keys).to include(:id, :snowpack_type, :domain, :content, :depth, :stability,
                                :stable, :unstable, :critical, :stability_label, :created_at)
    end

    it 'reflects current stability state' do
      h = snowpack.to_h
      expect(h[:stable]).to eq(snowpack.stable?)
    end
  end
end
