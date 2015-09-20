module Unparser
  class Emitter
    class UnparenthesizedArguments < Unparser::Emitter::Send::Arguments
      private

      def dispatch
        return if children.empty?
        write(' ')
        delimited_plain(effective_arguments)
      end
    end
  end
end
