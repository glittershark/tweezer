require 'bundler'
require 'parser/current'
require 'unparser'

module Tweezer
  class Gemfile
    include Tweezer::ASTHelper

    def initialize(source, file = nil)
      @ast, @comments = Parser::CurrentRuby.parse_with_comments(source, file)
      @file = file

      load_nodes!(@ast.children)
    end

    def self.load(file = Bundler.default_gemfile)
      new(File.read(file), file)
    end

    def save!
      fail unless @file
      File.write(@file, dump)
    end

    def gems
      @gems ||= []
    end

    # Maps arrays of groups to arrays of Gems
    def groups
      @groups ||= Hash.new { |h, k| h[k] = [] }
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def add_gem(*args)
      gem = Gem.new(*args)
      fail GemAlreadyPresent if gems.include? gem
      gems << gem

      if groups.include?(gem.groups)
        gem_groups = gem.groups
        gem.groups = []

        if groups[gem_groups].size == 1
          gem_to_group_block!(groups[gem_groups].first)
        end

        append_to_group_block! gem.to_node, groups: gem_groups
      else
        groups[gem.groups] = [gem] unless gem.groups.empty?
        append_before_first_block! gem.to_node
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def alter_gem(name, **options)
      gem = gems.find { |g| g.name == name } || fail(GemNotPresent)
      old_node = gem.to_node
      gem.version = options[:version]
      replace_gem!(old_node, gem.to_node)
    end

    def dump
      dumped = Unparser.unparse(ast, comments).dup
      dumped << "\n" unless dumped[-1] == "\n"
      dumped
    end

    private

    attr_reader :ast, :comments

    def load_nodes!(nodes)
      nodes.map { |node| load_node! node }.compact
    end

    def load_node!(node)
      return load_block_node!(node) if block? node
      return unless Gem.gem_node?(node)

      gem = Gem.new(node)
      gems << gem
      groups[gem.groups] << gem unless gem.groups.empty?
      gem
    end

    def load_block_node!(node)
      fail ArgumentError unless block?(node)
      gems = load_nodes!(block_children(node))
      groups[groups_from_group_block(node)].concat(gems) if group_block?(node)
      nil
    end

    def append_before_first_block!(new_node)
      appended = false
      nodes = ast.children.flat_map do |node|
        if block?(node) && !appended
          appended = true
          next [new_node, blank_line, node, blank_line]
        end

        [node]
      end
      nodes << new_node unless nodes.include? new_node

      @ast = @ast.updated(nil, nodes)
    end

    def append_to_group_block!(new_node, groups: [])
      nodes = ast.children.map do |node|
        if group_block?(node) && groups_from_group_block(node) == groups
          append_block_child(node, new_node)
        else
          node
        end
      end

      @ast = @ast.updated(nil, nodes)
    end

    def replace_gem!(old_node, new_node)
      nodes = ast.children.map { |node| node == old_node ? new_node : node }
      @ast = @ast.updated(nil, nodes)
    end

    def gem_to_group_block!(gem)
      nodes = ast.children.flat_map do |node|
        next [node] unless node == gem.to_node

        gem_groups = gem.groups
        gem.groups = []

        [blank_line, group_block(gem_groups, gem), blank_line]
      end

      @ast = @ast.updated(nil, nodes)
    end

    def group_block(groups, *gems)
      s(:block,
        s(:send, nil, :group,
          *(groups.map { |group| s(:sym, group) })),
        s(:args),
        *gems.map(&:to_node))
    end
  end
end
