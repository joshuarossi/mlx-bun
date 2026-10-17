import models.qwen.TrellisMlp
import layers.TrellisCodebookRanges
import kernels.trellis.GateUpSplitTailRanges
import kernels.trellis.GateUpFloatTailRanges

namespace Inference.Models.Qwen.TrellisMlpRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis Layers WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def gateCap : BF := BFloat16DyadicBounds.ceiling 90 12
def projectionCap : BF := BFloat16DyadicBounds.ceiling 10 16
def hiddenCap : BF := BFloat16DyadicBounds.ceiling 225 30
def outputCap : BF := BFloat16DyadicBounds.ceiling 240 41

theorem gateCap_range : Model.isFinite gateCap = true ∧ Model.toReal gateCap = 368640 := by
  have h := BFloat16DyadicBounds.ceiling_range 90 12 (by decide) (by decide) (by decide)
  exact ⟨h.1, h.2.trans (by norm_num)⟩
theorem projectionCap_range : Model.isFinite projectionCap = true ∧ Model.toReal projectionCap = 655360 := by
  have h := BFloat16DyadicBounds.ceiling_range 10 16 (by decide) (by decide) (by decide)
  exact ⟨h.1, h.2.trans (by norm_num)⟩
theorem hiddenCap_range : Model.isFinite hiddenCap = true ∧ Model.toReal hiddenCap = 225 * (2 : ℝ)^(30 : Nat) := by
  simpa only [hiddenCap, Nat.cast_ofNat, zpow_ofNat] using
    BFloat16DyadicBounds.ceiling_range 225 30 (by decide) (by decide) (by decide)
theorem outputCap_range : Model.isFinite outputCap = true ∧ Model.toReal outputCap = 240 * (2 : ℝ)^(41 : Nat) := by
  simpa only [outputCap, Nat.cast_ofNat, zpow_ofNat] using
    BFloat16DyadicBounds.ceiling_range 240 41 (by decide) (by decide) (by decide)

def tailProfile : GateUpSplitTailRanges.Profile where
  gateCap := gateCap
  upCap := projectionCap
  outputCap := hiddenCap
  gateFinite := gateCap_range.1
  outputFinite := hiddenCap_range.1
  capacity := by rw [gateCap_range.2, projectionCap_range.2, hiddenCap_range.2]; norm_num

-- Total mathematical arrays use the same bound on their padding values.
-- These are parameter bounds, not assumptions about any intermediate result.
structure Parameters (mlp : GateDown) : Prop where
  gate : ∀ row, (mlp.gate.scale row).isFinite = true ∧ |real (mlp.gate.scale row)| ≤ 9/256
  up : ∀ row, (mlp.up.scale row).isFinite = true ∧ |real (mlp.up.scale row)| ≤ 1/16
  down : ∀ row, (mlp.down.scale row).isFinite = true ∧ |real (mlp.down.scale row)| ≤ 1/32

def InputBound (input : Nat → BitVec 16) : Prop := ∀ i,
  (GateUpExecution.widen (input i)).isFinite = true ∧ |real (GateUpExecution.widen (input i))| ≤ 512

theorem projection (p : TrellisCodebookGateUp.Platform) (w : TrellisCodebookGateUp.Projection)
    (input : Nat → BitVec 16) (hx : InputBound input) (row : Nat) (es : Int) (weightCount : Nat)
    (size : 5120*weightCount < 16777216) (lo : -149 ≤ 2+es) (hi : 2+es+9 ≤ 100)
    (cap : BF) (finite : Model.isFinite cap = true)
    (capacity : (5120*weightCount : Nat) * (2 : ℝ)^(2+es+9) ≤ Model.toReal cap)
    (hw : (w.scale row).isFinite = true ∧ |real (w.scale row)| ≤ (weightCount : ℝ)*(2 : ℝ)^es) :
    TrellisCodebookGateUp.Finite p w input row ∧
      Model.isFinite (BFloat16.narrow (TrellisCodebookGateUp.raw p w input row)) = true ∧
      |Model.toReal (BFloat16.narrow (TrellisCodebookGateUp.raw p w input row))| ≤ Model.toReal cap := by
  have h := TrellisCodebookRanges.gate_raw p w input row es 9 weightCount size lo (by omega) (by omega) hi
    hw (by norm_num; exact hx)
  have hn := BFloat16ConversionBounds.narrow_range (TrellisCodebookGateUp.raw p w input row) cap
    (TrellisCodebookGateUp.raw_finite p w input row h.1) finite (h.2.trans capacity)
  exact ⟨h.1, hn⟩

