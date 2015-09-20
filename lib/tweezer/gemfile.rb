require 'parser/current'

module Tweezer
  class Gemfile
    def initialize(source)
      @ast = Parser::CurrentRuby.parse(source)
    end

    def gems
      @gems ||= @ast.children.map { |child| Gem.new(child) }
    end
  end
end
