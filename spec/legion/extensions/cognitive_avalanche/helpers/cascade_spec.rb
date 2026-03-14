# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAvalanche::Helpers::Cascade do
  subject(:cascade) do
    described_class.new(cascade_type: :creative, trigger_source: 'sp-abc', magnitude: 0.5)
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(cascade.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets cascade_type' do
      expect(cascade.cascade_type).to eq(:creative)
    end

    it 'sets trigger_source' do
      expect(cascade.trigger_source).to eq('sp-abc')
    end

    it 'sets magnitude' do
      expect(cascade.magnitude).to eq(0.5)
    end

    it 'defaults propagation_speed to 0.5' do
      expect(cascade.propagation_speed).to eq(0.5)
    end

    it 'defaults debris to empty array' do
      expect(cascade.debris).to eq([])
    end

    it 'records started_at timestamp' do
      expect(cascade.started_at).to be_a(Time)
    end

    it 'starts as active' do
      expect(cascade.active?).to be(true)
    end

    it 'clamps magnitude above 1.0 to 1.0' do
      c = described_class.new(cascade_type: :emotional, trigger_source: 'x', magnitude: 2.0)
      expect(c.magnitude).to eq(1.0)
    end

    it 'clamps magnitude below 0.0 to 0.0' do
      c = described_class.new(cascade_type: :emotional, trigger_source: 'x', magnitude: -0.5)
      expect(c.magnitude).to eq(0.0)
    end

    it 'raises ArgumentError for unknown cascade_type' do
      expect do
        described_class.new(cascade_type: :volcanic, trigger_source: 'x', magnitude: 0.5)
      end.to raise_error(ArgumentError, /unknown cascade_type/)
    end

    it 'accepts all valid cascade_types' do
      %i[creative emotional analytical chaotic convergent].each do |type|
        expect do
          described_class.new(cascade_type: type, trigger_source: 'x', magnitude: 0.5)
        end.not_to raise_error
      end
    end

    it 'accepts pre-populated debris' do
      c = described_class.new(cascade_type: :chaotic, trigger_source: 'x', magnitude: 0.5, debris: ['idea1'])
      expect(c.debris).to include('idea1')
    end
  end

  describe '#propagate!' do
    it 'increases magnitude by default 0.1' do
      expect { cascade.propagate! }.to change(cascade, :magnitude).by(0.1)
    end

    it 'increases magnitude by given rate' do
      expect { cascade.propagate!(0.2) }.to change(cascade, :magnitude).by(0.2)
    end

    it 'clamps magnitude at 1.0' do
      c = described_class.new(cascade_type: :chaotic, trigger_source: 'x', magnitude: 0.95)
      c.propagate!(0.5)
      expect(c.magnitude).to eq(1.0)
    end

    it 'does nothing when spent' do
      c = described_class.new(cascade_type: :chaotic, trigger_source: 'x', magnitude: 0.5)
      c.dissipate!(1.0)
      before = c.magnitude
      c.propagate!(0.1)
      expect(c.magnitude).to eq(before)
    end
  end

  describe '#dissipate!' do
    it 'decreases magnitude by default 0.08' do
      expect { cascade.dissipate! }.to change(cascade, :magnitude).by(-0.08)
    end

    it 'decreases magnitude by given rate' do
      expect { cascade.dissipate!(0.1) }.to change(cascade, :magnitude).by(-0.1)
    end

    it 'clamps magnitude at 0.0' do
      c = described_class.new(cascade_type: :chaotic, trigger_source: 'x', magnitude: 0.05)
      c.dissipate!(0.5)
      expect(c.magnitude).to eq(0.0)
    end

    it 'marks cascade as spent when magnitude reaches 0.0' do
      c = described_class.new(cascade_type: :chaotic, trigger_source: 'x', magnitude: 0.05)
      c.dissipate!(0.5)
      expect(c.spent?).to be(true)
    end
  end

  describe '#active?' do
    it 'returns true when active and magnitude > 0.0' do
      expect(cascade.active?).to be(true)
    end

    it 'returns false when fully dissipated' do
      cascade.dissipate!(1.0)
      expect(cascade.active?).to be(false)
    end
  end

  describe '#spent?' do
    it 'returns false for new cascade' do
      expect(cascade.spent?).to be(false)
    end

    it 'returns true after full dissipation' do
      cascade.dissipate!(1.0)
      expect(cascade.spent?).to be(true)
    end
  end

  describe '#magnitude_label' do
    it 'returns :minor for magnitude 0.1' do
      c = described_class.new(cascade_type: :chaotic, trigger_source: 'x', magnitude: 0.1)
      expect(c.magnitude_label).to eq(:minor)
    end

    it 'returns :devastating for magnitude 0.9' do
      c = described_class.new(cascade_type: :chaotic, trigger_source: 'x', magnitude: 0.9)
      expect(c.magnitude_label).to eq(:devastating)
    end
  end

  describe '#add_debris' do
    it 'appends to debris array' do
      cascade.add_debris('new thought fragment')
      expect(cascade.debris).to include('new thought fragment')
    end

    it 'supports multiple debris items' do
      cascade.add_debris('item1')
      cascade.add_debris('item2')
      expect(cascade.debris.size).to eq(2)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = cascade.to_h
      expect(h.keys).to include(:id, :cascade_type, :trigger_source, :magnitude, :magnitude_label,
                                 :propagation_speed, :debris, :active, :started_at)
    end

    it 'reflects current active state' do
      cascade.dissipate!(1.0)
      expect(cascade.to_h[:active]).to be(false)
    end

    it 'returns a duplicate of debris' do
      h = cascade.to_h
      h[:debris] << 'mutant'
      expect(cascade.debris).not_to include('mutant')
    end
  end
end
