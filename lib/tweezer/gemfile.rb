require 'bundler'
require 'parser/current'
require 'unparser'

module Tweezer
  class Gemfile
    def initialize(source, file = nil)
      @ast, @comments = Parser::CurrentRuby.parse_with_comments(source, file)
      @file = file
    end

    def self.load(file = Bundler.default_gemfile)
      new(File.read(file), file)
    end

    def save!
      fail unless @file
      File.write(@file, dump)
    end

    def gems
      @gems ||= @ast.children.map do |node|
        next unless Gem.gem_node? node
        Gem.new(node)
      end.compact
    end

    def add_gem(*args)
      gem = Gem.new(*args)
      fail GemAlreadyPresent if gems.include? gem
      gems << gem
      append_before_first_source! gem.to_node
    end

    def dump
      Unparser.unparse(ast, comments)
    end

    private

    attr_reader :ast, :comments

    def append_before_first_source!(new_node)
      nodes = ast.children.flat_map do |node|
        source_block?(node) ? [new_node, blank_line, node] : [node]
      end
      nodes << new_node unless nodes.include? new_node

      @ast = @ast.updated(nil, nodes)
    end

    def source_block?(node)
      node.type == :block &&
        node.children[0].type == :send &&
        node.children[0].children[1] == :source
    end

    def blank_line
      Parser::AST::Node.new(:blank_line)
    end
  end
end
