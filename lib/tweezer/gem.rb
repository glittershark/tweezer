module Tweezer
  class Gem
    def initialize(node_or_name)
      if node_or_name.is_a? Parser::AST::Node
        @name = node_or_name.children[2].children[0]
      else
        @name = node_or_name
      end
    end

    attr_reader :name
  end
end
