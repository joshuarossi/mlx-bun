import kernels.attention.SdpaTwoPassLayout
import kernels.attention.SdpaSequenceLoopRanges
import contracts.mlx.NormalizedCastBounds

namespace Inference.Kernels.Attention.SdpaTwoPassFirstPass
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- The ordinary two-pass first kernel uses the same scalar online update
-- as one-pass attention, with a host-selected key stride. Its intermediate
-- numerators are stored in BF16; maxima and denominator sums stay binary32.
def raw (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (coordinate : Fin 256) (block : Fin blocks) : State :=
  SdpaLoop.run p.merge.scalar p.maximum (SdpaVector.scores p query keys) (SdpaVector.valuesAt values coordinate)
    (SdpaTwoPassLayout.keys steps blocks block) (SdpaLoop.initial SdpaVector.initialShift)
def stored (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (coordinate : Fin 256) (block : Fin blocks) : BF := BFloat16.narrow (raw p query keys values coordinate block).numerator
def loaded (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (coordinate : Fin 256) (block : Fin blocks) : State :=
  { raw p query keys values coordinate block with numerator := BFloat16.widen (stored p query keys values coordinate block) }

theorem nonempty (steps blocks : Nat) (active : blocks ≤ steps) (block : Fin blocks) :
    SdpaTwoPassLayout.keys steps blocks block ≠ [] := by
  have i : block.val < steps := block.isLt.trans_le active
  have mem := (SdpaTwoPassLayout.keys_mem steps blocks block ⟨block.val, i⟩).mpr (Nat.mod_eq_of_lt block.isLt)
  intro empty
  rw [empty] at mem
  exact List.not_mem_nil mem

theorem narrow_relative (x : Float32) (finite : x.isFinite = true)
    (cast : Model.isFinite (BFloat16.narrow x) = true) :
    |Model.toReal (BFloat16.narrow x)-real x| ≤ (2 : ℝ)^(-8 : Int)*|real x|+(2 : ℝ)^(-134 : Int) := by
  have h := BFloat16.narrow_error x finite cast
  have hu : Model.unitRoundoffAt FloatFormat.bfloat16 = (2 : ℝ)^(-8 : Int) := by
    rw [Model.unitRoundoffAt_eq]
    rfl
  have he : Model.underflowErrorAt FloatFormat.bfloat16 = (2 : ℝ)^(-134 : Int) := by
    rw [Model.underflowErrorAt_eq]
    rfl
  exact h.trans (by simpa only [BFloat16.epsilon, hu, he] using RelativeRounding.epsilon_bound FloatFormat.bfloat16 (real x))

structure Result (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (coordinate : Fin 256) (block : Fin blocks) : Prop where
  loop : SdpaLoop.Finite p.merge.scalar p.maximum (SdpaVector.scores p query keys) (SdpaVector.valuesAt values coordinate)
    (SdpaTwoPassLayout.keys steps blocks block) (SdpaLoop.initial SdpaVector.initialShift)
  rawBound : SdpaUpdateBounds.Bounds (raw p query keys values coordinate block)
    (SdpaTwoPassLayout.count steps blocks block) (SdpaLoopBounds.ratio (SdpaTwoPassLayout.count steps blocks block))
  cast : Model.isFinite (stored p query keys values coordinate block) = true
  storedBound : |Model.toReal (stored p query keys values coordinate block)| ≤
    (2 : ℝ)^(26 : Nat)*real (raw p query keys values coordinate block).denominator

theorem ranges (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (primitive : SdpaExponentRanges.Primitive p.merge.scalar) (minimum : 32 ≤ blocks)
    (active : blocks ≤ steps) (supported : steps ≤ 262144)
    (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (hq : ∀ i, Model.isFinite (query i) = true ∧ |Model.toReal (query i)| ≤ 1024)
    (hk : ∀ t i, Model.isFinite (keys t i) = true ∧ |Model.toReal (keys t i)| ≤ 1024)
    (hv : ∀ t i, Model.isFinite (values t i) = true ∧ |Model.toReal (values t i)| ≤ (2 : ℝ)^(23 : Nat))
    (coordinate : Fin 256) (block : Fin blocks) : Result p query keys values coordinate block := by
  have score t := SdpaScoreRanges.ranges p.scoreContracted p.merge.reduce p.merge.reduction query (keys t) hq (hk t)
  have hs t : (SdpaVector.scores p query keys t).isFinite = true ∧
      |real (SdpaVector.scores p query keys t)| ≤ (2 : ℝ)^(24 : Nat) :=
    ⟨SdpaScore.source_finite _ _ _ _ _ (score t).1, (score t).2⟩
  have valuesRange t : (SdpaVector.valuesAt values coordinate t).isFinite = true ∧
      |real (SdpaVector.valuesAt values coordinate t)| ≤ (2 : ℝ)^(23 : Nat) :=
    ⟨BFloat16.widen_finite _ (hv t coordinate).1, by
      rw [SdpaVector.valuesAt, BFloat16.widen_real _ (hv t coordinate).1]
      exact (hv t coordinate).2⟩
  have countBound := SdpaTwoPassLayout.count_bound steps blocks supported minimum block
  have loop := SdpaLoopBounds.initialized p maximum primitive (SdpaVector.scores p query keys)
    (SdpaVector.valuesAt values coordinate) hs valuesRange (SdpaTwoPassLayout.keys steps blocks block)
    (nonempty steps blocks active block) (by rw [SdpaTwoPassLayout.length]; exact countBound)
  rw [SdpaTwoPassLayout.length] at loop
  change _ ∧ SdpaUpdateBounds.Bounds (raw p query keys values coordinate block) _ _ at loop
  have nonnegative := le_trans (by norm_num : (0 : ℝ) ≤ 1) loop.2.denominator.2.1
  have numerator := loop.2.numerator.2.trans
    (mul_le_mul_of_nonneg_right (SdpaLoopBounds.ratio_bounds _ countBound).2 nonnegative)
  have denominator : real (raw p query keys values coordinate block).denominator ≤ 8192 :=
    loop.2.denominator.2.2.trans (by exact_mod_cast countBound)
  let cap := BFloat16DyadicBounds.ceiling 1 38
  have capRange := BFloat16DyadicBounds.ceiling_range 1 38 (by decide) (by decide) (by decide)
  have cast := BFloat16ConversionBounds.narrow_range (raw p query keys values coordinate block).numerator cap
    loop.2.numerator.1 capRange.1 (by
      rw [capRange.2]
      norm_num at numerator ⊢
      linarith)
  have relative := narrow_relative _ loop.2.numerator.1 cast.1
  have magnitude := NormalizedCastBounds.absolute_of_error _ _ _ relative
  have storedBound : |Model.toReal (stored p query keys values coordinate block)| ≤
      (2 : ℝ)^(26 : Nat)*real (raw p query keys values coordinate block).denominator := by
    have positive := loop.2.denominator.2.1
    change |Model.toReal (stored p query keys values coordinate block)| ≤ _ at magnitude
    norm_num at magnitude numerator ⊢
    linarith
  exact ⟨loop.1, loop.2, cast.1, storedBound⟩

theorem loaded_finite (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (coordinate : Fin 256) (block : Fin blocks) (h : Result p query keys values coordinate block) :
    (loaded p query keys values coordinate block).shift.isFinite = true ∧
      (loaded p query keys values coordinate block).denominator.isFinite = true ∧
      (loaded p query keys values coordinate block).numerator.isFinite = true :=
  ⟨h.rawBound.shift.1, h.rawBound.denominator.1, BFloat16.widen_finite _ h.cast⟩

theorem shared (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (a b : Fin 256) (block : Fin blocks) :
    (loaded p query keys values a block).shift = (loaded p query keys values b block).shift ∧
      (loaded p query keys values a block).denominator = (loaded p query keys values b block).denominator :=
  SdpaVector.run_shared p.merge.scalar p.maximum _ _ _ _ _ _ rfl rfl

-- The storage error is added to the existing recurrence error budget.
-- In particular, it is not silently treated as a binary32 store.
theorem loaded_error (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (coordinate : Fin 256) (block : Fin blocks) (h : Result p query keys values coordinate block)
    (target : OnlineSoftmax.Summary) (error : Error)
    (he : StateError (raw p query keys values coordinate block) target error) :
    StateError (loaded p query keys values coordinate block) target
      ⟨error.denominator, BFloat16.epsilon (real (raw p query keys values coordinate block).numerator)+error.numerator⟩ := by
  refine ⟨he.shift, he.denominator, ?_⟩
  change |real (BFloat16.widen (stored p query keys values coordinate block))-target.numerator| ≤ _
  rw [BFloat16.widen_real _ h.cast]
  exact (abs_sub_le _ _ _).trans
    (add_le_add (BFloat16.narrow_error _ h.rawBound.numerator.1 h.cast) he.numerator)

end Inference.Kernels.Attention.SdpaTwoPassFirstPass
