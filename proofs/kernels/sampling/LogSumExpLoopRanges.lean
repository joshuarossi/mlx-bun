import kernels.sampling.LogSumExpBlockRanges
import kernels.sampling.LogSumExpLayout

namespace Inference.Kernels.Sampling.LogSumExpLoopRanges
open Contracts.Mlx Contracts.Mlx.Numerics LogSumExpBlockRanges
open Attention.SdpaUpdate (Platform)

def values (input : Fin 248320 → Float32) (iteration : Fin 61) (thread : Fin 1024) (read : Fin 4) : Float32 :=
  if h : LogSumExpLayout.offset iteration thread read < 248320 then input ⟨_, h⟩
  else LogSumExpExponentRanges.negativeInfinity

def loop (p : Platform) (input : Fin 248320 → Float32) (thread : Fin 1024) :
    (count : Nat) → count ≤ 61 → State
  | 0, _ => initial
  | count+1, size => validStep p (loop p input thread count (by omega))
      (values input ⟨count, by omega⟩ thread)

def Trace (p : Platform) (input : Fin 248320 → Float32) (thread : Fin 1024) :
    (count : Nat) → count ≤ 61 → Prop
  | 0, _ => True
  | count+1, size =>
      Trace p input thread count (by omega) ∧
      Finite p (loop p input thread count (by omega))
        (nextMaximum (loop p input thread count (by omega)) (values input ⟨count, by omega⟩ thread))
        (values input ⟨count, by omega⟩ thread)

theorem finite_values (input : Fin 248320 → Float32) (iteration : Fin 61) (thread : Fin 1024)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(23 : Nat))
    (valid : ∀ read, LogSumExpLayout.offset iteration thread read < 248320) :
    ∀ read, (values input iteration thread read).isFinite = true ∧
      |real (values input iteration thread read)| ≤ (2 : ℝ)^(23 : Nat) := by
  intro read
  simp only [values, valid read, dite_true]
  exact hi _

theorem padding_values (input : Fin 248320 → Float32) (iteration : Fin 61) (thread : Fin 1024)
    (padded : ∀ read, 248320 ≤ LogSumExpLayout.offset iteration thread read) :
    values input iteration thread = fun _ => LogSumExpExponentRanges.negativeInfinity := by
  funext read
  simp only [values, show ¬LogSumExpLayout.offset iteration thread read < 248320 from by
    have := padded read; omega, dite_false]

theorem ranges (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (paddingPrimitive : LogSumExpExponentRanges.PaddingPrimitive p)
    (input : Fin 248320 → Float32) (thread : Fin 1024)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(23 : Nat))
    (count : Nat) (size : count ≤ 61) :
    Trace p input thread count size ∧ (0 < count → Bounds (loop p input thread count size) (4*count)) := by
  induction count with
  | zero => exact ⟨True.intro, by omega⟩
  | succ count ih =>
    have ih' := ih (by omega)
    by_cases first : count = 0
    · subst count
      have h := LogSumExpBlockRanges.first p primitive (values input ⟨0, by decide⟩ thread)
        (finite_values input _ thread hi (LogSumExpLayout.first_block_valid thread))
      exact ⟨⟨True.intro, h.1⟩, fun _ => h.2⟩
    · have old := ih'.2 (by omega)
      have bound : 4*count+4 < 16777216 := by omega
      rcases LogSumExpLayout.whole_block_or_padding ⟨count, by omega⟩ thread with valid | padded
      · have h := LogSumExpBlockRanges.next p primitive _ (4*count) bound old
          (values input ⟨count, by omega⟩ thread) (finite_values input _ thread hi valid)
        refine ⟨⟨ih'.1, h.1⟩, fun _ => ?_⟩
        simpa only [loop, Nat.mul_add, Nat.mul_one] using h.2
      · have hp := padding_values input ⟨count, by omega⟩ thread padded
        have h := LogSumExpBlockRanges.padding p primitive paddingPrimitive _ (4*count) bound old
        have hm : nextMaximum (loop p input thread count (by omega)) (values input ⟨count, by omega⟩ thread) =
            (loop p input thread count (by omega)).maximum := by
          rw [hp, nextMaximum, List.ofFn_const, fold_padding _ old.maximumFinite]
        refine ⟨⟨ih'.1, ?_⟩, fun _ => ?_⟩
        · rw [hm, hp]
          exact h.1
        · simp only [loop, hp, padding_execution p _ old.maximumFinite, Nat.mul_add, Nat.mul_one]
          exact h.2

def localState (p : Platform) (input : Fin 248320 → Float32) (thread : Fin 1024) : State :=
  loop p input thread 61 (by decide)

theorem local_ranges (p : Platform) (primitive : Attention.SdpaExponentRanges.Primitive p)
    (paddingPrimitive : LogSumExpExponentRanges.PaddingPrimitive p)
    (input : Fin 248320 → Float32)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(23 : Nat)) (thread : Fin 1024) :
    Trace p input thread 61 (by decide) ∧ Bounds (localState p input thread) 244 := by
  have h := ranges p primitive paddingPrimitive input thread hi 61 (by decide)
  exact ⟨h.1, h.2 (by decide)⟩

end Inference.Kernels.Sampling.LogSumExpLoopRanges
