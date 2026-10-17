import kernels.normalization.ResidualRmsTailSyntax
import kernels.normalization.ResidualRmsReductionMemory

namespace Inference.Kernels.Normalization.ResidualRmsTailSource
open Contracts.Mlx ResidualRmsTailSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open ResidualRmsCellSemantics (count BF)
set_option maxRecDepth 10000

-- Collective threadgroup semantics for the restricted productions. Guards
-- select exactly the indicated 32 lanes or group leaders. Barriers enforce
-- phase transitions; actual Metal visibility remains a hardware boundary.
structure Machine where
  phase : Nat
  groups : Fin 32 → Float32
  scratch : M1Max.WordMemory
  inverse : M1Max.WordMemory

def instruction (platform : RmsNorm.Platform) (width eps : Float32)
    (firstPass : ResidualRmsFirstPassMemory.Machine) (base inverseBase : Nat)
    (op : Instruction) (state : Machine) : Option Machine :=
  match op with
  | .groupReduce => if state.phase=0 then
      some {state with phase:=1,groups:=ResidualRmsReductionMemory.groupValues platform.reduce firstPass} else none
  | .initialize => if state.phase=1 then
      some {state with phase:=2,scratch:=Memory.execute (NormalizationReduction.initialStores base) state.scratch} else none
  | .barrier => if state.phase=2 ∨ state.phase=4 then some {state with phase:=state.phase+1} else none
  | .partialWrite => if state.phase=3 then
      some {state with phase:=4,scratch:=Memory.execute (NormalizationReduction.partialStores base state.groups) state.scratch} else none
  | .inverse => if state.phase=5 then
      let acc := platform.reduce (fun lane => state.scratch (base+lane.val))
      let factor := platform.rsqrt (FlushToZero.add (platform.divide acc width) eps)
      some {state with phase:=6,inverse:=RmsNorm.inverseMemory state.inverse inverseBase factor} else none
  | .deviceBarrier => if state.phase=6 then some {state with phase:=7} else none

def run (platform : RmsNorm.Platform) (width eps : Float32)
    (firstPass : ResidualRmsFirstPassMemory.Machine) (base inverseBase : Nat) : List Instruction → Machine → Option Machine
  | [],state => some state
  | op::rest,state => do
    let next ←instruction platform width eps firstPass base inverseBase op state
    run platform width eps firstPass base inverseBase rest next

def initial (before inverseBefore : M1Max.WordMemory) : Machine := ⟨0,fun _ => 0,before,inverseBefore⟩

def final (platform : RmsNorm.Platform) (width eps : Float32)
    (firstPass : ResidualRmsFirstPassMemory.Machine) (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) : Machine :=
  let groups := ResidualRmsReductionMemory.groupValues platform.reduce firstPass
  let scratch := ResidualRmsReductionMemory.scratch before (NormalizationReduction.initialStores base)
    (NormalizationReduction.partialStores base groups)
  let factor := ResidualRmsReductionMemory.inverse platform width eps before base
    (NormalizationReduction.initialStores base) (NormalizationReduction.partialStores base groups)
  ⟨7,groups,scratch,RmsNorm.inverseMemory inverseBefore inverseBase factor⟩

theorem program_execution (platform : RmsNorm.Platform) (width eps : Float32)
    (firstPass : ResidualRmsFirstPassMemory.Machine) (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    run platform width eps firstPass base inverseBase program (initial before inverseBefore)=
      some (final platform width eps firstPass before inverseBefore base inverseBase) := by rfl

def executeSource (source : String) (platform : RmsNorm.Platform) (width eps : Float32)
    (firstPass : ResidualRmsFirstPassMemory.Machine) (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) : Option Machine := do
  let body ←parseBody source
  run platform width eps firstPass base inverseBase body (initial before inverseBefore)

theorem source_execution (platform : RmsNorm.Platform) (width eps : Float32)
    (firstPass : ResidualRmsFirstPassMemory.Machine) (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    executeSource sourceBody platform width eps firstPass before inverseBefore base inverseBase=
      some (final platform width eps firstPass before inverseBefore base inverseBase) := by
  unfold executeSource
  rw [parsed_body]
  exact program_execution platform width eps firstPass before inverseBefore base inverseBase

variable {x update : Fin count → BF} (input : BinaryMemory.Input x update)
  (allocation : ResidualRmsCellMemory.Allocation input.lhs.base input.rhs.base destination)

include allocation in
theorem inverse_read (platform : RmsNorm.Platform) (groups : platform.groups=32)
    (width eps : Float32) (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    (final platform width eps (ResidualRmsFirstPassMemory.complete input destination platform.contracted)
      before inverseBefore base inverseBase).inverse inverseBase=
      RmsNorm.inverse platform (ResidualRmsNorm.residualInput x update) width eps before base :=
  ResidualRmsReductionMemory.inverse_read input allocation platform groups rfl width eps before inverseBefore base inverseBase
    _ _ (List.Perm.refl _) (List.Perm.refl _)

-- No caller supplies an execution result or inverse value: both are built
-- from the parsed source and the proved first-pass accumulators.
include allocation in
theorem checked_inverse (platform : RmsNorm.Platform) (groups : platform.groups=32)
    (width eps : Float32) (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    ∃ after, executeSource sourceBody platform width eps
      (ResidualRmsFirstPassMemory.complete input destination platform.contracted) before inverseBefore base inverseBase=some after ∧
      after.phase=7 ∧ after.inverse inverseBase=
        RmsNorm.inverse platform (ResidualRmsNorm.residualInput x update) width eps before base :=
  ⟨_,source_execution _ _ _ _ _ _ _ _,rfl,inverse_read input allocation platform groups width eps before inverseBefore base inverseBase⟩


-- Output-pass register arithmetic reads the parsed first-pass BF16 bytes and
-- the inverse produced by the parsed tail. Keep narrowing before BF16 weight
-- multiplication, as in the source. Output store scheduling is separate.
include allocation in
theorem output_value (platform : RmsNorm.Platform) (groups : platform.groups=32)
    (weight : Fin count → BF) (width eps : Float32) (before inverseBefore : M1Max.WordMemory)
    (base inverseBase : Nat) (col : Fin count) :
    BFloat16Arithmetic.mul (weight col) (BFloat16.narrow (FlushToZero.mul
      (BFloat16.widen (Model.ofBits (HalfMemory.load
        (ResidualRmsFirstPassMemory.complete input destination platform.contracted).memory (destination+2*col.val))))
      ((final platform width eps (ResidualRmsFirstPassMemory.complete input destination platform.contracted)
        before inverseBefore base inverseBase).inverse inverseBase)))=
      ResidualRmsNorm.normalized platform x update weight width eps before base col :=
  ResidualRmsReductionMemory.output_value input allocation platform groups rfl weight width eps before inverseBefore
    base inverseBase _ _ (List.Perm.refl _) (List.Perm.refl _) col

end Inference.Kernels.Normalization.ResidualRmsTailSource
