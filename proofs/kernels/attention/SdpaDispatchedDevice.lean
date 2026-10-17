import kernels.attention.SdpaTwoPassScratch
import kernels.attention.SdpaOnePassScratch
import kernels.attention.SdpaOutput
import kernels.attention.SdpaDispatched

namespace Inference.Kernels.Attention.SdpaDispatchedDevice
open Contracts.Mlx Contracts.Mlx.Numerics SdpaDispatched
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

theorem complete_blocks (arch : Char) (steps : Nat) : blockCount arch steps%32=0 :=
  (SdpaTwoPassDispatch.qwen_bounds arch steps).2.2
theorem bounded_blocks (arch : Char) (steps : Nat) : blockCount arch steps ≤ 1024 :=
  (SdpaTwoPassDispatch.qwen_bounds arch steps).2.1

-- The selection is the pinned native dispatch predicate. It introduces no
-- new runtime checks. Both routes use completed byte-storage and scratch
-- traces. Their arithmetic loops retain the existing source translations.
abbrev OnePass (p : SdpaVector.Platform) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) :=
  ∀ head, SdpaOnePassScratch.Execution p (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head))

abbrev TwoPass (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) :=
  SdpaTwoPassScratch.Execution p contracted (complete_blocks arch steps) query keys values

@[irreducible] def produced (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF)
    (first : ¬twoPass arch steps → OnePass p query keys values)
    (second : twoPass arch steps → TwoPass p contracted arch query keys values) (head : Fin 24) (i : Fin 256) : BF :=
  if selected : twoPass arch steps then SdpaTwoPassScratch.forward (second selected) head i
  else SdpaOnePassScratch.forward (first selected head) i

theorem produced_eq (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF)
    (first : ¬twoPass arch steps → OnePass p query keys values)
    (second : twoPass arch steps → TwoPass p contracted arch query keys values) (head : Fin 24) (i : Fin 256) :
    produced p contracted arch query keys values first second head i=
      SdpaDispatched.forward p contracted arch (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i := by
  unfold produced SdpaDispatched.forward
  split
  next selected => exact SdpaTwoPassScratch.forward_eq (second selected) head i
  next selected => exact SdpaOnePassScratch.forward_eq (first selected head) i

structure Execution (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) where
  first : ¬twoPass arch steps → OnePass p query keys values
  second : twoPass arch steps → TwoPass p contracted arch query keys values
  output : SdpaOutput.Trace (produced p contracted arch query keys values first second)

def Execution.canonical (p : SdpaVector.Platform) (contracted : Bool) (arch : Char) (query : Fin 24 → Fin 256 → BF)
    (keys values : Fin 4 → Fin steps → Fin 256 → BF) : Execution p contracted arch query keys values :=
  let first := fun (_ : ¬twoPass arch steps) head => SdpaOnePassScratch.Execution.canonical p
    (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head))
  let second := fun _ : twoPass arch steps => SdpaTwoPassScratch.Execution.canonical p contracted
    (complete_blocks arch steps) query keys values (bounded_blocks arch steps)
  ⟨first, second, SdpaOutput.Trace.canonical (produced p contracted arch query keys values first second) (fun _ => 0) 0 (by decide) (by decide)⟩

variable {steps : Nat} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {query : Fin 24 → Fin 256 → BF} {keys values : Fin 4 → Fin steps → Fin 256 → BF}

def forward (execution : Execution p contracted arch query keys values) (head : Fin 24) (i : Fin 256) : BF :=
  execution.output.read head i

theorem forward_eq (execution : Execution p contracted arch query keys values) (head : Fin 24) (i : Fin 256) :
    forward execution head i=SdpaDispatched.forward p contracted arch (query head)
      (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)) i := by
  unfold forward
  rw [execution.output.read_correct]
  exact produced_eq p contracted arch query keys values execution.first execution.second head i

theorem forward_error (execution : Execution p contracted arch query keys values) (head : Fin 24)
    (targetQuery errorQuery : Fin 256 → ℝ) (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : SdpaVector.InputError (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head))
      targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : SdpaDispatched.Finite p contracted arch (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)))
    (positive : 0<steps) (i : Fin 256) :
    |Model.toReal (forward execution head i)-SdpaVector.target targetQuery targetKeys targetValues i| ≤
      SdpaDispatched.budget p contracted arch (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head))
        targetQuery errorQuery targetKeys targetValues errorKeys errorValues i := by
  rw [forward_eq]
  exact SdpaDispatched.forward_error p contracted arch _ _ _ _ _ _ _ _ _ he hf positive i

theorem forward_finite (execution : Execution p contracted arch query keys values) (head : Fin 24)
    (hf : SdpaDispatched.Finite p contracted arch (query head) (keys (SdpaScore.kvHead head)) (values (SdpaScore.kvHead head)))
    (i : Fin 256) : Model.isFinite (forward execution head i)=true := by
  rw [forward_eq]
  exact SdpaDispatched.forward_finite p contracted arch _ _ _ hf i

end Inference.Kernels.Attention.SdpaDispatchedDevice
