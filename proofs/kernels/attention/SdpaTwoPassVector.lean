import kernels.attention.SdpaTwoPassMaximum
import kernels.attention.SdpaTwoPassMergeRanges

namespace Inference.Kernels.Attention.SdpaTwoPassVector
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- One head in the ordinary two-pass BF16 route. Intermediate numerators
-- include the first kernel's BF16 store and the second kernel's widen.
abbrev partials := @SdpaTwoPassFirstPass.loaded
def commonShift (p : SdpaVector.Platform) (blocks : Nat) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) : Float32 :=
  SdpaTwoPassMaximum.common p (fun block : Fin blocks => (partials p query keys values 0 block).shift)
def merged (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (coordinate : Fin 256) : State :=
  SdpaTwoPassMerge.forward (blocks := blocks) p.merge contracted (partials p query keys values coordinate)
    (commonShift p blocks query keys values)
def forward (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (coordinate : Fin 256) : BF :=
  SdpaNormalize.value p.normalization (merged p contracted blocks query keys values coordinate)

noncomputable def partialTargets (p : SdpaVector.Platform) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (targetQuery : Fin 256 → ℝ)
    (targetKeys targetValues : Fin steps → Fin 256 → ℝ) (coordinate : Fin 256) (block : Fin blocks) : OnlineSoftmax.Summary :=
  OnlineSoftmax.reference (SdpaVector.targetScores targetQuery targetKeys) (fun t => targetValues t coordinate)
    (SdpaTwoPassLayout.keys steps blocks block) (real (partials p query keys values coordinate block).shift)
noncomputable def rawBudgets (p : SdpaVector.Platform) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ) (coordinate : Fin 256) (block : Fin blocks) : Error :=
  SdpaLoop.errorRun p.merge.scalar p.maximum (SdpaVector.scores p query keys) (SdpaVector.valuesAt values coordinate)
    (SdpaVector.targetScores targetQuery targetKeys) (fun t => targetValues t coordinate)
    (SdpaVector.scoreBudgets p query keys targetQuery errorQuery targetKeys errorKeys) (fun t => errorValues t coordinate)
    [] (SdpaTwoPassLayout.keys steps blocks block) (SdpaLoop.initial SdpaVector.initialShift) ⟨0, 0⟩
noncomputable def partialBudgets (p : SdpaVector.Platform) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ) (coordinate : Fin 256) (block : Fin blocks) : Error :=
  let e := rawBudgets p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate block
  ⟨e.denominator, BFloat16.epsilon (real (SdpaTwoPassFirstPass.raw p query keys values coordinate block).numerator)+e.numerator⟩
noncomputable def budget (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ) (coordinate : Fin 256) : ℝ :=
  SdpaNormalize.budget p.normalization (merged p contracted blocks query keys values coordinate)
    (OnlineSoftmax.reference (SdpaVector.targetScores targetQuery targetKeys) (fun t => targetValues t coordinate)
      (List.finRange steps) (real (commonShift p blocks query keys values)))
    (SdpaTwoPassMerge.budget (blocks := blocks) p.merge contracted (partials p query keys values coordinate)
      (commonShift p blocks query keys values)
      (partialTargets p query keys values targetQuery targetKeys targetValues coordinate)
      (partialBudgets p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate))

structure Finite (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) : Prop where
  queryFinite : ∀ i, Model.isFinite (query i) = true
  keysFinite : ∀ t i, Model.isFinite (keys t i) = true
  valuesFinite : ∀ t i, Model.isFinite (values t i) = true
  scores : ∀ t, Arithmetic.Finite (SdpaScore.bind query (keys t)) (SdpaScore.expression p.scoreContracted p.merge.reduction.tree)
  first : ∀ coordinate block, SdpaTwoPassFirstPass.Result p query keys values coordinate (block : Fin blocks)
  merge : ∀ coordinate, SdpaTwoPassMerge.Finite (blocks := blocks) p.merge contracted (partials p query keys values coordinate)
    (commonShift p blocks query keys values)
  normalization : ∀ coordinate, SdpaNormalize.Finite p.normalization (merged p contracted blocks query keys values coordinate)

