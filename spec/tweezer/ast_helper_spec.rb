require 'spec_helper'

describe Tweezer::ASTHelper do
  include described_class

  describe '.block?' do
    context 'for a block node' do
      subject { Parser::CurrentRuby.parse '2.times { puts "hello ruby" }' }
      specify { expect(described_class.block?(subject)).to be true }
    end

    context 'for a non-block node' do
      subject { Parser::CurrentRuby.parse 'puts "hello ruby"' }
      specify { expect(described_class.block?(subject)).to be false }
    end
  end

  describe '.source_block?' do
    context 'for a :source block' do
      subject { Parser::CurrentRuby.parse 'source("foobar") {}' }
      specify { expect(described_class.source_block?(subject)).to be true }
    end

    context 'for a non-:source block' do
      subject { Parser::CurrentRuby.parse 'it("foobar") {}' }
      specify { expect(described_class.source_block?(subject)).to be false }
    end

    context 'for a non-block node' do
      subject { Parser::CurrentRuby.parse 'puts "hello ruby"' }
      specify { expect(described_class.source_block?(subject)).to be false }
    end
  end

  describe '.group_block?' do
    context 'for a :group block' do
      subject { Parser::CurrentRuby.parse 'group("foobar") {}' }
      specify { expect(described_class.group_block?(subject)).to be true }
    end

    context 'for a non-:source block' do
      subject { Parser::CurrentRuby.parse 'it("foobar") {}' }
      specify { expect(described_class.group_block?(subject)).to be false }
    end

    context 'for a non-block node' do
      subject { Parser::CurrentRuby.parse 'puts "hello ruby"' }
      specify { expect(described_class.source_block?(subject)).to be false }
    end
  end

  describe '.block_children' do
    context 'for a block with one child' do
      let(:node) { Parser::CurrentRuby.parse '2.times { puts "hello ruby" }' }
      subject { described_class.block_children(node) }
      it { is_expected.to eq [Parser::CurrentRuby.parse('puts "hello ruby"')] }
    end

    context 'for a block with multiple children' do
      let(:node) { Parser::CurrentRuby.parse '2.times { puts "hi"; 1 + 1 }' }
      subject { described_class.block_children(node) }

      it do
        is_expected.to eq [Parser::CurrentRuby.parse('puts "hi"'),
                           Parser::CurrentRuby.parse('1 + 1')]
      end
    end
  end

  describe '.groups_from_group_block' do
    let(:node) { Parser::CurrentRuby.parse "group(:test) { gem 'test' }" }
    subject { described_class.groups_from_group_block node }
    it { is_expected.to eq [:test] }
  end

  describe '.unparse_hash_node' do
    let(:node) { Parser::CurrentRuby.parse '{ a: :b, "c" => :d }' }
    subject { described_class.unparse_hash_node(node) }
    it { is_expected.to eq a: s(:sym, :b), 'c' => s(:sym, :d) }
  end

  describe '.append_block_child' do
    let(:block) { Parser::CurrentRuby.parse "group(:test) { gem 'test' }" }
    let(:appended) { Parser::CurrentRuby.parse 'gem "new"' }
    subject { described_class.append_block_child(block, appended) }

    it "appends the node to the block's children" do
      expect(described_class.block_children(subject)).to include appended
    end
  end
end
