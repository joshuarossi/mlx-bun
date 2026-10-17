import kernels.attention.SdpaTwoPassBytes
import kernels.attention.SdpaTransposeBytes
import kernels.attention.SdpaTwoPassExecution

namespace Inference.Kernels.Attention.SdpaTwoPassScratch
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- A concrete completing sequence reuses the same allocation for all eight
-- coordinates held by each lane. Every previous trace has finished both
-- barriers before its memory becomes the next trace's initial memory.
def canonicalScratch (values : Fin 8 → SdpaTransposeBytes.Lanes) (before : ByteMemory.Bytes)
    (base : Nat) (aligned : base%4=0) (bounded : base+4096 ≤ 2^64) (offset : Fin 8) :
    SdpaTransposeBytes.Trace (values offset) :=
  if zero : offset.val=0 then SdpaTransposeBytes.Trace.canonical (values offset) before base aligned bounded
  else SdpaTransposeBytes.Trace.canonical (values offset)
    (canonicalScratch values before base aligned bounded ⟨offset.val-1, by omega⟩).memory base aligned bounded
termination_by offset.val
decreasing_by omega

theorem canonical_base (values : Fin 8 → SdpaTransposeBytes.Lanes) (before : ByteMemory.Bytes)
    (base : Nat) (aligned : base%4=0) (bounded : base+4096 ≤ 2^64) (offset : Fin 8) :
    (canonicalScratch values before base aligned bounded offset).base=base := by
  rw [canonicalScratch]
  split <;> rfl

theorem canonical_reuse (values : Fin 8 → SdpaTransposeBytes.Lanes) (before : ByteMemory.Bytes)
    (base : Nat) (aligned : base%4=0) (bounded : base+4096 ≤ 2^64) (offset : Fin 7) :
    (canonicalScratch values before base aligned bounded ⟨offset.val+1, by omega⟩).before=
      (canonicalScratch values before base aligned bounded ⟨offset.val, by omega⟩).memory := by
  conv =>
    lhs
    rw [canonicalScratch]
  simp only [Fin.val_mk, Nat.add_eq_zero_iff, Nat.one_ne_zero, and_false, dite_false]
  rfl

@[irreducible] def numeratorLanes (p : SdpaVector.Platform) (contracted : Bool) (complete : blocks%32=0)
    (query : Fin 24 → Fin 256 → BF) (keys values : Fin 4 → Fin steps → Fin 256 → BF)
    (first : SdpaTwoPassBytes.FirstTrace p blocks query keys values) (head : Fin 24) (offset : Fin 8) :
    SdpaTransposeBytes.Lanes := fun group lane =>
  (SdpaTwoPassExecution.sourceKeys complete group).foldl (fun acc block => ArithmeticFold.maddFloat contracted
    (SdpaUpdate.exponential p.merge.scalar (first.readState head block 0).shift
      (SdpaTwoPassMaximum.common p (fun b => (first.readState head b 0).shift)))
    (first.readState head block (SdpaLayout.coordinate lane offset)).numerator acc) 0

theorem numerator_lanes (p : SdpaVector.Platform) (contracted : Bool) (complete : blocks%32=0)
    (query : Fin 24 → Fin 256 → BF) (keys values : Fin 4 → Fin steps → Fin 256 → BF)
    (first : SdpaTwoPassBytes.FirstTrace p blocks query keys values) (head : Fin 24) (offset : Fin 8) :
    numeratorLanes p contracted complete query keys values first head offset=
      SdpaTwoPassExecution.numeratorLanes p contracted complete (query head) (keys (SdpaScore.kvHead head))
        (values (SdpaScore.kvHead head)) offset := by
  unfold numeratorLanes
  simp only [SdpaTwoPassBytes.first_to_second]
  rfl

structure Execution (p : SdpaVector.Platform) (contracted : Bool) (complete : blocks%32=0)
    (query : Fin 24 → Fin 256 → BF) (keys values : Fin 4 → Fin steps → Fin 256 → BF) where
  first : SdpaTwoPassBytes.FirstTrace p blocks query keys values
  scratch : ∀ head offset, SdpaTransposeBytes.Trace (numeratorLanes p contracted complete query keys values first head offset)
  sameBase : ∀ head offset, (scratch head offset).base=(scratch head 0).base
  reuse : ∀ head (offset : Fin 7), (scratch head ⟨offset.val+1, by omega⟩).before=(scratch head ⟨offset.val, by omega⟩).memory

