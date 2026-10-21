import metal.Lexer
import metal.Preprocess
import metal.Parser

namespace Metal

/-- The syntax of a compiled kernel text (MLX's assembled source, without
the `metal::utils()` preamble): lexed, preprocessed, parsed. -/
def frontend (text : List Char) : Option (List Top) :=
  (preprocess (lex text)).bind parseUnit

end Metal