theorem partials_error (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : SdpaVector.InputError query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : Finite p contracted blocks query keys values) (coordinate : Fin 256) (block : Fin blocks) :
    StateError (partials p query keys values coordinate block)
      (partialTargets p query keys values targetQuery targetKeys targetValues coordinate block)
      (partialBudgets p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate block) := by
  apply SdpaTwoPassFirstPass.loaded_error p query keys values coordinate block (hf.first coordinate block)
  apply SdpaLoop.initialized_run_error p.merge.scalar p.maximum (SdpaVector.scores p query keys)
    (SdpaVector.valuesAt values coordinate) (SdpaVector.targetScores targetQuery targetKeys) (fun t => targetValues t coordinate)
    (SdpaVector.scoreBudgets p query keys targetQuery errorQuery targetKeys errorKeys) (fun t => errorValues t coordinate)
    _ _ (SdpaTwoPassLayout.keys steps blocks block) SdpaVector.initialShift (hf.first coordinate block).loop
  · intro t
    exact SdpaScore.source_error p.scoreContracted p.merge.reduce p.merge.reduction query (keys t)
      targetQuery (targetKeys t) errorQuery (errorKeys t) he.query (he.keys t) hf.queryFinite (hf.keysFinite t) (hf.scores t)
  · intro t
    rw [SdpaVector.valuesAt, BFloat16.widen_real _ (hf.valuesFinite t coordinate)]
    exact he.values t coordinate

theorem forward_error (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (targetQuery errorQuery : Fin 256 → ℝ)
    (targetKeys targetValues errorKeys errorValues : Fin steps → Fin 256 → ℝ)
    (he : SdpaVector.InputError query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues)
    (hf : Finite p contracted blocks query keys values) (hn : 0 < steps) (hb : 0 < blocks) (coordinate : Fin 256) :
    |Model.toReal (forward p contracted blocks query keys values coordinate)-
      SdpaVector.target targetQuery targetKeys targetValues coordinate| ≤
      budget p contracted blocks query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate := by
  have coverage := SdpaTwoPassLayout.coverage steps blocks hb
  have nonempty : (List.finRange blocks).flatMap (SdpaTwoPassLayout.keys steps blocks) ≠ [] := by
    intro empty
    have member := coverage.mem_iff.mpr (List.mem_finRange (⟨0, hn⟩ : Fin steps))
    change (⟨0, hn⟩ : Fin steps) ∈ (List.finRange blocks).flatMap (SdpaTwoPassLayout.keys steps blocks) at member
    rw [empty] at member
    exact List.not_mem_nil member
  have h := SdpaTwoPassMerge.normalized_error p.merge p.normalization contracted (partials p query keys values coordinate)
    (commonShift p blocks query keys values) (SdpaVector.targetScores targetQuery targetKeys)
    (fun t => targetValues t coordinate) (SdpaTwoPassLayout.keys steps blocks)
    (partialBudgets p query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues coordinate)
    (partials_error p contracted blocks query keys values targetQuery errorQuery targetKeys targetValues errorKeys errorValues he hf coordinate)
    (hf.merge coordinate) (hf.normalization coordinate) nonempty
  have href := OnlineSoftmax.reference_permutation (SdpaVector.targetScores targetQuery targetKeys)
    (fun t => targetValues t coordinate) _ _ coverage (real (commonShift p blocks query keys values))
  have ht := congrArg OnlineSoftmax.normalized href
  simp only [OnlineSoftmax.normalized_reference] at ht
  dsimp only [SdpaTwoPassLayout.allKeys] at href ht
  rw [ht, href] at h
  exact h

theorem forward_finite (p : SdpaVector.Platform) (contracted : Bool) (blocks : Nat) (query : Fin 256 → BF)
    (keys values : Fin steps → Fin 256 → BF) (hf : Finite p contracted blocks query keys values) (coordinate : Fin 256) :
    Model.isFinite (forward p contracted blocks query keys values coordinate) = true := (hf.normalization coordinate).cast

end Inference.Kernels.Attention.SdpaTwoPassVector
