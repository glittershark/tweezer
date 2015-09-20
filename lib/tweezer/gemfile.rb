require 'parser/current'
require 'unparser'

module Tweezer
  class Gemfile
    def initialize(source)
      @ast, @comments = Parser::CurrentRuby.parse_with_comments(source)
    end

    def gems
      @gems ||= @ast.children.map { |child| Gem.new(child) }
    end

    def add_gem(name)
      gem = Gem.new(name)
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
