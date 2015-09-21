module Unparser
  class Emitter
    def write_to_buffer
      emit_comments_before if buffer.fresh_line?
      fix_newlines
      dispatch
      comments.consume(node)
      emit_eof_comments if parent.is_a?(Root)
      self
    end

    def fix_newlines
      (node.loc.line - buffer.current_line).times { buffer.nl } if node.loc
    end
  end
end
