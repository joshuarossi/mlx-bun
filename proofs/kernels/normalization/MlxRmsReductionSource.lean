import kernels.normalization.MlxRmsReductionFirstPass
import kernels.normalization.MlxRmsReductionSyntax
import kernels.normalization.MlxRmsHostSelection

namespace Inference.Kernels.Normalization.MlxRmsReductionSource
open Contracts.Mlx MlxRmsReductionSyntax
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open MlxRmsLoopControl (count)
set_option maxRecDepth 10000

-- Exact binary32 conversion of the selected uint axis_size=5120.
def axisFloat : Float32 := Float32.ofBits 0x45a00000

theorem axisFloat_value : Numerics.real axisFloat=5120 := by
  rw [Numerics.real_unpack]
  change Model.unpackedToReal (.finite .positive 10485760 (-11) (by decide))=5120
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit,FloatLib.Floats.Formats.Flocq.bpow]
  change 10485760*((2 : ℝ)^11)⁻¹=5120
  norm_num

structure Machine (groups : Nat) where
  phase : Nat
  partials : Fin groups → Float32
  scratch : M1Max.WordMemory
  inverse : M1Max.WordMemory

variable {values weight : Fin count → ArrayStorage.BF} (input : BinaryMemory.Input values weight)

def groupValues (platform : RmsNorm.Platform) (group : Fin platform.groups) : Float32 :=
  platform.reduce (fun lane => MlxRmsReductionFirstPass.locals input platform.contracted (platform.groups*32)
    (NormalizationReduction.laneIndex group lane))

-- Collective semantics for the complete parsed tail. The three source
-- barriers separate ordered shared-memory phases; GPU visibility/compiler
-- conformance remain explicit platform boundaries. SIMD/division/rsqrt stay
-- platform primitives, not assumed exact real arithmetic.
def instruction (platform : RmsNorm.Platform) (size eps : Float32) (base inverseBase : Nat)
    (op : Instruction) (state : Machine platform.groups) : Option (Machine platform.groups) :=
  match op with
  | .groupReduce => if state.phase=0 then some {state with phase:=1,partials:=groupValues input platform} else none
  | .initialize => if state.phase=1 then some {state with phase:=2,scratch:=Memory.execute (NormalizationReduction.initialStores base) state.scratch} else none
  | .partialWrite => if state.phase=3 then some {state with phase:=4,scratch:=Memory.execute (NormalizationReduction.partialStores base state.partials) state.scratch} else none
  | .inverse => if state.phase=5 then
      let acc := platform.reduce (fun lane => state.scratch (base+lane.val))
      let factor := platform.rsqrt (FlushToZero.add (platform.divide acc size) eps)
      some {state with phase:=6,inverse:=RmsNorm.inverseMemory state.inverse inverseBase factor} else none
  | .barrier => if state.phase=2 ∨ state.phase=4 ∨ state.phase=6 then some {state with phase:=state.phase+1} else none

def run (platform : RmsNorm.Platform) (size eps : Float32) (base inverseBase : Nat) :
    List Instruction → Machine platform.groups → Option (Machine platform.groups)
  | [],before => some before
  | op::rest,before => do
    let next ←instruction input platform size eps base inverseBase op before
    run platform size eps base inverseBase rest next

def initial (platform : RmsNorm.Platform) (before inverseBefore : M1Max.WordMemory) : Machine platform.groups :=
  ⟨0,fun _ => 0,before,inverseBefore⟩

def final (platform : RmsNorm.Platform) (size eps : Float32) (before inverseBefore : M1Max.WordMemory)
    (base inverseBase : Nat) : Machine platform.groups :=
  let partials := groupValues input platform
  let scratch := NormalizationReduction.shared before (NormalizationReduction.initialStores base)
    (NormalizationReduction.partialStores base partials)
  let factor := platform.rsqrt (FlushToZero.add (platform.divide
    (platform.reduce (fun lane => scratch (base+lane.val))) size) eps)
  ⟨7,partials,scratch,RmsNorm.inverseMemory inverseBefore inverseBase factor⟩

theorem program_execution (platform : RmsNorm.Platform) (size eps : Float32)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    run input platform size eps base inverseBase program (initial platform before inverseBefore)=
      some (final input platform size eps before inverseBefore base inverseBase) := by rfl

