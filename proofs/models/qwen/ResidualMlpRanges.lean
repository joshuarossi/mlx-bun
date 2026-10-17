import models.qwen.ResidualBlocks
import models.qwen.TrellisMlpRanges
import models.qwen.NormalizationUniformBounds
import kernels.ResidualRmsNormRanges

namespace Inference.Models.Qwen.ResidualMlpRanges
open Contracts.Mlx Contracts.Mlx.Numerics ResidualBlocks
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

noncomputable def inputCeiling (stage : Nat) : ℝ := (4*stage+1 : Nat) * (2 : ℝ)^(48 : Nat)
def residualCap (stage : Nat) : BF := BFloat16DyadicBounds.ceiling (4*stage+2) 48
def outputCap (stage : Nat) : BF := BFloat16DyadicBounds.ceiling (stage+1) 50

theorem residualCap_range (stage : Nat) (hs : stage < 64) :
    Model.isFinite (residualCap stage) = true ∧
      Model.toReal (residualCap stage) = (4*stage+2 : Nat) * (2 : ℝ)^(48 : Nat) := by
  simpa only [residualCap, zpow_ofNat] using
    BFloat16DyadicBounds.ceiling_range (4*stage+2) 48 (by omega) (by decide) (by decide)

theorem outputCap_range (stage : Nat) (hs : stage < 64) :
    Model.isFinite (outputCap stage) = true ∧
      Model.toReal (outputCap stage) = (stage+1 : Nat) * (2 : ℝ)^(50 : Nat) := by
  simpa only [outputCap, zpow_ofNat] using
    BFloat16DyadicBounds.ceiling_range (stage+1) 50 (by omega) (by decide) (by decide)

def InputBound (stage : Nat) (x : Fin 5120 → BF) : Prop :=
  ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ inputCeiling stage
def UpdateBound (update : Fin 5120 → BF) : Prop :=
  ∀ i, Model.isFinite (update i) = true ∧ |Model.toReal (update i)| ≤ (2 : ℝ)^(44 : Nat)

structure Parameters (b : Mlp) : Prop where
  normalization : ∀ i, Model.isFinite (b.norm.weight i) = true ∧ |Model.toReal (b.norm.weight i)| ≤ 1
  mlp : TrellisMlpRanges.Parameters b.mlp

structure Primitives (b : Mlp) where
  division : DivisionDirectedBounds.Contract b.norm.platform.divide
  root : RsqrtBounds.Envelope b.norm.platform.rsqrt
  activation : TrellisMlpRanges.ActivationPrimitive b.mlp.activation

theorem residual_ranges (stage : Nat) (hs : stage < 64) (x update : Fin 5120 → BF)
    (hx : InputBound stage x) (hu : UpdateBound update) (i : Fin 5120) :
    Kernels.ResidualRmsNorm.AddFinite (x i) (update i) ∧
      |Model.toReal (residual x update i)| ≤ Model.toReal (residualCap stage) := by
  apply Kernels.ResidualRmsNormRanges.addition _ _ _ (hx i).1 (hu i).1 (residualCap_range stage hs).1
  apply (add_le_add (hx i).2 (hu i).2).trans
  rw [inputCeiling, (residualCap_range stage hs).2]
  push_cast
  norm_num
  linarith

theorem residual_ceiling (stage : Nat) (hs : stage < 64) :
    Model.toReal (residualCap stage) ≤ (2 : ℝ)^(56 : Nat) := by
  have h : (stage : ℝ) ≤ 63 := by exact_mod_cast (show stage ≤ 63 by omega)
  rw [(residualCap_range stage hs).2]
  push_cast
  norm_num
  linarith

theorem packed_bound (x : Fin 5120 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ 512) :
    TrellisMlpRanges.InputBound (Blocks.packed x) := by
  intro i
  by_cases hi : i < 5120
  · rw [Blocks.packed_read x ⟨i, hi⟩ (hx ⟨i, hi⟩).1]
    exact ⟨BFloat16.widen_finite _ (hx ⟨i, hi⟩).1, by rw [BFloat16.widen_real _ (hx ⟨i, hi⟩).1]; exact (hx ⟨i, hi⟩).2⟩
  · have hp : Blocks.packed x i = 0 := by
      unfold Blocks.packed
      exact dite_eq_right hi
    have hz : Kernels.Trellis.GateUpExecution.widen (0 : BitVec 16) = (0 : Float32) := by decide +kernel
    rw [hp, hz]
    refine ⟨by decide, ?_⟩
    have hr : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
    rw [hr]; norm_num

