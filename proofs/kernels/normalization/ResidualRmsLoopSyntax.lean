import kernels.normalization.ResidualRmsCellSyntax

namespace Inference.Kernels.Normalization.ResidualRmsLoopSyntax
open Copy.ScalarCopySyntax (Tokens Parser wordChar accept decimal)
set_option maxRecDepth 10000

-- Restricted complete loop-shell grammar. Identifier, type, cast, comparison,
-- prefix increment and guarded-cell positions are fixed productions; numeric
-- counter initializers, bounds and stride multipliers are parsed into fields.
structure Control where
  outerStart : Nat
  outerMultiplier : Nat
  innerStart : Nat
  innerLimit : Nat
  columnMultiplier : Nat
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else match c,rest with
      | '+','='::rest => do pure ("+="::(←lexAux fuel rest))
      | '+','+'::rest => do pure ("++"::(←lexAux fuel rest))
      | _,_ => if ['(',')','{','}',';','=','+','*','<'].contains c then do
          pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def acceptAll : Tokens → Tokens → Option Tokens
  | [],tokens => some tokens
  | first::rest,tokens => do acceptAll rest (←accept first tokens)

def natural (unsigned : Bool) : Parser Nat := fun tokens => do
  match tokens with
  | token::rest =>
    let value ←if unsigned then
      if token.endsWith "u" then decimal (String.ofList (token.toList.dropLast)) else none
      else decimal token
    pure (value,rest)
  | [] => none

def parseTokens (tokens : Tokens) : Option Control := do
  let rest ←acceptAll ["for","(","uint","r","="] tokens
  let (outerStart,rest) ←natural false rest
  let rest ←acceptAll [";","r","<","uint","(","D",")",";","r","+=","uint","(","THREADS",")","*"] rest
  let (outerMultiplier,rest) ←natural true rest
  let rest ←acceptAll [")","{","for","(","uint","i","="] rest
  let (innerStart,rest) ←natural false rest
  let rest ←acceptAll [";","i","<"] rest
  let (innerLimit,rest) ←natural true rest
  let rest ←acceptAll [";","++","i",")","{","const","uint","col","=","r","+","tid","*"] rest
  let (columnMultiplier,rest) ←natural true rest
  let rest ←acceptAll ["+","i",";","if","(","col","<","uint","(","D",")",")","{","CELL",";","}","}","}"] rest
  if rest=[] then some ⟨outerStart,outerMultiplier,innerStart,innerLimit,columnMultiplier⟩ else none

def parseBody (source : String) : Option Control := do parseTokens (←tokenize source)

def sourceBody : String := r#"for (uint r = 0; r < uint(D); r += uint(THREADS) * 4u) {
    for (uint i = 0; i < 4u; ++i) {
      const uint col = r + tid * 4u + i;
      if (col < uint(D)) { CELL; }
    }
  }"#

def control : Control := ⟨0,4,0,4,4⟩
theorem parsed_body : parseBody sourceBody=some control := by decide +kernel

end Inference.Kernels.Normalization.ResidualRmsLoopSyntax
