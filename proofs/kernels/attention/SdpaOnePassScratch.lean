import kernels.attention.SdpaSummaryBytes
import kernels.attention.SdpaTwoPassScratch

namespace Inference.Kernels.Attention.SdpaOnePassScratch
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

@[irreducible] def numeratorLanes (p : SdpaVector.Platform) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (offset : Fin 8) : SdpaTransposeBytes.Lanes :=
  fun group lane => (SdpaVector.partials p query keys values (SdpaLayout.coordinate lane offset) group).numerator

structure Execution (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF) where
  summaries : SdpaSummaryBytes.Trace (fun group => (SdpaVector.partials p query keys values 0 group).shift)
    (fun group => (SdpaVector.partials p query keys values 0 group).denominator)
  scratch : ∀ offset, SdpaTransposeBytes.Trace (numeratorLanes p query keys values offset)
  sameBase : ∀ offset, (scratch offset).base=(scratch 0).base
  reuse : ∀ offset : Fin 7, (scratch ⟨offset.val+1, by omega⟩).before=(scratch ⟨offset.val, by omega⟩).memory

def Execution.canonical (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF) :
    Execution p query keys values := by
  refine ⟨SdpaSummaryBytes.Trace.canonical _ _,
    SdpaTwoPassScratch.canonicalScratch (numeratorLanes p query keys values) (fun _ => 0) 0 (by decide) (by decide), ?_, ?_⟩
  · intro offset
    rw [SdpaTwoPassScratch.canonical_base, SdpaTwoPassScratch.canonical_base]
  · intro offset
    exact SdpaTwoPassScratch.canonical_reuse _ _ _ _ _ offset

variable {steps : Nat} {p : SdpaVector.Platform} {query : Fin 256 → BF} {keys values : Fin steps → Fin 256 → BF}

def common (execution : Execution p query keys values) : Float32 := p.simdMaximum (execution.summaries.read true)

theorem common_eq (execution : Execution p query keys values) : common execution=SdpaVector.commonShift p query keys values := by
  unfold common SdpaVector.commonShift
  apply congrArg p.simdMaximum
  funext group
  exact execution.summaries.read_correct true group

def factor (execution : Execution p query keys values) (lane : Fin 32) : Float32 :=
  SdpaUpdate.exponential p.merge.scalar (execution.summaries.read true lane) (common execution)

def denominator (execution : Execution p query keys values) : Float32 :=
  p.merge.reduce (fun lane => FlushToZero.mul (execution.summaries.read false lane) (factor execution lane))

theorem denominator_correct (execution : Execution p query keys values) (i : Fin 256) :
    denominator execution=(SdpaVector.merged p query keys values i).denominator := by
  unfold denominator factor
  simp only [SdpaSummaryBytes.Trace.read_correct, SdpaSummaryBytes.selected, Bool.false_eq_true, ↓reduceIte, common_eq]
  unfold SdpaVector.merged SdpaMerge.forward SdpaMerge.source SdpaMerge.component
  simp only [Bool.false_eq_true, ↓reduceIte]
  apply congrArg p.merge.reduce
  funext lane
  rw [(SdpaVector.partials_shared p query keys values 0 i lane).1, (SdpaVector.partials_shared p query keys values 0 i lane).2]

def numerator (execution : Execution p query keys values) (offset : Fin 8) (group : Fin 32) : Float32 :=
  p.merge.reduce (fun lane => FlushToZero.mul ((execution.scratch offset).register group lane) (factor execution lane))

theorem numerator_correct (execution : Execution p query keys values) (offset : Fin 8) (group : Fin 32) :
    numerator execution offset group=(SdpaVector.merged p query keys values (SdpaLayout.coordinate group offset)).numerator := by
  unfold numerator
  unfold SdpaVector.merged SdpaMerge.forward SdpaMerge.source SdpaMerge.component
  simp only [↓reduceIte]
  apply congrArg p.merge.reduce
  funext lane
  rw [SdpaTransposeBytes.Trace.register_correct]
  unfold numeratorLanes factor
  rw [SdpaSummaryBytes.Trace.read_correct, common_eq]
  change FlushToZero.mul _ (SdpaUpdate.exponential _ (SdpaVector.partials p query keys values 0 lane).shift _)=_
  rw [(SdpaVector.partials_shared p query keys values 0 (SdpaLayout.coordinate group offset) lane).1]

-- Source division follows the same positive-denominator contract as the
-- original numerical theorem. Stores are handled by SdpaOutput after this
-- value is produced. No extra BF16 rounding is inserted into scratch.
def forward (execution : Execution p query keys values) (i : Fin 256) : BF :=
  SdpaNormalize.value p.normalization ⟨common execution, denominator execution,
    numerator execution ⟨i.val%8, by omega⟩ ⟨i.val/8, by omega⟩⟩

theorem forward_eq (execution : Execution p query keys values) (i : Fin 256) :
    forward execution i=SdpaVector.forward p query keys values i := by
  unfold forward
  rw [common_eq, denominator_correct execution i, numerator_correct, SdpaTwoPassWrites.coordinate_inverse]
  rfl

theorem forward_finite (execution : Execution p query keys values) (hf : SdpaVector.Finite p query keys values) (i : Fin 256) :
    Model.isFinite (forward execution i)=true := by
  rw [forward_eq]
  exact SdpaVector.forward_finite p query keys values hf i

theorem forward_error (execution : Execution p query keys values)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : SdpaVector.InputError query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : SdpaVector.Finite p query keys values) (positive : 0<steps) (i : Fin 256) :
    |Model.toReal (forward execution i)-SdpaVector.target targetQuery targetKeys targetValues i| ≤
      SdpaVector.budget p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues i := by
  rw [forward_eq]
  exact SdpaVector.forward_error p query keys values _ _ _ _ _ _ he hf positive i

end Inference.Kernels.Attention.SdpaOnePassScratch
