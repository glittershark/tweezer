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

    def dump
      Unparser.unparse(ast)
    end

    private

    attr_reader :ast
  end
end
