module Unparser
  class Emitter
    class Literal
      class Primitive < self
        class Inspect < self
          def dispatch
            return super unless value.is_a? String
            return super if value.include? "'"

            write("'#{value}'")
          end
        end
      end
    end
  end
end
