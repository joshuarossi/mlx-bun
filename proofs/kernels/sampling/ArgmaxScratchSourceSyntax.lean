import kernels.sampling.ArgmaxShuffleSyntax

namespace Inference.Kernels.Sampling.ArgmaxScratchSourceSyntax
open Copy.ScalarCopySyntax (Tokens accept)
open ArgmaxShuffleSyntax (wordChar whitespace acceptMany natural)
set_option maxRecDepth 10000

structure Body where
  scoreCount : Nat
  idCount : Nat
  ownerLane : Nat
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
    | ':',':'::tail => do pure ("::"::(←lexAux fuel tail))
    | _,_ => if ['(',')','[',']','{','}',';','='].contains c then do
        pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) := lexAux (source.length+1) source.toList

def parseTokens (tokens : Tokens) : Option Body := do
  let rest ←acceptMany ["threadgroup","float","scores","["] tokens
  let (scoreCount,rest) ←natural rest
  let rest ←acceptMany ["]",";","threadgroup","uint","ids","["] rest
  let (idCount,rest) ←natural rest
  let rest ←acceptMany ["]",";","if","(","lane","=="] rest
  let (ownerLane,rest) ←natural rest
  let rest ←acceptMany [")","{","scores","[","simd","]","=","best",";","ids","[","simd","]","=","bestId",";","}",
    "threadgroup_barrier","(","mem_flags","::","mem_threadgroup",")",";"] rest
  if rest=[] then some ⟨scoreCount,idCount,ownerLane⟩ else none

def parse (source : String) : Option Body := do parseTokens (←tokenize source)
def sourceBody : String := r#"threadgroup float scores[4];
  threadgroup uint ids[4];
  if (lane == 0) { scores[simd] = best; ids[simd] = bestId; }
  threadgroup_barrier(mem_flags::mem_threadgroup);"#
def tokens : Tokens := ["threadgroup","float","scores","[","4","]",";","threadgroup","uint","ids","[","4","]",";",
  "if","(","lane","==","0",")","{","scores","[","simd","]","=","best",";","ids","[","simd","]","=","bestId",";","}",
  "threadgroup_barrier","(","mem_flags","::","mem_threadgroup",")",";"]
def body : Body := ⟨4,4,0⟩
theorem lexed : tokenize sourceBody=some tokens := by decide +kernel
theorem parsed : parse sourceBody=some body := by
  simp only [parse,lexed]
  decide +kernel

end Inference.Kernels.Sampling.ArgmaxScratchSourceSyntax
