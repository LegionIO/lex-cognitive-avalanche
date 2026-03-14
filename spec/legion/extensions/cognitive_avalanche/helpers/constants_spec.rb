# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAvalanche::Helpers::Constants do
  def described_module
    Legion::Extensions::CognitiveAvalanche::Helpers::Constants
  end

  describe 'MAX_SNOWPACKS' do
    it 'is 100' do
      expect(described_module::MAX_SNOWPACKS).to eq(100)
    end
  end

  describe 'MAX_CASCADE_HISTORY' do
    it 'is 500' do
      expect(described_module::MAX_CASCADE_HISTORY).to eq(500)
    end
  end

  describe 'TRIGGER_THRESHOLD' do
    it 'is 0.75' do
      expect(described_module::TRIGGER_THRESHOLD).to eq(0.75)
    end
  end

  describe 'ACCUMULATION_RATE' do
    it 'is 0.06' do
      expect(described_module::ACCUMULATION_RATE).to eq(0.06)
    end
  end

  describe 'MELT_RATE' do
    it 'is 0.02' do
      expect(described_module::MELT_RATE).to eq(0.02)
    end
  end

  describe 'SNOWPACK_TYPES' do
    it 'contains all five types' do
      expect(described_module::SNOWPACK_TYPES).to eq(%i[ideas emotions memories associations impulses])
    end

    it 'is frozen' do
      expect(described_module::SNOWPACK_TYPES).to be_frozen
    end
  end

  describe 'CASCADE_TYPES' do
    it 'contains all five types' do
      expect(described_module::CASCADE_TYPES).to eq(%i[creative emotional analytical chaotic convergent])
    end

    it 'is frozen' do
      expect(described_module::CASCADE_TYPES).to be_frozen
    end
  end

  describe 'STABILITY_LABELS' do
    it 'is a hash' do
      expect(described_module::STABILITY_LABELS).to be_a(Hash)
    end

    it 'covers catastrophic through bedrock' do
      labels = described_module::STABILITY_LABELS.values
      expect(labels).to include(:catastrophic, :critical, :unstable, :moderate, :bedrock)
    end
  end

  describe 'MAGNITUDE_LABELS' do
    it 'is a hash' do
      expect(described_module::MAGNITUDE_LABELS).to be_a(Hash)
    end

    it 'covers minor through devastating' do
      labels = described_module::MAGNITUDE_LABELS.values
      expect(labels).to include(:minor, :moderate, :significant, :major, :devastating)
    end
  end

  describe '.label_for' do
    it 'returns :catastrophic for stability 0.1' do
      expect(described_module.label_for(:STABILITY_LABELS, 0.1)).to eq(:catastrophic)
    end

    it 'returns :critical for stability 0.3' do
      expect(described_module.label_for(:STABILITY_LABELS, 0.3)).to eq(:critical)
    end

    it 'returns :unstable for stability 0.5' do
      expect(described_module.label_for(:STABILITY_LABELS, 0.5)).to eq(:unstable)
    end

    it 'returns :moderate for stability 0.7' do
      expect(described_module.label_for(:STABILITY_LABELS, 0.7)).to eq(:moderate)
    end

    it 'returns :bedrock for stability 0.9' do
      expect(described_module.label_for(:STABILITY_LABELS, 0.9)).to eq(:bedrock)
    end

    it 'returns :minor for magnitude 0.1' do
      expect(described_module.label_for(:MAGNITUDE_LABELS, 0.1)).to eq(:minor)
    end

    it 'returns :moderate for magnitude 0.3' do
      expect(described_module.label_for(:MAGNITUDE_LABELS, 0.3)).to eq(:moderate)
    end

    it 'returns :significant for magnitude 0.5' do
      expect(described_module.label_for(:MAGNITUDE_LABELS, 0.5)).to eq(:significant)
    end

    it 'returns :major for magnitude 0.7' do
      expect(described_module.label_for(:MAGNITUDE_LABELS, 0.7)).to eq(:major)
    end

    it 'returns :devastating for magnitude 0.9' do
      expect(described_module.label_for(:MAGNITUDE_LABELS, 0.9)).to eq(:devastating)
    end

    it 'clamps values above 1.0 to 1.0' do
      expect(described_module.label_for(:MAGNITUDE_LABELS, 1.5)).not_to eq(:unknown)
    end

    it 'clamps values below 0.0 to 0.0' do
      expect(described_module.label_for(:MAGNITUDE_LABELS, -0.5)).not_to eq(:unknown)
    end
  end
end
