require 'spec_helper'

describe Tweezer::Gemfile do
  basic_gemfile = <<-RUBY.strip
gem 'test1'
gem 'test2', '~> 1.0'
  RUBY

  gemfile_with_comments = <<-RUBY.strip
# the 'test1' gem
gem 'test1'
# the 'test2' gem
gem 'test2', '~> 1.0'
  RUBY

  gemfile_with_newline = <<-RUBY.strip
gem 'test1'

gem 'test2', '~> 1.0'
  RUBY

  gemfile_with_ruby = <<-RUBY.strip
ruby '2.2.2'
gem 'test'
  RUBY

  gemfile_with_sources = <<-RUBY.strip
ruby '2.2.2'

gem 'test'

source 'http://example.org' do
  gem 'foobar'
end
  RUBY

  describe '#gems' do
    context 'for a basic gemfile' do
      subject { described_class.new(basic_gemfile).gems }
      it { is_expected.to have(2).items }
      it { is_expected.to all(be_a Tweezer::Gem) }

      it 'returns the correct gems' do
        expect(subject.map(&:name)).to eq %w(test1 test2)
      end
    end

    context 'for a gemfile with a ruby version declaration' do
      subject { described_class.new(gemfile_with_ruby).gems }
      it { is_expected.to have(1).item }
      it { is_expected.to all(be_a Tweezer::Gem) }
    end
  end

  describe '#add_gem' do
    context 'for a basic gemfile' do
      subject { described_class.new(basic_gemfile) }

      context 'with just a name' do
        before { subject.add_gem 'tweezer' }

        it 'adds the gem to the #gems array' do
          expect(subject.gems.last.name).to eq 'tweezer'
        end

        it "adds the gem's node to the AST" do
          expect(subject.dump).to include "gem 'tweezer'"
        end
      end

      context 'with a name and a version' do
        before { subject.add_gem 'tweezer', '~> 1.0.0' }

        it 'adds the gem with the version to the #gems array' do
          expect(subject.gems.last).to have_attributes name: 'tweezer',
                                                       version: '~> 1.0.0'
        end

        it "adds the gem's node to the AST" do
          expect(subject.dump).to include "gem 'tweezer', '~> 1.0.0'"
        end
      end

      context "with a gem that's already present" do
        it 'raises a GemAlreadyPresent error' do
          expect { subject.add_gem('test1') }.to raise_error(
            Tweezer::GemAlreadyPresent)
        end
      end

      context 'for a gemfile with source blocks' do
        subject { described_class.new(gemfile_with_sources) }
        before { subject.add_gem 'tweezer', '~> 1.0.0' }

        it 'adds the gem to the right place' do
          expect(subject.dump).to eq <<-RUBY.strip
ruby '2.2.2'

gem 'test'
gem 'tweezer', '~> 1.0.0'

source 'http://example.org' do
  gem 'foobar'
end
          RUBY
        end
      end
    end
  end

  describe '#dump' do
    {
      'basic gemfile' => basic_gemfile,
      'gemfile with comments' => gemfile_with_comments,
      'gemfile with newlines' => gemfile_with_newline,
      'gemfile with a ruby version' => gemfile_with_ruby
    }.each do |name, source|
      context "for a #{name}" do
        subject { described_class.new(source).dump }
        it { is_expected.to eq source }
      end
    end
  end
end
