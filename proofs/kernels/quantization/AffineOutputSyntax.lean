import kernels.trellis.GateRowSyntax

namespace Inference.Kernels.Quantization.AffineOutputSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken decimal)
open Trellis.GateRowSyntax (Expr Constant)
set_option maxRecDepth 10000

-- Retain the actual builtin component, signed destination and grouped
-- expression. The native parameter values are attached by selected semantics.
def parseRow (source : String) : Option Constant := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←accept "const" ts
  let ts ←accept "int" ts
  let (name,ts) ←nameToken ts
  let ts ←accept "=" ts
  let ts ←accept "(" ts
  let (inner,ts) ←Trellis.GateRowSyntax.expression 16 0 ts
  let ts ←accept ")" ts
  let ts ←accept "*" ts
  let (width,ts) ←nameToken ts
  let ts ←accept ";" ts
  if ts=[] then some ⟨name,.multiply inner (.variable width)⟩ else none

structure Loop where
  counter : String
  initial : Nat
  condition : String
  bound : String
  increment : String
  deriving DecidableEq, Repr
structure Projection where
  target : String
  reduce : String
  array : String
  index : String
  deriving DecidableEq, Repr
structure Store where
  lane : String
  selected : Nat
  target : String
  base : String
  offset : String
  cast : String
  value : String
  deriving DecidableEq, Repr

def parseLoop (source : String) : Option Loop := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←accept "for" ts
  let ts ←accept "(" ts
  let ts ←accept "int" ts
  let (counter,ts) ←nameToken ts
  let ts ←accept "=" ts
  let value::ts := ts | none
  let initial ←decimal value
  let ts ←accept ";" ts
  let (condition,ts) ←nameToken ts
  let ts ←accept "<" ts
  let (bound,ts) ←nameToken ts
  let ts ←accept ";" ts
  let (increment,ts) ←nameToken ts
  let ts ←accept "++" ts
  let ts ←accept ")" ts
  if ts=[] then some ⟨counter,initial,condition,bound,increment⟩ else none

def parseProjection (source : String) : Option Projection := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←accept "const" ts
  let ts ←accept "float" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (reduce,ts) ←nameToken ts
  let ts ←accept "(" ts
  let (array,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (index,ts) ←nameToken ts
  let ts ←accept "]" ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  if ts=[] then some ⟨target,reduce,array,index⟩ else none

def parseStore (source : String) : Option Store := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←accept "if" ts
  let ts ←accept "(" ts
  let (lane,ts) ←nameToken ts
  let ts ←accept "=" ts
  let ts ←accept "=" ts
  let value::ts := ts | none
  let selected ←decimal value
  let ts ←accept ")" ts
  let (target,ts) ←nameToken ts
  let ts ←accept "[" ts
  let (base,ts) ←nameToken ts
  let ts ←accept "+" ts
  let (offset,ts) ←nameToken ts
  let ts ←accept "]" ts
  let ts ←accept "=" ts
  let ts ←accept "static_cast" ts
  let ts ←accept "<" ts
  let (cast,ts) ←nameToken ts
  let ts ←accept ">" ts
  let ts ←accept "(" ts
  let (value,ts) ←nameToken ts
  let ts ←accept ")" ts
  let ts ←accept ";" ts
  if ts=[] then some ⟨lane,selected,target,base,offset,cast,value⟩ else none

def parseConfig (source : String) : Option (Nat × Nat) := do
  let ts ←Trellis.GateInputSyntax.tokenize source
  let ts ←accept "const" ts
  let ts ←accept "R" ts
  let ts ←accept "=" ts
  let r::ts := ts | none
  let rows ←decimal r
  let ts ←accept "," ts
  let ts ←accept "S" ts
  let ts ←accept "=" ts
  let s::ts := ts | none
  let groups ←decimal s
  let ts ←accept ";" ts
  if ts=[] then some (rows,groups) else none

def configSource : String := "const R = 4, S = 16;"
theorem parsed_config : parseConfig configSource=some (4,16) := by decide +kernel

def rowSource : String := "const int row0 = (threadgroup_position_in_grid.y * S + sg) * R;"
def loopSource : String := "for (int r = 0; r < R; r++)"
def projectionSource : String := "const float v = simd_sum(result[r]);"
def storeSource : String := "if (lane == 0) y[row0 + r] = static_cast<T>(v);"
def row : Constant := ⟨"row0",.multiply
  (.add (.multiply (.builtin "threadgroup_position_in_grid" "y") (.variable "S")) (.variable "sg")) (.variable "R")⟩
def loop : Loop := ⟨"r",0,"r","R","r"⟩
def projection : Projection := ⟨"v","simd_sum","result","r"⟩
def store : Store := ⟨"lane",0,"y","row0","r","T","v"⟩

theorem parsed_row : parseRow rowSource=some row := by decide +kernel
theorem parsed_loop : parseLoop loopSource=some loop := by decide +kernel
theorem parsed_projection : parseProjection projectionSource=some projection := by decide +kernel
theorem parsed_store : parseStore storeSource=some store := by decide +kernel

end Inference.Kernels.Quantization.AffineOutputSyntax
