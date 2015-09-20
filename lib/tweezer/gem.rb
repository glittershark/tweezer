module Tweezer
  class Gem
    def initialize(node_or_name, version = nil)
      if node_or_name.is_a? Parser::AST::Node
        check_node!(node_or_name)

        arguments = node_or_name.children[2..-1]

        @name = arguments[0].children[0]
        @version = arguments[1].children[0] if arguments[1]
      else
        @name = node_or_name
        @version = version
      end
    end

    def to_node
      args = [nil, :gem, Parser::AST::Node.new(:str, [name])]
      args << Parser::AST::Node.new(:str, [version]) if version

      Parser::AST::Node.new(:send, args)
    end

    def self.gem_node?(node)
      node.children[1] == :gem
    end

    attr_reader :name, :version

    private

    def check_node!(node)
      return if self.class.gem_node?(node)
      fail ArgumentError, "Not a call to `gem`: #{node.inspect}"
    end
  end
end
