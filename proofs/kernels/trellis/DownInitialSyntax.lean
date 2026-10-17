import kernels.trellis.DownLaneSource
import kernels.trellis.GateTailSyntax
namespace Inference.Kernels.Trellis.DownInitialSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
set_option maxRecDepth 10000

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c || c='.' then do
      let word := fun c => wordChar c || c='.'
      pure (String.ofList (c::rest.takeWhile word)::(←lexAux fuel (rest.dropWhile word)))
    else if c='+' then match rest with
      | '+'::rest => do pure ("++"::(←lexAux fuel rest))
      | _ => do pure ("+"::(←lexAux fuel rest))
    else if ['(',')','[',']',';','=','<'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

structure Declaration where
  target : String
  dimension : PackedArraySyntax.Expr
  deriving Repr
structure Initializer where
  counter : String
  start : PackedArraySyntax.Expr
  test : String
  bound : PackedArraySyntax.Expr
  increment : String
  target : String
  index : PackedArraySyntax.Expr
  value : GateTailSyntax.Expr
  deriving Repr

def declarationTokens : Parser Declaration := fun ts => do
  let ts ←accept "float" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (dimension,ts) ←PackedArraySyntax.expression 16 0 ts
  let ts ←accept "]" ts
  let ts ←accept ";" ts
  pure (⟨target,dimension⟩,ts)

def initializerTokens : Parser Initializer := fun ts => do
  let ts ←accept "uint" (←accept "(" (←accept "for" ts))
  let (counter,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (start,ts) ←PackedArraySyntax.expression 16 0 ts
  let ts ←accept ";" ts
  let (test,ts) ←nameToken ts
  let ts ←accept "<" ts
  let (bound,ts) ←PackedArraySyntax.expression 16 0 ts
  let ts ←accept ";" ts
  let ts ←accept "++" ts
  let (increment,ts) ←nameToken ts
  let ts ←accept ")" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←PackedArraySyntax.expression 16 0 ts
  let ts ←accept "]" ts
  let ts ←accept "=" ts
  let (value,ts) ←GateTailSyntax.expression 16 0 ts
  let ts ←accept ";" ts
  pure (⟨counter,start,test,bound,increment,target,index,value⟩,ts)

def parse {α : Type} (parser : Parser α) (source : String) : Option α := do
  let (code,rest) ←parser (←lexAux (source.length+1) source.toList)
  if rest=[] then some code else none

def declarationSource : String := "float acc[P];"
def initializerSource : String := "for (uint i = 0; i < (uint)P; ++i) acc[i] = 0.0f;"
def declaration : Declaration := ⟨"acc",.variable "P"⟩
def initializer : Initializer := ⟨"i",.literal .signed 0,"i",.castUInt (.variable "P"),"i","acc",.variable "i",.floating 0 1⟩
theorem parsed_declaration : parse declarationTokens declarationSource=some declaration := rfl
theorem parsed_initializer : parse initializerTokens initializerSource=some initializer := rfl
end Inference.Kernels.Trellis.DownInitialSyntax
