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
    def add(name, version = nil)
      groups = options[:groups].map(&:to_sym) if options[:groups]
      @gemfile.add_gem(name, version, groups: groups || [])
      @gemfile.save!
    end
  end
end
