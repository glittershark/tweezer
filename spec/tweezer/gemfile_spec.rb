require 'spec_helper'

describe Tweezer::Gemfile do
  basic_gemfile = <<-RUBY.strip_heredoc
    gem 'test1'
    gem 'test2', '~> 1.0'
  RUBY

  gemfile_with_comments = <<-RUBY.strip_heredoc
    # the 'test1' gem
    gem 'test1'
    # the 'test2' gem
    gem 'test2', '~> 1.0'
  RUBY

  gemfile_with_newline = <<-RUBY.strip_heredoc
    gem 'test1'

    gem 'test2', '~> 1.0'
  RUBY

  gemfile_with_ruby = <<-RUBY.strip_heredoc
    ruby '2.2.2'
    gem 'test'
  RUBY

  gemfile_with_sources = <<-RUBY.strip_heredoc
    ruby '2.2.2'

    gem 'test'

    source 'http://example.org' do
      gem 'foobar'
    end
  RUBY

  gemfile_with_group = <<-RUBY.strip_heredoc
    ruby '2.2.2'

    gem 'test'
    gem 'test2', group: :test

    group :development do
      gem 'foobar'
    end
  RUBY

  gemfile_with_multiple_groups = <<-RUBY.strip_heredoc
    ruby '2.2.2'

    gem 'test'
    gem 'test2', group: :test

    group :development do
      gem 'foobar'
    end

    group :test do
      gem 'boofar'
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
    context 'with a basic gem' do
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
          before { subject.add_gem 'tweezer', version: '~> 1.0.0' }

          it 'adds the gem with the version to the #gems array' do
            expect(subject.gems.last).to have_attributes name: 'tweezer',
                                                         version: '~> 1.0.0'
          end

          it "adds the gem's node to the AST" do
            expect(subject.dump).to include "gem 'tweezer', '~> 1.0.0'"
          end
        end

        context 'with a name and a path' do
          before { subject.add_gem 'tweezer', path: '~/code/tweezer' }

          it 'adds the gem with the path to the #gems array' do
            expect(subject.gems.last).to have_attributes name: 'tweezer',
                                                         path: '~/code/tweezer'
          end

          it "adds the gem's node to the AST" do
            expect(subject.dump).to include(
              "gem 'tweezer', path: '~/code/tweezer'")
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
          before { subject.add_gem 'tweezer', version: '~> 1.0.0' }

          it 'adds the gem to the right place' do
            expect(subject.dump).to eq <<-RUBY.strip_heredoc
              ruby '2.2.2'

              gem 'test'
              gem 'tweezer', '~> 1.0.0'

              source 'http://example.org' do
                gem 'foobar'
              end
            RUBY
          end
        end

        context 'for a gemfile with group blocks' do
          subject { described_class.new(gemfile_with_multiple_groups) }
          before { subject.add_gem 'tweezer', version: '~> 1.0.0' }

          it 'adds the gem to the right place' do
            expect(subject.dump).to eq <<-RUBY.strip_heredoc
              ruby '2.2.2'

              gem 'test'
              gem 'test2', group: :test
              gem 'tweezer', '~> 1.0.0'

              group :development do
                gem 'foobar'
              end

              group :test do
                gem 'boofar'
              end
            RUBY
          end
        end
      end

      context 'with a groups option' do
        context 'to a basic gemfile' do
          subject { described_class.new(basic_gemfile) }
          before do
            subject.add_gem 'tweezer', version: '~> 1.0.0', groups: [:test]
          end

          it 'adds the gem with the group description' do
            expect(subject.dump).to eq <<-RUBY.strip_heredoc
              gem 'test1'
              gem 'test2', '~> 1.0'
              gem 'tweezer', '~> 1.0.0', group: :test
            RUBY
          end
        end
      end
    end

    context 'for a gemfile with source blocks' do
      subject { described_class.new(gemfile_with_sources) }
      before { subject.add_gem 'tweezer', version: '~> 1.0.0' }

      it 'adds the gem to the right place' do
        expect(subject.dump).to eq <<-RUBY.strip_heredoc
          ruby '2.2.2'

          gem 'test'
          gem 'tweezer', '~> 1.0.0'

          source 'http://example.org' do
            gem 'foobar'
          end
        RUBY
      end
    end

    context 'for a gemfile with groups' do
      subject { described_class.new(gemfile_with_group) }
      context 'for a basic gem' do
        before { subject.add_gem 'tweezer', version: '~> 1.0.0' }

        it 'adds the gem to the right place' do
          expect(subject.dump).to eq <<-RUBY.strip_heredoc
            ruby '2.2.2'

            gem 'test'
            gem 'test2', group: :test
            gem 'tweezer', '~> 1.0.0'

            group :development do
              gem 'foobar'
            end
          RUBY
        end
      end

      context 'with a :groups option' do
        context 'when that group matches an existing block' do
          before { subject.add_gem 'tweezer', groups: [:development] }

          it 'adds the gem to the existing group block' do
            expect(subject.dump).to eq <<-RUBY.strip_heredoc
              ruby '2.2.2'

              gem 'test'
              gem 'test2', group: :test

              group :development do
                gem 'foobar'
                gem 'tweezer'
              end
            RUBY
          end
        end

        context 'when that group matches an existing gem' do
          before { subject.add_gem 'tweezer', groups: [:test] }

          it 'adds the gem, and the existing gem, to a new group block' do
            expect(subject.dump).to eq <<-RUBY.strip_heredoc
              ruby '2.2.2'

              gem 'test'

              group :test do
                gem 'test2'
                gem 'tweezer'
              end

              group :development do
                gem 'foobar'
              end
            RUBY
          end
        end
      end
    end
  end

  describe '#alter_gem' do
    context "when the gem isn't present in the gemfile" do
      subject { described_class.new(basic_gemfile) }

      it 'raises an error' do
        expect { subject.alter_gem 'tweezer' }.to raise_error(
          Tweezer::GemNotPresent)
      end
    end

    context 'with a basic gem' do
      context 'for a basic gemfile' do
        subject { described_class.new(basic_gemfile) }

        context 'changing the version' do
          before { subject.alter_gem 'test1', version: '~> 1.1' }

          it "adds the gem's version to the gemfile source" do
            expect(subject.dump).to eq <<-RUBY.strip_heredoc
              gem 'test1', '~> 1.1'
              gem 'test2', '~> 1.0'
            RUBY
          end
        end

        context 'changing the path' do
          before { subject.alter_gem 'test1', path: '~/code/test1' }

          it "adds the gem's version to the gemfile source" do
            expect(subject.dump).to eq <<-RUBY.strip_heredoc
              gem 'test1', path: '~/code/test1'
              gem 'test2', '~> 1.0'
            RUBY
          end
        end

        context 'when the gem already has options set' do
          before { subject.alter_gem 'test2', path: '~/code/test2' }

          it 'alters the gem in-line, preserving existing options' do
            expect(subject.dump).to eq <<-RUBY.strip_heredoc
              gem 'test1'
              gem 'test2', '~> 1.0', path: '~/code/test2'
            RUBY
          end
        end
      end
    end
  end

  describe '#dump' do
    {
      'basic gemfile' => basic_gemfile,
      'gemfile with comments' => gemfile_with_comments,
      'gemfile with newlines' => gemfile_with_newline,
      'gemfile with a ruby version' => gemfile_with_ruby,
      'gemfile with a source block' => gemfile_with_sources,
      'gemfile with a group block' => gemfile_with_group,
      'gemfile with multiple group blocks' => gemfile_with_multiple_groups
    }.each do |name, source|
      context "for a #{name}" do
        subject { described_class.new(source).dump }
        it { is_expected.to eq source }
      end
    end
  end
end
