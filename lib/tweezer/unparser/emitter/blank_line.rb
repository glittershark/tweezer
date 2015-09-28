require 'unparser'

module Unparser
  class Emitter
    old = REGISTRY.dup
    remove_const :REGISTRY
    const_set :REGISTRY, old.dup

    class BlankLine < self
      handle :blank_line

      private

      def dispatch; end
    end

    REGISTRY.freeze
  end
end
