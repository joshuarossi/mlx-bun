import kernels.trellis.GateWeightSyntax
namespace Inference.Kernels.Trellis.DownStepSyntax
open Copy.ScalarCopySyntax (Parser accept nameToken)
open PackedArraySyntax
set_option maxRecDepth 10000
structure Read where
  target : String
  indices : List Expr
  array : String
  index : Expr
  deriving Repr
structure Window where
  target : String
  function : String
  table : String
  words : String
  virtual : String
  offset : Expr
  level : Expr
  deriving Repr
structure Step where
  target : String
  indices : List Expr
  weight : Expr
  input : Expr
  previous : Expr
  deriving Repr

def readTokens (declared : Bool) : Parser Read := fun ts => do
  let ts ←if declared then do accept "float" (←accept "const" ts) else some ts
  let (target,ts) ←nameToken ts
  let (indices,ts) ←subscripts 16 ts
  let ts ←accept "=" ts
  let ts ←accept "float" ts
  let ts ←accept "(" ts
  let (array,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←expression 16 0 ts
  let ts ←accept "]" ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  pure (⟨target,indices,array,index⟩,ts)

def windowTokens : Parser Window := fun ts => do
  let ts ←accept "float" (←accept "const" ts)
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (function,ts) ←nameToken ts
  let ts ←accept "(" ts
  let (table,ts) ←nameToken ts
  let ts ←accept "," ts
  let (words,ts) ←nameToken ts
  let ts ←accept "," ts
  let (virtual,ts) ←nameToken ts
  let ts ←accept "," ts
  let (offset,ts) ←expression 16 0 ts
  let ts ←accept "," ts
  let (level,ts) ←expression 16 0 ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  pure (⟨target,function,table,words,virtual,offset,level⟩,ts)

def stepTokens : Parser Step := fun ts => do
  let (target,ts) ←nameToken ts
  let (indices,ts) ←subscripts 16 ts
  let ts ←accept "=" ts
  let ts ←accept "metal" ts
  let ts ←accept ":" ts
  let ts ←accept ":" ts
  let ts ←accept "fma" ts
  let ts ←accept "(" ts
  let (weight,ts) ←expression 16 0 ts
  let ts ←accept "," ts
  let (input,ts) ←expression 16 0 ts
  let ts ←accept "," ts
  let (previous,ts) ←expression 16 0 ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  pure (⟨target,indices,weight,input,previous⟩,ts)

def tokenize (source : String) : Option (List String) := PackedArraySyntax.tokenize source

def parse {α : Type} (parser : Parser α) (source : String) : Option α := do
  let (code,rest) ←parser (←tokenize source)
  if rest=[] then some code else none

def pairInputSource : String := "xr[u] = float(x[r0 + r + u]);"
def pairScaleSource : String := "sr[u] = float(scales[r0 + r + u]);"
def tailInputSource : String := "const float xr = float(x[r0 + r]);"
def tailScaleSource : String := "const float sr = float(scales[r0 + r]);"
def windowSource : String := "const float code = trellis_codebook_window(table, w, v, i * (uint)K, (uint)L);"
def pairStepSource : String := "acc[i] = metal::fma(code * sr[u], xr[u], acc[i]);"
def tailStepSource : String := "acc[i] = metal::fma(code * sr, xr, acc[i]);"
private def v := Expr.variable
open Expr in
def row (paired : Bool) : Expr := if paired then add (add (v "r0") (v "r")) (v "u") else add (v "r0") (v "r")
def read (paired scale : Bool) : Read := ⟨if scale then "sr" else "xr",if paired then [v "u"] else [],
  if scale then "scales" else "x",row paired⟩
open Expr in
def window : Window := ⟨"code","trellis_codebook_window","table","w","v",multiply (v "i") (castUInt (v "K")),castUInt (v "L")⟩
open Expr in
def step (paired : Bool) : Step := ⟨"acc",[v "i"],multiply (v "code") (if paired then index "sr" [v "u"] else v "sr"),
  if paired then index "xr" [v "u"] else v "xr",index "acc" [v "i"]⟩

theorem parsed_reads : ∀ paired scale : Bool,
    parse (readTokens (!paired)) (if paired then (if scale then pairScaleSource else pairInputSource)
      else (if scale then tailScaleSource else tailInputSource))=some (read paired scale) := by
  intro paired scale; cases paired <;> cases scale <;> rfl

theorem parsed_window : parse windowTokens windowSource=some window := rfl
theorem parsed_steps : ∀ paired : Bool,
    parse stepTokens (if paired then pairStepSource else tailStepSource)=some (step paired) := by
  intro paired; cases paired <;> rfl
end Inference.Kernels.Trellis.DownStepSyntax
