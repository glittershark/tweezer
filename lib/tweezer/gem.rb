module Tweezer
  class Gem
    def initialize(ast)
      @name = ast.children[2].children[0]
    end

    attr_reader :name
  end
end