theorem gate_projection (mlp : GateDown) (params : Parameters mlp) (input : Nat → BitVec 16) (hx : InputBound input) (row : Nat) :
    TrellisCodebookGateUp.Finite mlp.gatePlatform mlp.gate input row ∧
      Model.isFinite (BFloat16.narrow (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.gate input row)) = true ∧
      |Model.toReal (BFloat16.narrow (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.gate input row))| ≤ Model.toReal gateCap :=
  projection mlp.gatePlatform mlp.gate input hx row (-8) 9 (by decide) (by decide) (by decide) gateCap
    gateCap_range.1 (by rw [gateCap_range.2]; norm_num) (by norm_num; exact params.gate row)

theorem up_projection (mlp : GateDown) (params : Parameters mlp) (input : Nat → BitVec 16) (hx : InputBound input) (row : Nat) :
    TrellisCodebookGateUp.Finite mlp.gatePlatform mlp.up input row ∧
      Model.isFinite (BFloat16.narrow (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.up input row)) = true ∧
      |Model.toReal (BFloat16.narrow (TrellisCodebookGateUp.raw mlp.gatePlatform mlp.up input row))| ≤ Model.toReal projectionCap :=
  projection mlp.gatePlatform mlp.up input hx row (-4) 1 (by decide) (by decide) (by decide) projectionCap
    projectionCap_range.1 (by rw [projectionCap_range.2]; norm_num) (by norm_num; exact params.up row)

structure SplitPrimitive (expAbs : BF → BF) where
  expError : BF → ℝ
  exponential : GateUpSplitTail.ExpAbsContract expAbs expError
  expRange : SigmoidRanges.ExponentialRange expAbs

-- Ranges use only expRange; the error function is free.
structure FloatPrimitive (expNeg : Float32 → Float32) where
  expError : Float32 → ℝ
  exponential : GateUpTail.ExpNegContract expNeg expError
  expRange : GateUpFloatTailRanges.ExponentialRange expNeg

-- Scalar exponential premises for the statically selected tail.
def ActivationPrimitive : Activation → Type
  | .float expNeg => FloatPrimitive expNeg
  | .split expAbs => SplitPrimitive expAbs

abbrev ProjectionRange (p : TrellisCodebookGateUp.Platform) (w : TrellisCodebookGateUp.Projection)
    (input : Nat → BitVec 16) (row : Nat) (cap : BF) : Prop :=
  TrellisCodebookGateUp.Finite p w input row ∧
    Model.isFinite (BFloat16.narrow (TrellisCodebookGateUp.raw p w input row)) = true ∧
    |Model.toReal (BFloat16.narrow (TrellisCodebookGateUp.raw p w input row))| ≤ Model.toReal cap

theorem cast_range (x : Float32) (cap : BF)
    (h : Model.isFinite (BFloat16.narrow x) = true ∧ |Model.toReal (BFloat16.narrow x)| ≤ Model.toReal cap) :
    (BFloat16.cast x).isFinite = true ∧ |real (BFloat16.cast x)| ≤ Model.toReal cap := by
  refine ⟨BFloat16.widen_finite _ h.1, ?_⟩
  change |real (BFloat16.widen (BFloat16.narrow x))| ≤ _
  rw [BFloat16.widen_real _ h.1]
  exact h.2

