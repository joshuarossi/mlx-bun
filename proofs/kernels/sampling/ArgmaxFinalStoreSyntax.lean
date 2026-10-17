import kernels.sampling.ArgmaxShuffleSyntax

namespace Inference.Kernels.Sampling.ArgmaxFinalStoreSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
open ArgmaxShuffleSyntax (wordChar whitespace acceptMany natural)
set_option maxRecDepth 10000

structure Store where
  guardVariable : String
  guardValue : Nat
  destination : String
  index : String
  value : String
  deriving DecidableEq, Repr

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if whitespace c then lexAux fuel (rest.dropWhile whitespace)
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else match c,rest with
    | '=','='::tail => do pure ("=="::(←lexAux fuel tail))
    | _,_ => if ['(',')','[',']',';','='].contains c then do
        pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) := lexAux (source.length+1) source.toList

def parseTokens (tokens : Tokens) : Option Store := do
  let rest ←acceptMany ["if","("] tokens
  let (guardVariable,rest) ←nameToken rest
  let rest ←accept "==" rest
  let (guardValue,rest) ←natural rest
  let rest ←accept ")" rest
  let (destination,rest) ←nameToken rest
  let rest ←accept "[" rest
  let (index,rest) ←nameToken rest
  let rest ←acceptMany ["]","="] rest
  let (value,rest) ←nameToken rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨guardVariable,guardValue,destination,index,value⟩ else none

def parse (source : String) : Option Store := do parseTokens (←tokenize source)
def sourceBody : String := "if (lane == 0) out[row] = bestId;"
def tokens : Tokens := ["if","(","lane","==","0",")","out","[","row","]","=","bestId",";"]
def body : Store := ⟨"lane",0,"out","row","bestId"⟩
theorem lexed : tokenize sourceBody=some tokens := by decide +kernel
theorem parsed : parse sourceBody=some body := by
  simp only [parse,lexed]
  decide +kernel

end Inference.Kernels.Sampling.ArgmaxFinalStoreSyntax
