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

      context 'with a path' do
        let(:node) do
          Parser::CurrentRuby.parse('gem "test", path: "~/code/tweezer"')
        end
        subject { described_class.new(node) }
        its(:name) { is_expected.to eq 'test' }
        its(:path) { is_expected.to eq '~/code/tweezer' }
      end

      context 'with a group' do
        let(:node) { Parser::CurrentRuby.parse('gem "test", group: :test') }
        subject { described_class.new(node) }
        its(:name) { is_expected.to eq 'test' }
        its(:groups) { is_expected.to eq [:test] }
      end

      context 'with an array of groups' do
        let(:node) { Parser::CurrentRuby.parse('gem "test", group: [:a, :b]') }
        subject { described_class.new(node) }
        its(:name) { is_expected.to eq 'test' }
        its(:groups) { is_expected.to eq [:a, :b] }
      end
    end

    context 'with a name' do
      subject { described_class.new('tweezer') }
      its(:name) { is_expected.to eq 'tweezer' }
    end

    context 'with a name and a version' do
      subject { described_class.new('tweezer', version: '~> 1.0.0') }
      its(:name) { is_expected.to eq 'tweezer' }
      its(:version) { is_expected.to eq '~> 1.0.0' }
    end

    context 'with a name and a path' do
      subject { described_class.new('tweezer', path: '~/code/tweezer') }
      its(:name) { is_expected.to eq 'tweezer' }
      its(:path) { is_expected.to eq '~/code/tweezer' }
    end

    context 'with a group' do
      subject do
        described_class.new('tweezer', version: '~> 1.0.0', groups: [:test])
      end
      its(:name) { is_expected.to eq 'tweezer' }
      its(:version) { is_expected.to eq '~> 1.0.0' }
      its(:groups) { is_expected.to eq [:test] }
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
      subject { described_class.new('tweezer', version: '~> 1.0.0').to_node }
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

    context 'with a name, version, and path' do
      subject do
        described_class.new('tweezer', path: '~/gems/tweezer',
                                       version: '~> 1.0.0').to_node
      end
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

      it 'calls the gem method with the path as an option' do
        pair = subject.children[4].children[0]
        expect(pair.children[0].children[0]).to eq :path
        expect(pair.children[1].children[0]).to eq '~/gems/tweezer'
      end
    end

    context 'with a group' do
      let(:gem) do
        described_class.new('tweezer', version: '~> 1.0.0', groups: [:test])
      end
      subject { gem.to_node }

      it 'calls the `gem` method' do
        expect(subject.children[1]).to eq :gem
      end

      it 'calls the gem method with the name of the gem' do
        expect(subject.children[2].children[0]).to eq 'tweezer'
      end

      it "calls the gem method with the gem's version as the second argument" do
        expect(subject.children[3].children[0]).to eq '~> 1.0.0'
      end

      it 'calls the gem method with the groups as options' do
        pair = subject.children[4].children[0]
        expect(pair.children[0].children[0]).to eq :group
        expect(pair.children[1].children[0]).to eq :test
      end
    end
  end

  describe '#==' do
    subject { described_class.new('tweezer', version: '~> 1.0.0') }

    context 'with two equal gems' do
      it do
        is_expected.to eq described_class.new('tweezer', version: '~> 1.0.0')
      end
    end

    context 'when the versions differ' do
      it do
        is_expected.to_not eq described_class.new('tweezer',
                                                  version: '~> 1.0.1')
      end
    end

    context 'when the names differ' do
      it do
        is_expected.to_not eq described_class.new('foobar', version: '~> 1.0.0')
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