noncomputable def activationBudget (a : Activation) (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (h : ActivationPrimitive a) (row : Nat) : ℝ :=
  match a, h with
  | .float expNeg, h => TrellisCodebookGateUp.layerBudget p gate up input row
      (real (BFloat16.cast (TrellisCodebookGateUp.raw p up input row)))
      (GateUpTailFlushToZero.validBudget expNeg h.expError
        (BFloat16.cast (TrellisCodebookGateUp.raw p gate input row))
        (BFloat16.cast (TrellisCodebookGateUp.raw p up input row)))
  | .split expAbs, h => TrellisCodebookGateUp.layerBudget p gate up input row
      (Model.toReal (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row)))
      (GateUpSplitTail.tailBudget expAbs
        (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row))
        (BFloat16.narrow (TrellisCodebookGateUp.raw p up input row))
        (Kernels.Delta.Gates.betaBudget expAbs h.expError
          (BFloat16.narrow (TrellisCodebookGateUp.raw p gate input row))))

theorem tail_ranges (a : Activation) (h : ActivationPrimitive a) (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16) (row : Nat)
    (hg : ProjectionRange p gate input row gateCap) (hu : ProjectionRange p up input row projectionCap) :
    (hidden a p gate up input row).isFinite = true ∧
      |real (hidden a p gate up input row)| ≤ Model.toReal hiddenCap ∧
      |real (hidden a p gate up input row) - TrellisCodebookGateUp.layerTarget gate up input row| ≤
        activationBudget a p gate up input h row := by
  match a, h with
  | .float expNeg, h =>
    have ht := GateUpFloatTailRanges.ranges tailProfile expNeg h.expRange _ _
      (cast_range _ _ hg.2) (cast_range _ _ hu.2)
    exact ⟨ht.2.1, ht.2.2, TrellisCodebookGateUp.float_valid_error p gate up input row expNeg h.expError
      h.exponential hg.1 hu.1 hg.2.1 hu.2.1 ht.1⟩
  | .split expAbs, h =>
    have ht := GateUpSplitTailRanges.ranges tailProfile expAbs h.expError h.exponential h.expRange _ _ hg.2 hu.2
    have he := GateUpSplitTailRanges.error tailProfile expAbs h.expError h.exponential h.expRange _ _ hg.2 hu.2
    have hc := TrellisCodebookGateUp.split_compose p gate up input row expAbs _
      hg.1 hu.1 hg.2.1 hu.2.1 ht.2.2.1 he
    refine ⟨BFloat16.widen_finite _ ht.2.2.1, ?_, hc⟩
    change |real (TrellisCodebookGateUp.splitOutput p gate up input row expAbs)| ≤ _
    rw [TrellisCodebookGateUp.splitOutput, BFloat16.widen_real _ ht.2.2.1]
    exact ht.2.2.2

def tail_finite (a : Activation) (h : ActivationPrimitive a) (p : TrellisCodebookGateUp.Platform)
    (gate up : TrellisCodebookGateUp.Projection) (input : Nat → BitVec 16)
    (hg : ∀ row, ProjectionRange p gate input row gateCap) (hu : ∀ row, ProjectionRange p up input row projectionCap) :
    TrellisMlp.TailFinite a p gate up input :=
  match a, h with
  | .float expNeg, h => ({
      expError := h.expError
      exponential := h.exponential
      gateFinite := fun row => (hg row.val).1
      upFinite := fun row => (hu row.val).1
      gateCast := fun row => (hg row.val).2.1
      upCast := fun row => (hu row.val).2.1
      tail := fun row => (GateUpFloatTailRanges.ranges tailProfile expNeg h.expRange _ _
        (cast_range _ _ (hg row.val).2) (cast_range _ _ (hu row.val).2)).1 } : TrellisMlp.FloatFinite p gate up input expNeg)
  | .split expAbs, h => ({
      expError := h.expError
      exponential := h.exponential
      gateFinite := fun row => (hg row.val).1
      upFinite := fun row => (hu row.val).1
      sigmoid := fun row => (GateUpSplitTailRanges.ranges tailProfile expAbs h.expError h.exponential h.expRange _ _
        (hg row.val).2 (hu row.val).2).1
      products := fun row => (GateUpSplitTailRanges.ranges tailProfile expAbs h.expError h.exponential h.expRange _ _
        (hg row.val).2 (hu row.val).2).2.1 } : TrellisMlp.SplitFinite p gate up input expAbs)

