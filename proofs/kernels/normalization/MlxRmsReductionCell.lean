import kernels.normalization.MlxRmsLoopMemory

namespace Inference.Kernels.Normalization.MlxRmsReductionCell
open Contracts.Mlx MlxRmsOutputSyntax
open Copy.ScalarCopySyntax (accept)
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open MlxRmsOutputSemantics (Value Environment)
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

structure Body where
  declared : String
  input : Expr
  target : String
  product : Expr
  deriving DecidableEq, Repr

def parseBody (source : String) : Option Body := do
  let tokens ←tokenize source
  let rest ←accept "float" tokens
  let (declared,rest) ←nameToken rest
  let rest ←accept "=" rest
  let (input,rest) ←indexed sum rest
  let rest ←accept ";" rest
  let (target,rest) ←nameToken rest
  let rest ←accept "+" rest
  let rest ←accept "=" rest
  let (product,rest) ←MlxRmsOutputSyntax.product varExpr varExpr rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨declared,input,target,product⟩ else none

def sourceBody : String := r#"float xi = x[i + r];
        acc += xi * xi;"#
def sourceTailBody : String := r#"float xi = x[i + r];
          acc += xi * xi;"#
def body : Body := ⟨"xi",.index "x" (.add (.var "i") (.var "r")),"acc",.mul (.var "xi") (.var "xi")⟩
theorem parsed_body : parseBody sourceBody=some body := by decide +kernel
theorem parsed_tail_body : parseBody sourceTailBody=some body := by decide +kernel

def step (contracted : Bool) (value acc : Float32) : Float32 :=
  if contracted then FlushToZero.fma value value acc else FlushToZero.add acc (FlushToZero.mul value value)

-- Restricted execution grammar validates all identifiers and input-index/
-- product nodes. The float declaration widens BF16 before multiplication;
-- contraction is explicit and does not reorder loop accumulations.
def execute (contracted : Bool) (source r i : Nat) (acc : Float32)
    (memory : HalfMemory.Bytes) (body : Body) : Option Float32 :=
  match body.declared,body.input,body.target,body.product with
  | "xi",.index "x" (.add (.var "i") (.var "r")),"acc",.mul (.var "xi") (.var "xi") =>
    some (step contracted (BFloat16.widen (Model.ofBits (HalfMemory.load memory (source+2*((i+r)%2^32))))) acc)
  | _,_,_,_ => none

theorem execution (contracted : Bool) (source r i : Nat) (small : r+i<2^32)
    (acc : Float32) (memory : HalfMemory.Bytes) :
    execute contracted source r i acc memory body=some (step contracted
      (BFloat16.widen (Model.ofBits (HalfMemory.load memory (source+2*(r+i))))) acc) := by
  have index : (i+r)%2^32=r+i := by rw [Nat.add_comm i r,Nat.mod_eq_of_lt small]
  change some (step contracted (BFloat16.widen (Model.ofBits (HalfMemory.load memory (source+2*((i+r)%2^32))))) acc)=_
  rw [index]

def executeSource (text : String) (contracted : Bool) (source r i : Nat)
    (acc : Float32) (memory : HalfMemory.Bytes) : Option Float32 := do
  execute contracted source r i acc memory (←parseBody text)

theorem source_execution (contracted : Bool) (source r i : Nat) (small : r+i<2^32)
    (acc : Float32) (memory : HalfMemory.Bytes) :
    executeSource sourceBody contracted source r i acc memory=some (step contracted
      (BFloat16.widen (Model.ofBits (HalfMemory.load memory (source+2*(r+i))))) acc) := by
  unfold executeSource
  rw [parsed_body]
  exact execution _ _ _ _ small _ _

theorem tail_source_execution (contracted : Bool) (source r i : Nat) (small : r+i<2^32)
    (acc : Float32) (memory : HalfMemory.Bytes) :
    executeSource sourceTailBody contracted source r i acc memory=some (step contracted
      (BFloat16.widen (Model.ofBits (HalfMemory.load memory (source+2*(r+i))))) acc) := by
  unfold executeSource
  rw [parsed_tail_body]
  exact execution _ _ _ _ small _ _

end Inference.Kernels.Normalization.MlxRmsReductionCell
