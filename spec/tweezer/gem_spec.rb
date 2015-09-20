require 'spec_helper'
require 'parser/current'

describe Tweezer::Gem do
  describe '#initialize' do
    context 'with an AST node' do
      context 'with just a name' do
        let(:node) { Parser::CurrentRuby.parse('gem "test"') }
        subject { described_class.new(node) }
        its(:name) { is_expected.to eq 'test' }
      end

      context 'with a version' do
        let(:node) { Parser::CurrentRuby.parse('gem "test", "~> 1.0.0"') }
        subject { described_class.new(node) }
        its(:name) { is_expected.to eq 'test' }
        its(:version) { is_expected.to eq '~> 1.0.0' }
      end
    end

    context 'with a name' do
      subject { described_class.new('tweezer') }
      its(:name) { is_expected.to eq 'tweezer' }
    end

    context 'with a name and a version' do
      subject { described_class.new('tweezer', '~> 1.0.0') }
      its(:name) { is_expected.to eq 'tweezer' }
      its(:version) { is_expected.to eq '~> 1.0.0' }
    end
  end

  describe '#to_node' do
    context 'with just a name' do
      subject { described_class.new('tweezer').to_node }
      its(:type) { is_expected.to eq :send }

      it 'calls the `gem` method' do
        expect(subject.children[1]).to eq :gem
      end

      it 'calls the gem method with the name of the gem' do
        expect(subject.children[2].children[0]).to eq 'tweezer'
      end
    end

    context 'with a name and a version' do
      subject { described_class.new('tweezer', '~> 1.0.0').to_node }
      its(:type) { is_expected.to eq :send }

      it 'calls the `gem` method' do
        expect(subject.children[1]).to eq :gem
      end

      it 'calls the gem method with the name of the gem' do
        expect(subject.children[2].children[0]).to eq 'tweezer'
      end

      it "calls the gem method with the gem's version as the second argument" do
        expect(subject.children[3].children[0]).to eq '~> 1.0.0'
      end
    end
  end

  describe '.gem_node?' do
    context 'with a gem node' do
      let(:node) { Parser::CurrentRuby.parse('gem "test"') }
      subject { described_class.gem_node?(node) }
      it { is_expected.to be true }
    end

    context 'with a non-gem node' do
      let(:node) { Parser::CurrentRuby.parse('ruby "2.2.0"') }
      subject { described_class.gem_node?(node) }
      it { is_expected.to be false }
    end
  end
end