def Execution.canonical (p : SdpaVector.Platform) (contracted : Bool) (complete : blocks%32=0)
    (query : Fin 24 → Fin 256 → BF) (keys values : Fin 4 → Fin steps → Fin 256 → BF)
    (bounded : blocks ≤ 1024) : Execution p contracted complete query keys values := by
  let first : SdpaTwoPassBytes.FirstTrace p blocks query keys values := SdpaTwoPassBytes.Trace.canonical _ _ _ bounded
  refine ⟨first, fun head => canonicalScratch (numeratorLanes p contracted complete query keys values first head)
    (fun _ => 0) 0 (by decide) (by decide), ?_, ?_⟩
  · intro head offset
    rw [canonical_base, canonical_base]
  · intro head offset
    exact canonical_reuse _ _ _ _ _ offset

variable {blocks steps : Nat} {p : SdpaVector.Platform} {contracted : Bool} {complete : blocks%32=0}
  {query : Fin 24 → Fin 256 → BF} {keys values : Fin 4 → Fin steps → Fin 256 → BF}

theorem Execution.numerator_correct (execution : Execution p contracted complete query keys values) (head : Fin 24)
    (offset : Fin 8) (group : Fin 32) :
    (execution.scratch head offset).reduce p.merge.reduce group=
      (SdpaTwoPassVector.merged p contracted blocks (query head) (keys (SdpaScore.kvHead head))
        (values (SdpaScore.kvHead head)) (SdpaLayout.coordinate group offset)).numerator := by
  rw [SdpaTransposeBytes.Trace.reduce_correct, numerator_lanes]
  have result := SdpaTwoPassExecution.numerator_execution p contracted complete (query head)
    (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) offset (fun _ => 0)
    (List.range 1024) (List.Perm.refl _) group
  rwa [SdpaTwoPassStorage.second_scratch_read] at result

def merged (execution : Execution p contracted complete query keys values) (head : Fin 24) (i : Fin 256) : SdpaUpdate.State :=
  SdpaTwoPassMerge.forward p.merge contracted (fun block => execution.first.readState head block i)
    (SdpaTwoPassMaximum.common p (fun block => (execution.first.readState head block 0).shift))

theorem merged_eq (execution : Execution p contracted complete query keys values) (head : Fin 24) (i : Fin 256) :
    merged execution head i=SdpaTwoPassVector.merged p contracted blocks (query head)
      (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i := by
  unfold merged
  simp only [SdpaTwoPassBytes.first_to_second]
  rfl

def forward (execution : Execution p contracted complete query keys values) (head : Fin 24) (i : Fin 256) : BF :=
  let state := merged execution head i
  let numerator := (execution.scratch head ⟨i.val%8, by omega⟩).reduce p.merge.reduce ⟨i.val/8, by omega⟩
  SdpaNormalize.value p.normalization { state with numerator := numerator }

theorem forward_eq (execution : Execution p contracted complete query keys values) (head : Fin 24) (i : Fin 256) :
    forward execution head i=SdpaTwoPassVector.forward p contracted blocks (query head)
      (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i := by
  unfold forward
  rw [execution.numerator_correct, SdpaTwoPassWrites.coordinate_inverse, merged_eq]
  rfl

theorem forward_finite (execution : Execution p contracted complete query keys values) (head : Fin 24)
    (hf : SdpaTwoPassVector.Finite p contracted blocks (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)))
    (i : Fin 256) : Model.isFinite (forward execution head i)=true := by
  rw [forward_eq]
  exact SdpaTwoPassVector.forward_finite p contracted blocks _ _ _ hf i

theorem forward_error (execution : Execution p contracted complete query keys values) (head : Fin 24)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : SdpaVector.InputError (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head))
      targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : SdpaTwoPassVector.Finite p contracted blocks (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)))
    (hn : 0<steps) (hb : 0<blocks) (i : Fin 256) :
    |Model.toReal (forward execution head i)-SdpaVector.target targetQuery targetKeys targetValues i| ≤
      SdpaTwoPassVector.budget p contracted blocks (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head))
        targetQuery errorQuery targetKeys targetValues errorKeys errorValues i := by
  rw [forward_eq]
  exact SdpaTwoPassVector.forward_error p contracted blocks _ _ _ _ _ _ _ _ _ he hf hn hb i

end Inference.Kernels.Attention.SdpaTwoPassScratch
