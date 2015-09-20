require 'spec_helper'

describe Tweezer::Gemfile do
  let(:basic_gemfile) do
    <<-RUBY.strip
gem "test1"
gem "test2", "~> 1.0"
    RUBY
  end

  let(:gemfile_with_comments) do
    <<-RUBY.strip
# the 'test1' gem
gem "test1"
# the 'test2' gem
gem "test2", "~> 1.0"
    RUBY
  end

  describe '#gems' do
    subject { described_class.new(basic_gemfile).gems }
    it { is_expected.to have(2).items }
    it { is_expected.to all(be_a Tweezer::Gem) }

    it 'returns the correct gems' do
      expect(subject.map(&:name)).to eq %w(test1 test2)
    end
  end

  describe '#add_gem' do
    subject { described_class.new(basic_gemfile) }

    before do
      subject.add_gem 'tweezer'
    end

    it 'adds the gem to the #gems array' do
      expect(subject.gems.last.name).to eq 'tweezer'
    end

    it "adds the gem's node to the AST" do
      expect(subject.dump).to include 'gem "tweezer"'
    end
  end

  describe '#dump' do
    context 'for a basic gemfile' do
      subject { described_class.new(basic_gemfile).dump }
      it { is_expected.to eq basic_gemfile }
    end

    context 'for a gemfile with comments' do
      subject { described_class.new(gemfile_with_comments).dump }
      it { is_expected.to eq gemfile_with_comments }
    end
  end
end
