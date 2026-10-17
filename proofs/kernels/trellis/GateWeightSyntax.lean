import kernels.trellis.PackedArraySyntax
namespace Inference.Kernels.Trellis.GateWeightSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken)
set_option maxRecDepth 10000

structure Scale where
  target : String
  array : String
  index : PackedArraySyntax.Expr
  deriving Repr
structure Weight where
  target : String
  function : String
  table : String
  words : String
  virtual : String
  offset : PackedArraySyntax.Expr
  level : PackedArraySyntax.Expr
  scale : String
  deriving Repr

def scaleTokens : Parser Scale := fun ts => do
  let ts ←accept "const" ts
  let ts ←accept "float" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let ts ←accept "float" ts
  let ts ←accept "(" ts
  let (array,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept "]" ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  pure (⟨target,array,index⟩,ts)

def weightTokens : Parser Weight := fun ts => do
  let ts ←accept "const" ts
  let ts ←accept "float" ts
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
  let (offset,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept "," ts
  let (level,ts) ←PackedArraySyntax.expression 8 0 ts
  let ts ←accept ")" ts
  let ts ←accept "*" ts
  let (scale,ts) ←nameToken ts
  let ts ←accept ";" ts
  pure (⟨target,function,table,words,virtual,offset,level,scale⟩,ts)

def parseScale (source : String) : Option Scale := do
  let (actual,rest) ←scaleTokens (←PackedArraySyntax.tokenize source)
  if rest=[] then some actual else none

def parseWeight (source : String) : Option Weight := do
  let (actual,rest) ←weightTokens (←PackedArraySyntax.tokenize source)
  if rest=[] then some actual else none

def gateScaleSource : String := "const float gScale = float(gscales[row]);"
def upScaleSource : String := "const float uScale = float(uscales[row]);"
def gateWeightSource : String := "const float gWeight = trellis_codebook_window(table, g, gv, (31u - j) * (uint)KG, (uint)L) * gScale;"
def upWeightSource : String := "const float uWeight = trellis_codebook_window(table, u, uv, (31u - j) * (uint)KU, (uint)L) * uScale;"
def scaleAST (isUp : Bool) : Scale := ⟨if isUp then "uScale" else "gScale",if isUp then "uscales" else "gscales",.variable "row"⟩
def weightAST (isUp : Bool) : Weight := ⟨if isUp then "uWeight" else "gWeight","trellis_codebook_window","table",
  if isUp then "u" else "g",if isUp then "uv" else "gv",
  .multiply (.subtract (.literal .unsigned 31) (.variable "j")) (.castUInt (.variable (if isUp then "KU" else "KG"))),
  .castUInt (.variable "L"),if isUp then "uScale" else "gScale"⟩

theorem parsed_scales : ∀ isUp : Bool,
    parseScale (if isUp then upScaleSource else gateScaleSource)=some (scaleAST isUp) := by intro isUp; cases isUp <;> rfl
theorem parsed_weights : ∀ isUp : Bool,
    parseWeight (if isUp then upWeightSource else gateWeightSource)=some (weightAST isUp) := by intro isUp; cases isUp <;> rfl
end Inference.Kernels.Trellis.GateWeightSyntax