structure Result (b : Mlp) (stage : Nat) (x update : Fin 5120 → BF) where
  finite : b.Finite x update
  addition : ElementwiseAdd.Bounds (residual x update) (b.branch x update)
  output : ∀ i, |Model.toReal (b.forward x update i)| ≤ (stage+1 : Nat) * (2 : ℝ)^(50 : Nat)

-- The stage number indexes a proof invariant; it is not a runtime guard.
-- Exact representable ceilings include rounding at both residual additions.
noncomputable def checked (b : Mlp) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x update : Fin 5120 → BF)
    (hx : InputBound stage x) (hu : UpdateBound update) : Result b stage x update := by
  have ha i := residual_ranges stage hs x update hx hu i
  have hn := NormalizationUniformBounds.ranges_wide b.norm primitive.division primitive.root parameters.normalization
    (residual x update) (fun i => ⟨(ha i).1.cast, (ha i).2.trans (residual_ceiling stage hs)⟩)
  have hi : TrellisMlpRanges.InputBound (b.inputBits x update) := packed_bound (b.normalized x update)
    (fun i => ⟨b.norm.forward_finite _ hn.1 i, hn.2 i⟩)
  let hf : b.Finite x update := {
    addition := fun i => (ha i).1
    normalization := hn.1
    mlp := TrellisMlpRanges.finite b.mlp parameters.mlp _ hi primitive.activation }
  have hm := TrellisMlpRanges.ranges b.mlp parameters.mlp _ hi primitive.activation
  have capacity : Model.toReal (residualCap stage) + Model.toReal TrellisMlpRanges.outputCap ≤ Model.toReal (outputCap stage) := by
    rw [(residualCap_range stage hs).2, TrellisMlpRanges.outputCap_range.2, (outputCap_range stage hs).2]
    push_cast
    norm_num
    linarith
  let bounds : ElementwiseAdd.Bounds (residual x update) (b.branch x update) := {
    leftBound := fun _ => Model.toReal (residualCap stage)
    rightBound := fun _ => Model.toReal TrellisMlpRanges.outputCap
    leftFinite := fun i => (ha i).1.cast
    rightFinite := fun i => TrellisMlp.forward_finite b.mlp _ hf.mlp i
    leftMagnitude := fun i => (ha i).2
    rightMagnitude := hm.2
    capacity := fun _ => capacity.trans (BFloat16Bounds.ceiling_max _ (outputCap_range stage hs).1) }
  refine ⟨hf, bounds, fun i => ?_⟩
  have ho := BFloat16Bounds.add_range (residual x update i) (b.branch x update i) (outputCap stage)
    (bounds.leftFinite i) (bounds.rightFinite i) (outputCap_range stage hs).1
    ((add_le_add (bounds.leftMagnitude i) (bounds.rightMagnitude i)).trans capacity)
  simpa only [Mlp.forward, ElementwiseAdd.forward, (outputCap_range stage hs).2] using ho.2

theorem next_input (b : Mlp) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x update : Fin 5120 → BF)
    (hx : InputBound stage x) (hu : UpdateBound update) : InputBound (stage+1) (b.forward x update) := by
  let h := checked b parameters primitive stage hs x update hx hu
  intro i
  refine ⟨ElementwiseAdd.forward_finite _ _ h.addition i, (h.output i).trans ?_⟩
  unfold inputCeiling
  push_cast
  norm_num
  linarith

theorem accuracy (b : Mlp) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x update : Fin 5120 → BF)
    (hx : InputBound stage x) (hu : UpdateBound update)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (ex : ∀ i, |Model.toReal (x i) - targetX i| ≤ errorX i)
    (eu : ∀ i, |Model.toReal (update i) - targetUpdate i| ≤ errorUpdate i) (i : Fin 5120) :
    |Model.toReal (b.forward x update i) - b.target targetX targetUpdate i| ≤
      b.budget x update targetX targetUpdate errorX errorUpdate (checked b parameters primitive stage hs x update hx hu).finite i := by
  let h := checked b parameters primitive stage hs x update hx hu
  exact ElementwiseAdd.forward_error _ _ h.addition (residualTarget targetX targetUpdate)
    (b.branchTarget targetX targetUpdate) (residualBudget x update errorX errorUpdate)
    (b.branchBudget x update targetX targetUpdate errorX errorUpdate h.finite)
    (residual_error x update targetX targetUpdate errorX errorUpdate ex eu h.finite.addition)
    (b.branch_error x update targetX targetUpdate errorX errorUpdate ex eu h.finite) i

end Inference.Models.Qwen.ResidualMlpRanges
