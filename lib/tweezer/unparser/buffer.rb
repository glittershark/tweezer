module Unparser
  class Buffer
    def current_line
      content.count("\n") + 1
    end
  end
end
