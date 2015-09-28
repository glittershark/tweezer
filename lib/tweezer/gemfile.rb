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

    def group_blocks
      @group_blocks ||= []
    end

    # rubocop:disable Metrics/AbcSize
    def add_gem(*args)
      gem = Gem.new(*args)
      fail GemAlreadyPresent if gems.include? gem
      gems << gem

      if group_blocks.include?(gem.groups)
        groups = gem.groups
        gem.groups = []
        append_to_group_block! gem.to_node, groups: groups
      else
        append_before_first_block! gem.to_node
      end
    end
    # rubocop:enable Metrics/AbcSize

    def dump
      Unparser.unparse(ast, comments)
    end

    private

    attr_reader :ast, :comments

    def load_from_ast!
    end

    def load_nodes!(nodes)
      nodes.each { |node| load_node! node }
    end

    def load_node!(node)
      gems << Gem.new(node) if Gem.gem_node? node
      group_blocks << groups_from_group_block(node) if group_block?(node)
      load_nodes! block_children(node) if block?(node)
    end

    def append_before_first_block!(new_node)
      nodes = ast.children.flat_map do |node|
        block?(node) ? [new_node, blank_line, node] : [node]
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

    def blank_line
      Parser::AST::Node.new(:blank_line)
    end
  end
end
