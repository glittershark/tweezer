module Tweezer
  class Gem
    include Tweezer::ASTHelper

    def initialize(node_or_name, version = nil, opts = {})
      return init_from_node(node_or_name) if node_or_name.is_a?(
        Parser::AST::Node)

      @name = node_or_name

      if version.is_a? Hash
        @version = nil
        opts = version
      else
        @version = version
      end

      @groups = opts[:groups]
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
    attr_writer :groups

    def groups
      @groups ||= []
    end

    private

    # rubocop:disable Metrics/AbcSize
    def init_from_node(node)
      check_node!(node)
      arguments = node.children[2..-1]
      opts = arguments.pop if arguments[-1].type == :hash

      @name = arguments[0].children[0]
      @version = arguments[1].children[0] if arguments[1]

      return unless opts
      @groups = groups_from_node(unparse_hash_node(opts)[:group])
    end
    # rubocop:enable Metrics/AbcSize

    def groups_to_node
      s(:pair,
        s(:sym, :group),
        if groups.length == 1
          s(:sym, groups[0])
        else
          s(:array, groups.map { |g| s(:sym, g) })
        end)
    end

    def groups_from_node(node)
      case node.type
      when :sym then [node.children[0]]
      when :array then node.children.flat_map(&:children)
      else fail ArgumentError
      end
    end

    def check_node!(node)
      return if self.class.gem_node?(node)
      fail ArgumentError, "Not a call to `gem`: #{node.inspect}"
    end
  end
end