def executeSource (platform : RmsNorm.Platform) (size eps : Float32)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) : Option (Machine platform.groups) := do
  let body ←parseBody sourceBody
  run input platform size eps base inverseBase body (initial platform before inverseBefore)

theorem source_execution (platform : RmsNorm.Platform) (size eps : Float32)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    executeSource input platform size eps before inverseBefore base inverseBase=
      some (final input platform size eps before inverseBefore base inverseBase) := by
  unfold executeSource
  rw [parsed_body]
  exact program_execution input platform size eps before inverseBefore base inverseBase

theorem inverse_read (platform : RmsNorm.Platform) (size eps : Float32)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    (final input platform size eps before inverseBefore base inverseBase).inverse inverseBase=
      RmsNorm.inverse platform (RmsNormMemory.sourceValues input) size eps before base := by
  rw [show (final input platform size eps before inverseBefore base inverseBase).inverse=
      RmsNorm.inverseMemory inverseBefore inverseBase
        (RmsNorm.inverse platform (RmsNormMemory.sourceValues input) size eps before base) by rfl]
  exact RmsNorm.inverse_read _ _ _

theorem existing_factor {platform : RmsNorm.Platform} {size eps : Float32}
    (existing : RmsNormMemory.Execution input platform size eps)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    (final input platform size eps before inverseBefore base inverseBase).inverse inverseBase=existing.factor := by
  rw [inverse_read input,RmsNormMemory.sourceValues_eq input]
  exact (existing.factor_eq before base).symm

-- This constructor joins selected host metadata, parsed input loops/cells,
-- both SIMD reductions/barriers and parsed pointer/output-cell stores. The
-- inverse and every completed memory are constructed, never premises.
theorem selected_execution (kernel : MlxRmsHostSelection.KernelLimit) (donatable : Bool)
    {platform : RmsNorm.Platform} {eps : Float32}
    (nativeThreads : platform.groups*32=kernel.threads)
    (existing : RmsNormMemory.Execution input platform axisFloat eps)
    (before inverseBefore : M1Max.WordMemory) (base inverseBase : Nat) :
    ∃ launch after,
      MlxRmsHostSelection.select (MlxRmsHostSelection.singleToken donatable) kernel=some launch ∧
      launch.rows=1 ∧ launch.weightStride=1 ∧ launch.groupThreads=kernel.threads ∧
      platform.groups*32=launch.groupThreads ∧
      (∀ thread : Fin (platform.groups*32), MlxRmsLoopControl.Executes (platform.groups*32) thread 0
        ((NormalizationSchedule.threadColumns count thread).map Fin.val)) ∧
      (∀ thread, MlxRmsReductionFirstPass.executeThread input platform.contracted (platform.groups*32)
          (by have := platform.groupsPositive; omega) thread=
        some (MlxRmsReductionFirstPass.locals input platform.contracted (platform.groups*32) thread)) ∧
      executeSource input platform axisFloat eps before inverseBefore base inverseBase=some after ∧ after.phase=7 ∧
      MlxRmsLoopMemory.Runs input existing.normalized kernel.threads kernel.positive after.inverse inverseBase
        (MlxRmsLoopMemory.programs kernel.threads).flatten input.lhs.bytes existing.normalized.trace.memory := by
  let launch : MlxRmsHostSelection.Launch :=
    ⟨5120,1,true,1,kernel.threads,kernel.threads,if donatable then .donated else .fresh⟩
  refine ⟨launch,final input platform axisFloat eps before inverseBefore base inverseBase,
    MlxRmsHostSelection.single_launch donatable kernel,rfl,rfl,rfl,nativeThreads,?_,?_,
    source_execution input platform axisFloat eps before inverseBefore base inverseBase,rfl,?_⟩
  · exact MlxRmsLoopControl.source_operational (platform.groups*32)
      (by have := platform.groupsPositive; omega) (by have := platform.groupsBounded; omega)
  · exact MlxRmsReductionFirstPass.checked_locals input platform.contracted (platform.groups*32)
      (by have := platform.groupsPositive; omega)
  · exact MlxRmsLoopMemory.output_stores input existing.normalized kernel.threads kernel.positive _ inverseBase
      (existing_factor input existing before inverseBefore base inverseBase)

end Inference.Kernels.Normalization.MlxRmsReductionSource
