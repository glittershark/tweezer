require 'spec_helper'
require 'parser/current'

describe Tweezer::Gem do
  describe '#initialize' do
    context 'with an AST node' do
      let(:node) { Parser::CurrentRuby.parse('gem "test"') }
      subject { described_class.new(node) }
      its(:name) { is_expected.to eq 'test' }
    end

    context 'with a name' do
      subject { described_class.new('tweezer') }
      its(:name) { is_expected.to eq 'tweezer' }
    end
  end
end
