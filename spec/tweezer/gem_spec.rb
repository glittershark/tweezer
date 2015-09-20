require 'spec_helper'
require 'parser/current'

describe Tweezer::Gem do
  describe '#initialize' do
    let(:ast) { Parser::CurrentRuby.parse('gem "test"') }
    subject { described_class.new(ast) }
    its(:name) { is_expected.to eq 'test' }
  end
end
