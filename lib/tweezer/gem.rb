module Tweezer
  class Gem
    def initialize(node_or_name, version = nil, opts = {})
      if node_or_name.is_a? Parser::AST::Node
        check_node!(node_or_name)

        arguments = node_or_name.children[2..-1]

        @name = arguments[0].children[0]
        @version = arguments[1].children[0] if arguments[1]
      else
        @name = node_or_name
        @version = version
        @groups = opts[:groups]
      end
    end

    def to_node
      args = [nil, :gem, s(:str, name)]
      args << s(:str, version) if version
      args << s(:hash, groups_to_node) unless groups.empty?

      Parser::AST::Node.new(:send, args)
    end

    def ==(other)
      name == other.name &&
        version == other.version
    end

    def self.gem_node?(node)
      node.children[1] == :gem
    end

    attr_reader :name, :version

    def groups
      @groups ||= []
    end

    private

    def groups_to_node
      s(:pair,
        s(:sym, :group),
        if groups.length == 1
          s(:sym, groups[0])
        else
          s(:array, groups.map { |g| s(:sym, g) })
        end)
    end

    def s(type, *children)
      Parser::AST::Node.new(type, children)
    end

    def check_node!(node)
      return if self.class.gem_node?(node)
      fail ArgumentError, "Not a call to `gem`: #{node.inspect}"
    end
  end
end
