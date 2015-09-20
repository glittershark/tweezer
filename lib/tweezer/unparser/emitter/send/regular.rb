module Unparser
  class Emitter
    class Send
      class Regular < self
        def emit_arguments
          case
          when arguments.empty? && receiver.nil? && local_variable_clash?
            write('()')
          when Tweezer.unparenthesized_method?(selector)
            run(UnparenthesizedArguments, n(:arguments, arguments))
          else
            run(Arguments, n(:arguments, arguments))
          end
        end
      end
    end
  end
end
