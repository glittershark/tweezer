require 'thor'
require 'bundler'

module Tweezer
  class CLI < Thor
    def initialize(*)
      super

      custom_gemfile = options[:gemfile] || Bundler.settings[:gemfile]
      if custom_gemfile && !custom_gemfile.empty?
        ENV['BUNDLE_GEMFILE'] = File.expand_path(custom_gemfile)
      end

      @gemfile = Tweezer::Gemfile.load
    end

    desc 'add GEM [VERSION]',
         'add GEM to the gemfile, optionally pinned to VERSION'
    option :groups, type: :array, aliases: '-g',
                    desc: 'Groups to add the gem to'
    def add(name)
      @gemfile.add_gem(name, **gem_opts)
      @gemfile.save!
    end

    desc 'alter GEM',
         'alter GEM that is already in the gemfile, with the given options'
    option :version, aliases: '-v', desc: 'version to pin the gem to'
    option :groups, aliases: '-g',
                    type: :array,
                    desc: 'version to pin the gem to'
    def alter(name)
      @gemfile.alter_gem(name, **gem_opts)
      @gemfile.save!
    end

    private

    def gem_opts
      @gem_opts ||= {
        groups: options[:groups] ? options[:groups].map(&:to_sym) : [],
        version: options[:version] || ''
      }
    end
  end
end
