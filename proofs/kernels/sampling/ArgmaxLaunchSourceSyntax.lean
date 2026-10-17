import kernels.sampling.ArgmaxTraversalSource

namespace Inference.Kernels.Sampling.ArgmaxLaunchSourceSyntax
open Copy.ScalarCopySyntax (Tokens accept nameToken)
open ArgmaxShuffleSyntax (wordChar whitespace acceptMany natural)
set_option maxRecDepth 10000

-- A checked restricted grammar for the remaining launch phases. Fixed names
-- and operators are grammar terminals; source control constants remain data.
inductive Body where
  | initialize : Body
  | update : String → Body
  | partialStore : Nat → Body
  | finishLoop : Nat → Body
  | finishRead : Body
  | mergeRead : Nat → Nat → Nat → Body
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
    | _,_ => if ['(',')','[',']','{','}',';',',','=','+','*','-','<','?',':'].contains c then do
        pure (String.singleton c::(←lexAux fuel rest)) else none

def tokenize (source : String) := lexAux (source.length+1) source.toList

def complete (value : Body) (rest : Tokens) : Option Body := if rest=[] then some value else none

def parseInit (tokens : Tokens) : Option Body := do
  complete .initialize (←acceptMany ["float","best","=","-","INFINITY",";","uint","bestId","=","0xffffffffu",";"] tokens)
def parseUpdate (tokens : Tokens) : Option Body := do
  let rest ←acceptMany ["if","(","better","(","value",","] tokens
  let (id,rest) ←nameToken rest
  let rest ←acceptMany [",","best",",","bestId",")",")","{","best","=","value",";","bestId","="] rest
  let (assigned,rest) ←nameToken rest
  let rest ←acceptMany [";","}"] rest
  if assigned=id then complete (.update id) rest else none

def parsePartialStore (tokens : Tokens) : Option Body := do
  let rest ←acceptMany ["if","(","lane","=="] tokens
  let (owner,rest) ←natural rest
  complete (.partialStore owner) (←acceptMany [")","{","values","[","row","*","P","+","tile","]","=","best",";",
    "indices","[","row","*","P","+","tile","]","=","bestId",";","}"] rest)
def parseFinishLoop (tokens : Tokens) : Option Body := do
  let rest ←acceptMany ["for","(","uint","i","=","tid",";","i","<","P",";","i","+","="] tokens
  let (stride,rest) ←natural rest
  complete (.finishLoop stride) (←acceptMany [")","{"] rest)
def parseFinishRead (tokens : Tokens) : Option Body := do
  complete .finishRead (←acceptMany ["float","value","=","values","[","row","*","P","+","i","]",";",
    "uint","id","=","indices","[","row","*","P","+","i","]",";"] tokens)
def parseMergeRead (tokens : Tokens) : Option Body := do
  let rest ←acceptMany ["if","(","simd","=="] tokens
  let (group,rest) ←natural rest
  let rest ←acceptMany [")","{","best","=","lane","<"] rest
  let (scores,rest) ←natural rest
  let rest ←acceptMany ["?","scores","[","lane","]",":","-","INFINITY",";","bestId","=","lane","<"] rest
  let (ids,rest) ←natural rest
  complete (.mergeRead group scores ids) (←acceptMany ["?","ids","[","lane","]",":","0xffffffffu",";"] rest)

def parse (parser : Tokens → Option Body) (source : String) : Option Body := do parser (←tokenize source)

def initSource : String := "float best = -INFINITY;\n  uint bestId = 0xffffffffu;"
def partialUpdateSource : String := "if (better(value, i, best, bestId)) { best = value; bestId = i; }"
def finishUpdateSource : String := "if (better(value, id, best, bestId)) { best = value; bestId = id; }"
def partialStoreSource : String := "if (lane == 0) { values[row * P + tile] = best; indices[row * P + tile] = bestId; }"
def finishLoopSource : String := "for (uint i = tid; i < P; i += 128) {"
def finishReadSource : String := "float value = values[row * P + i];\n    uint id = indices[row * P + i];"
def mergeReadSource : String := "if (simd == 0) {\n    best = lane < 4 ? scores[lane] : -INFINITY;\n    bestId = lane < 4 ? ids[lane] : 0xffffffffu;"

def initSourceTokens : Tokens := ["float","best","=","-","INFINITY",";","uint","bestId","=","0xffffffffu",";"]
theorem lexed_initSource : tokenize initSource=some initSourceTokens := by decide +kernel
theorem parsed_initSource : parse parseInit initSource=some .initialize := by
  simp only [parse,lexed_initSource]
  decide +kernel

def partialUpdateSourceTokens : Tokens := ["if","(","better","(","value",",","i",",","best",",","bestId",")",")","{","best","=","value",";","bestId","=","i",";","}"]
theorem lexed_partialUpdateSource : tokenize partialUpdateSource=some partialUpdateSourceTokens := by decide +kernel
theorem parsed_partialUpdateSource : parse parseUpdate partialUpdateSource=some (.update "i") := by
  simp only [parse,lexed_partialUpdateSource]
  decide +kernel

def finishUpdateSourceTokens : Tokens := ["if","(","better","(","value",",","id",",","best",",","bestId",")",")","{","best","=","value",";","bestId","=","id",";","}"]
theorem lexed_finishUpdateSource : tokenize finishUpdateSource=some finishUpdateSourceTokens := by decide +kernel
theorem parsed_finishUpdateSource : parse parseUpdate finishUpdateSource=some (.update "id") := by
  simp only [parse,lexed_finishUpdateSource]
  decide +kernel

def partialStoreSourceTokens : Tokens := ["if","(","lane","==","0",")","{","values","[","row","*","P","+","tile","]","=","best",";","indices","[","row","*","P","+","tile","]","=","bestId",";","}"]
theorem lexed_partialStoreSource : tokenize partialStoreSource=some partialStoreSourceTokens := by decide +kernel
theorem parsed_partialStoreSource : parse parsePartialStore partialStoreSource=some (.partialStore 0) := by
  simp only [parse,lexed_partialStoreSource]
  decide +kernel

def finishLoopSourceTokens : Tokens := ["for","(","uint","i","=","tid",";","i","<","P",";","i","+","=","128",")","{"]
theorem lexed_finishLoopSource : tokenize finishLoopSource=some finishLoopSourceTokens := by decide +kernel
theorem parsed_finishLoopSource : parse parseFinishLoop finishLoopSource=some (.finishLoop 128) := by
  simp only [parse,lexed_finishLoopSource]
  decide +kernel

def finishReadSourceTokens : Tokens := ["float","value","=","values","[","row","*","P","+","i","]",";","uint","id","=","indices","[","row","*","P","+","i","]",";"]
theorem lexed_finishReadSource : tokenize finishReadSource=some finishReadSourceTokens := by decide +kernel
theorem parsed_finishReadSource : parse parseFinishRead finishReadSource=some .finishRead := by
  simp only [parse,lexed_finishReadSource]
  decide +kernel

def mergeReadSourceTokens : Tokens := ["if","(","simd","==","0",")","{","best","=","lane","<","4","?","scores","[","lane","]",":","-","INFINITY",";","bestId","=","lane","<","4","?","ids","[","lane","]",":","0xffffffffu",";"]
theorem lexed_mergeReadSource : tokenize mergeReadSource=some mergeReadSourceTokens := by decide +kernel
theorem parsed_mergeReadSource : parse parseMergeRead mergeReadSource=some (.mergeRead 0 4 4) := by
  simp only [parse,lexed_mergeReadSource]
  decide +kernel

end Inference.Kernels.Sampling.ArgmaxLaunchSourceSyntax
