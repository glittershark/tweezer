module Tweezer
  class Gem
    include Tweezer::ASTHelper

    def initialize(node_or_name, opts = {})
      return init_from_node(node_or_name) if node_or_name.is_a?(
        Parser::AST::Node)

      @name = node_or_name
      alter!(opts)
    end

    def alter!(opts)
      @version = opts[:version] if opts[:version]
      @groups = opts[:groups] if opts[:groups]
      @path = opts[:path] if opts[:path]
      @opts = (@opts || {}).merge(opts)
    end

    def to_node
      args = [nil, :gem, s(:str, name)]
      args << s(:str, version) if version
      opts_node = opts_to_node
      args << opts_node if opts_node

      Parser::AST::Node.new(:send, args)
    end

    def ==(other)
      name == other.name &&
        version == other.version
    end

    def self.gem_node?(node)
      node.children[1] == :gem
    end

    attr_reader :name
    attr_accessor :version, :path
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

      opts_h = unparse_hash_node(opts)
      @groups = groups_from_node(opts_h[:group])
      @path = path_from_node(opts_h[:path])
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

    def opts_to_node
      pairs = []
      pairs << groups_to_node unless groups.empty?
      pairs << s(:pair, s(:sym, :path), s(:str, path)) if path
      return if pairs.empty?
      s(:hash, *pairs)
    end

    def groups_from_node(node)
      return [] unless node
      case node.type
      when :sym then [node.children[0]]
      when :array then node.children.flat_map(&:children)
      else fail ArgumentError
      end
    end

    def path_from_node(node)
      return unless node
      fail ArgumentError unless node.type == :str
      node.children.first
    end

    def check_node!(node)
      return if self.class.gem_node?(node)
      fail ArgumentError, "Not a call to `gem`: #{node.inspect}"
    end
  end
end
