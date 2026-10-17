import kernels.copy.ScalarCopySyntax

namespace Inference.Kernels.Normalization.MlxRmsLoopSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept decimal)
set_option maxRecDepth 10000

-- Fixed productions retain uint r, signed int i, both comparisons, the
-- full-block predicate, lsize*N_READS stride, postincrements and guarded tail.
-- Numeric initializers are parsed rather than discarded. CELL stands only for
-- a separately parsed arithmetic body; the host guard binds both loop shells.
structure Control where
  outerStart : Nat
  fullStart : Nat
  tailStart : Nat
  deriving DecidableEq, Repr

def word (c : Char) : Bool :=
  ('a'≤c && c≤'z') || ('A'≤c && c≤'Z') || ('0'≤c && c≤'9') || c=='_'
def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lexAux fuel rest
    else if word c then do
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else match c,rest with
      | '+','='::rest => do pure ("+="::(←lexAux fuel rest))
      | '+','+'::rest => do pure ("++"::(←lexAux fuel rest))
      | '<','='::rest => do pure ("<="::(←lexAux fuel rest))
      | _,_ => if ['(',')','{','}',';','=','+','*','<'].contains c then do
          pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList
def acceptAll : Tokens → Tokens → Option Tokens
  | [],tokens => some tokens
  | token::rest,tokens => do acceptAll rest (←accept token tokens)
def natural : Parser Nat
  | token::rest => do pure (←decimal token,rest)
  | [] => none

def parseTokens (tokens : Tokens) : Option Control := do
  let rest ←acceptAll ["for","(","uint","r","="] tokens
  let (outerStart,rest) ←natural rest
  let rest ←acceptAll [";","r","<","axis_size",";","r","+=","lsize","*","N_READS",")","{",
    "if","(","r","+","lid","*","N_READS","+","N_READS","<=","axis_size",")","{",
    "for","(","int","i","="] rest
  let (fullStart,rest) ←natural rest
  let rest ←acceptAll [";","i","<","N_READS",";","i","++",")","{","CELL",";","}","}","else","{",
    "for","(","int","i","="] rest
  let (tailStart,rest) ←natural rest
  let rest ←acceptAll [";","i","<","N_READS",";","i","++",")","{","if","(","(","r","+","lid","*","N_READS","+","i",")","<","axis_size",")","{","CELL",";","}","}","}","}"] rest
  if rest=[] then some ⟨outerStart,fullStart,tailStart⟩ else none

def parseBody (source : String) : Option Control := do parseTokens (←tokenize source)

def sourceBody : String := r#"for (uint r = 0; r < axis_size; r += lsize * N_READS) {
    if (r + lid * N_READS + N_READS <= axis_size) {
      for (int i = 0; i < N_READS; i++) { CELL; }
    } else {
      for (int i = 0; i < N_READS; i++) {
        if ((r + lid * N_READS + i) < axis_size) { CELL; }
      }
    }
  }"#
def control : Control := ⟨0,0,0⟩
theorem parsed_body : parseBody sourceBody=some control := by decide +kernel

end Inference.Kernels.Normalization.MlxRmsLoopSyntax
