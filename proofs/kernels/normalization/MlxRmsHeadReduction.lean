import kernels.normalization.MlxRmsHeadFirstPass
import kernels.normalization.MlxRmsReductionSyntax

namespace Inference.Kernels.Normalization.MlxRmsHeadReduction
open Contracts.Mlx MlxRmsReductionSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

structure Machine where
  phase : Nat
  partials : Fin 2 → Float32
  scratch : M1Max.WordMemory
  inverse : M1Max.WordMemory

variable {heads base : Nat} {values : Fin heads → Fin 256 → ArrayStorage.BF} {weight : Fin 256 → ArrayStorage.BF}
  (input : RmsHeadsMemory.Input values weight base)

def groupValues (p : RmsNorm.Platform) (head : Fin heads) (group : Fin 2) : Float32 :=
  p.reduce (fun lane => MlxRmsHeadFirstPass.localValue input p.contracted head (NormalizationReduction.laneIndex group lane))

def instruction (p : RmsNorm.Platform) (head : Fin heads) (width eps : Float32) (scratchBase inverseBase : Nat)
    (op : Instruction) (state : Machine) : Option Machine :=
  match op with
  | .groupReduce => if state.phase=0 then some {state with phase:=1,partials:=groupValues input p head} else none
  | .initialize => if state.phase=1 then some {state with phase:=2,scratch:=Memory.execute (NormalizationReduction.initialStores scratchBase) state.scratch} else none
  | .partialWrite => if state.phase=3 then some {state with phase:=4,scratch:=Memory.execute (NormalizationReduction.partialStores scratchBase state.partials) state.scratch} else none
  | .inverse => if state.phase=5 then
      let acc := p.reduce (fun lane => state.scratch (scratchBase+lane.val))
      let factor := p.rsqrt (FlushToZero.add (p.divide acc width) eps)
      some {state with phase:=6,inverse:=RmsNorm.inverseMemory state.inverse inverseBase factor} else none
  | .barrier => if state.phase=2 ∨ state.phase=4 ∨ state.phase=6 then some {state with phase:=state.phase+1} else none

def run (p : RmsNorm.Platform) (head : Fin heads) (width eps : Float32) (scratchBase inverseBase : Nat) :
    List Instruction → Machine → Option Machine
  | [],before => some before
  | op::rest,before => do
    let next ←instruction input p head width eps scratchBase inverseBase op before
    run p head width eps scratchBase inverseBase rest next

def initial (before inverseBefore : M1Max.WordMemory) : Machine := ⟨0,fun _ => 0,before,inverseBefore⟩

def final (p : RmsNorm.Platform) (head : Fin heads) (width eps : Float32)
    (before inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) : Machine :=
  let partials := groupValues input p head
  let scratch := NormalizationReduction.shared before (NormalizationReduction.initialStores scratchBase)
    (NormalizationReduction.partialStores scratchBase partials)
  let factor := p.rsqrt (FlushToZero.add (p.divide (p.reduce (fun lane => scratch (scratchBase+lane.val))) width) eps)
  ⟨7,partials,scratch,RmsNorm.inverseMemory inverseBefore inverseBase factor⟩

def executeSource (p : RmsNorm.Platform) (head : Fin heads) (width eps : Float32)
    (before inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) : Option Machine := do
  let body ←MlxRmsReductionSyntax.parseBody MlxRmsReductionSyntax.sourceBody
  run input p head width eps scratchBase inverseBase body (initial before inverseBefore)

theorem source_execution (p : RmsNorm.Platform) (head : Fin heads) (width eps : Float32)
    (before inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) :
    executeSource input p head width eps before inverseBefore scratchBase inverseBase=
      some (final input p head width eps before inverseBefore scratchBase inverseBase) := by
  unfold executeSource
  rw [MlxRmsReductionSyntax.parsed_body]
  rfl

theorem groups_eq (p : RmsNorm.Platform) (head : Fin heads) :
    groupValues input p head=NormalizationReduction.groupSum p.reduce p.contracted (RmsHeadsMemory.sourceValues input head) := by
  funext group
  unfold groupValues NormalizationReduction.groupSum
  congr 1
  funext lane
  exact MlxRmsHeadFirstPass.local_eq input p.contracted head _

theorem inverse_read (p : RmsNorm.Platform) (dispatch : p.groups=2) (head : Fin heads) (width eps : Float32)
    (before inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) :
    (final input p head width eps before inverseBefore scratchBase inverseBase).inverse inverseBase=
      RmsNorm.inverse p (RmsHeadsMemory.sourceValues input head) width eps before scratchBase := by
  unfold final
  dsimp only
  rw [RmsNorm.inverse_read,groups_eq input p head]
  unfold RmsNorm.inverse
  rw [dispatch]
  rfl

theorem factor_read {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (head : Fin heads)
    (before inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) :
    (final input p head width eps before inverseBefore scratchBase inverseBase).inverse inverseBase=
      MlxRmsHeadMemory.inverseWords input execution head 0 := by
  rw [inverse_read input p execution.dispatch,RmsHeadsMemory.sourceValues_eq input head,
    MlxRmsHeadMemory.inverse_read input execution head]
  exact (execution.factor_eq head before scratchBase).symm

-- The parsed first-pass caches, two SIMD reductions and shared-memory phases
-- produce the very inverse read by the parsed cached-output ownership trace.
-- The primitive/compiler/barrier and native descriptor attachments remain
-- explicit. The selected axis conversion is supplied by the graph's width.
theorem checked {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (headBound : heads≤2^32)
    (before inverseBefore : M1Max.WordMemory) (scratchBase inverseBase : Nat) :
    (∀ head thread, ∃ after,
      MlxRmsHeadMemory.captureSource (base:=base) p.contracted head thread input.source.memory=some after ∧
      MlxRmsHeadRegisters.Captures p.contracted (MlxRmsHeadFirstPass.source (base:=base) head thread)
        input.source.memory (List.finRange 4) MlxRmsHeadRegisters.initial after ∧
      after.acc=NormalizationReduction.threadSum p.contracted (RmsHeadsMemory.sourceValues input head) thread) ∧
    (∀ head, ∃ after, executeSource input p head width eps before inverseBefore scratchBase inverseBase=some after ∧
      after.phase=7 ∧ after.inverse inverseBase=MlxRmsHeadMemory.inverseWords input execution head 0) ∧
    MlxRmsHeadMemory.Executes input execution (ReadBeforeOverwrite.initial input.source.memory)
      execution.reads.events execution.reads.after ∧ execution.reads.after.memory=execution.stores.memory := by
  refine ⟨fun head thread => MlxRmsHeadFirstPass.source_local input headBound p.contracted head thread,?_,
    (MlxRmsHeadMemory.checked input execution headBound).1,(MlxRmsHeadMemory.checked input execution headBound).2⟩
  intro head
  exact ⟨final input p head width eps before inverseBefore scratchBase inverseBase,
    source_execution input p head width eps before inverseBefore scratchBase inverseBase,rfl,
    factor_read input execution head before inverseBefore scratchBase inverseBase⟩

end Inference.Kernels.Normalization.MlxRmsHeadReduction
