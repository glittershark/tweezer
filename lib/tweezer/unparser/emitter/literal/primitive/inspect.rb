module Unparser
  class Emitter
    class Literal
      class Primitive < self
        class Inspect < self
          def dispatch
            return write_inspect unless value.is_a? String
            return write_inspect if value.include? "'"

            write("'#{value}'")
          end

          private

          def write_inspect
            write(value.inspect)
          end
        end
      end
    end
  end
end
