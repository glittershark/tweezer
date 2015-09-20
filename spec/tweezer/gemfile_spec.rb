require 'spec_helper'

describe Tweezer::Gemfile do
  describe '#gems' do
    let(:source) do
      <<-RUBY
        gem 'test1'
        gem 'test2', '~> 1.0'
      RUBY
    end

    subject { described_class.new(source).gems }
    it { is_expected.to have(2).items }
    it { is_expected.to all(be_a Tweezer::Gem) }

    it 'returns the correct gems' do
      expect(subject.map(&:name)).to eq %w(test1 test2)
    end
  end
end
