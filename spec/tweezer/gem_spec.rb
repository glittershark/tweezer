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
end
