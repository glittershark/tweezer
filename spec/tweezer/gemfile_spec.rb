require 'spec_helper'

describe Tweezer::Gemfile do
  let(:basic_source) do
    <<-RUBY.strip
gem "test1"
gem "test2", "~> 1.0"
    RUBY
  end

  describe '#gems' do
    subject { described_class.new(basic_source).gems }
    it { is_expected.to have(2).items }
    it { is_expected.to all(be_a Tweezer::Gem) }

    it 'returns the correct gems' do
      expect(subject.map(&:name)).to eq %w(test1 test2)
    end
  end

  describe '#dump' do
    subject { described_class.new(basic_source).dump }
    it { is_expected.to eq basic_source }
  end
end
