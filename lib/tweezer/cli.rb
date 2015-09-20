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
    def add(name, version = nil)
      @gemfile.add_gem(name, version)
      @gemfile.save!
    end
  end
end
