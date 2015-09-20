require 'bundler'
require 'parser/current'
require 'unparser'

module Tweezer
  class Gemfile
    def initialize(source, file = nil)
      @ast, @comments = Parser::CurrentRuby.parse_with_comments(source, file)
      @file = file
    end

    def self.load(file = Bundler.default_gemfile)
      new(File.read(file), file)
    end

    def save!
      fail unless @file
      File.write(@file, dump)
    end

    def gems
      @gems ||= @ast.children.map do |node|
        next unless Gem.gem_node? node
        Gem.new(node)
      end.compact
    end

    def add_gem(*args)
      gem = Gem.new(*args)
      fail GemAlreadyPresent if gems.include? gem
      gems << gem
      @ast = @ast.append(gem.to_node)
    end

    def dump
      Unparser.unparse(ast, comments)
    end

    private

    attr_reader :ast, :comments
  end
end
