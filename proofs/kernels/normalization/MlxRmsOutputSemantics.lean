import kernels.normalization.MlxRmsOutputSyntax
import kernels.RmsNormMemory
import contracts.mlx.NormalizationSchedule

namespace Inference.Kernels.Normalization.MlxRmsOutputSemantics
open Contracts.Mlx MlxRmsOutputSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF
inductive Value where
  | uint : Nat → Value
  | bfloat : BF → Value
  | floating : Float32 → Value
abbrev Environment := String → Option Value

-- The output phase has nonnegative int i<4; addition with uint r promotes i
-- to uint. Mixed BF16/float multiplication widens BF16 before the operation.
-- These floating operations remain the explicit M1 primitive contracts.
def evaluate (source weight : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (env : Environment) (memory : HalfMemory.Bytes) : Expr → Option Value
  | .var name => env name
  | .zero => some (.uint 0)
  | .index name expression => do
    match ←evaluate source weight inverse inverseBase env memory expression with
    | .uint index =>
      if name="x" then pure (.bfloat (Model.ofBits (HalfMemory.load memory (source+2*index))))
      else if name="w" then pure (.bfloat (Model.ofBits (HalfMemory.load memory (weight+2*index))))
      else if name="local_inv_mean" then pure (.floating (inverse (inverseBase+index)))
      else none
    | _ => none
  | .cast typeName expression => do
    match typeName,←evaluate source weight inverse inverseBase env memory expression with
    | "T",.floating value => pure (.bfloat (BFloat16.narrow value))
    | _,_ => none
  | .add left right => do
    match ←evaluate source weight inverse inverseBase env memory left,
        ←evaluate source weight inverse inverseBase env memory right with
    | .uint x,.uint y => pure (.uint ((x+y)%2^32))
    | _,_ => none
  | .mul left right => do
    match ←evaluate source weight inverse inverseBase env memory left,
        ←evaluate source weight inverse inverseBase env memory right with
    | .uint x,.uint y => pure (.uint ((x*y)%2^32))
    | .bfloat x,.floating y => pure (.floating (FlushToZero.mul (BFloat16.widen x) y))
    | .bfloat x,.bfloat y => pure (.bfloat (BFloat16Arithmetic.mul x y))
    | _,_ => none

def execute (source weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase : Nat)
    (env : Environment) (memory : HalfMemory.Bytes) (statement : Store) : Option HalfMemory.Bytes := do
  match statement.destination,
      ←evaluate source weight inverse inverseBase env memory statement.index,
      ←evaluate source weight inverse inverseBase env memory statement.value with
  | "out",.uint index,.bfloat value =>
    pure (HalfMemory.store memory (destination+2*index) (ArrayStorage.bits value))
  | _,_,_ => none

def environment (r i stride : Nat) : Environment := fun name =>
  if name="r" then some (.uint r)
  else if name="i" then some (.uint i)
  else if name="w_stride" then some (.uint stride) else none

def result (source weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase r i : Nat)
    (memory : HalfMemory.Bytes) : HalfMemory.Bytes :=
  HalfMemory.store memory (destination+2*(r+i))
    (ArrayStorage.bits (RmsNormMemory.operation (inverse inverseBase)
      (Model.ofBits (HalfMemory.load memory (source+2*(r+i))))
      (Model.ofBits (HalfMemory.load memory (weight+2*(r+i))))))

theorem execution (source weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase r i : Nat)
    (small : r+i<2^32) (memory : HalfMemory.Bytes) :
    execute source weight destination inverse inverseBase (environment r i 1) memory body=
      some (result source weight destination inverse inverseBase r i memory) := by
  change r+i<4294967296 at small
  simp [execute,evaluate,environment,body,result,RmsNormMemory.operation,
    Nat.mod_eq_of_lt small,Nat.add_comm i r]

def executeSource (text : String) (source weight destination : Nat)
    (inverse : M1Max.WordMemory) (inverseBase r i : Nat) (memory : HalfMemory.Bytes) : Option HalfMemory.Bytes := do
  let parsed ←parse text
  execute source weight destination inverse inverseBase (environment r i 1) memory parsed

theorem source_execution (source weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase r i : Nat)
    (small : r+i<2^32) (memory : HalfMemory.Bytes) :
    executeSource sourceBody source weight destination inverse inverseBase r i memory=
      some (result source weight destination inverse inverseBase r i memory) := by
  unfold executeSource
  rw [parsed_body]
  exact execution _ _ _ _ _ _ _ small _

theorem tail_source_execution (source weight destination : Nat) (inverse : M1Max.WordMemory) (inverseBase r i : Nat)
    (small : r+i<2^32) (memory : HalfMemory.Bytes) :
    executeSource sourceTailBody source weight destination inverse inverseBase r i memory=
      some (result source weight destination inverse inverseBase r i memory) := by
  unfold executeSource
  rw [parsed_tail_body]
  exact execution _ _ _ _ _ _ _ small _

end Inference.Kernels.Normalization.MlxRmsOutputSemantics