noncomputable def localBudget (mlp : GateDown) (input : Nat → BitVec 16)
    (activation : ActivationPrimitive mlp.activation) (row : Nat) : ℝ :=
  activationBudget mlp.activation mlp.gatePlatform mlp.gate mlp.up input activation row

theorem hidden_ranges (mlp : GateDown) (params : Parameters mlp) (input : Nat → BitVec 16) (hx : InputBound input)
    (activation : ActivationPrimitive mlp.activation) (row : Nat) :
    (mlp.intermediate input row).isFinite = true ∧
      |real (mlp.intermediate input row)| ≤ Model.toReal hiddenCap ∧
      |real (mlp.intermediate input row) - TrellisCodebookGateUp.layerTarget mlp.gate mlp.up input row| ≤
        localBudget mlp input activation row :=
  tail_ranges mlp.activation activation mlp.gatePlatform mlp.gate mlp.up input row
    (gate_projection mlp params input hx row) (up_projection mlp params input hx row)

noncomputable def hiddenContract (mlp : GateDown) (params : Parameters mlp) (input : Nat → BitVec 16) (hx : InputBound input)
    (activation : ActivationPrimitive mlp.activation) :
    HiddenContract mlp.activation mlp.gatePlatform mlp.gate mlp.up input where
  error := localBudget mlp input activation
  accuracy row := (hidden_ranges mlp params input hx activation row.val).2.2

theorem ranges (mlp : GateDown) (params : Parameters mlp) (input : Nat → BitVec 16) (hx : InputBound input)
    (activation : ActivationPrimitive mlp.activation) :
    TrellisCodebookDown.Finite mlp.downPlatform mlp.down (mlp.intermediate input) ∧
      ∀ col, |Model.toReal (mlp.forward input col)| ≤ Model.toReal outputCap := by
  have hi (row : Nat) := hidden_ranges mlp params input hx activation row
  have hr (col : Fin 5120) := TrellisCodebookRanges.down_raw mlp.downPlatform mlp.down (mlp.intermediate input)
    (-5) 30 225 (by decide) (by decide) (by decide) (by decide) (by decide)
    (by norm_num; exact params.down)
    (fun row => ⟨(hi row).1, by simpa only [hiddenCap_range.2, zpow_ofNat, Nat.cast_ofNat] using (hi row).2.1⟩) col
  have hn (col : Fin 5120) := BFloat16ConversionBounds.narrow_range
    (TrellisCodebookDown.raw mlp.downPlatform mlp.down (mlp.intermediate input) col) outputCap
    (hr col).2.1 outputCap_range.1 (by
      apply (hr col).2.2.trans
      rw [outputCap_range.2]
      norm_num)
  exact ⟨⟨fun col => (hr col).1, fun col => (hn col).1⟩, fun col => (hn col).2⟩

theorem accuracy (mlp : GateDown) (params : Parameters mlp) (input : Nat → BitVec 16) (hx : InputBound input)
    (activation : ActivationPrimitive mlp.activation) (ideal inputError : Fin 5120 → ℝ)
    (hi : ∀ c, |real (GateUpExecution.widen (input c.val)) - ideal c| ≤ inputError c) (col : Fin 5120) :
    Model.isFinite (mlp.forward input col) = true ∧
      |Model.toReal (mlp.forward input col)| ≤ Model.toReal outputCap ∧
      |Model.toReal (mlp.forward input col) - mlp.target ideal col| ≤
        mlp.errorBudget input ideal inputError (hiddenContract mlp params input hx activation) col := by
  have h := ranges mlp params input hx activation
  exact ⟨mlp.forward_finite input h.1 col, h.2 col,
    mlp.forward_error input ideal inputError hi _ h.1 col⟩

noncomputable def finite (mlp : GateDown) (params : Parameters mlp) (input : Nat → BitVec 16) (hx : InputBound input)
    (activation : ActivationPrimitive mlp.activation) : TrellisMlp.Finite mlp input where
  tail := tail_finite mlp.activation activation mlp.gatePlatform mlp.gate mlp.up input
    (gate_projection mlp params input hx) (up_projection mlp params input hx)
  down := (ranges mlp params input hx activation).1

end Inference.Models.Qwen.TrellisMlpRanges
