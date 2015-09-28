module Tweezer
  module ASTHelper
    def s(type, *children)
      Parser::AST::Node.new(type, children)
    end

    def blank_line
      Parser::AST::Node.new(:blank_line)
    end

    def block?(node)
      node.type == :block
    end

    def source_block?(node)
      block?(node) &&
        node.children[0].type == :send &&
        node.children[0].children[1] == :source
    end

    def group_block?(node)
      block?(node) &&
        node.children[0].type == :send &&
        node.children[0].children[1] == :group
    end

    def block_children(node)
      child = node.children[2]
      children = child.type == :begin ? child.children : [child]
      return children unless block_given?
      children.each { |c| yield c }
    end

    def groups_from_group_block(node)
      node.children[0].children[2..-1].flat_map(&:children)
    end

    def unparse_hash_node(node)
      fail ArgumentError unless node.type == :hash
      node.children.map do |child|
        [child.children[0].children[0], child.children[1]]
      end.to_h
    end

    def append_block_child(block, node)
      new_children = block.children[0..1]
      old_child = block.children[2]

      if old_child.type == :begin
        new_children << old_child.append(node)
      else
        new_children << s(:begin, old_child, node)
      end

      block.updated(nil, new_children)
    end

    module_function :s, :block?, :source_block?, :group_block?, :block_children,
                    :groups_from_group_block, :unparse_hash_node,
                    :append_block_child
  end
end
