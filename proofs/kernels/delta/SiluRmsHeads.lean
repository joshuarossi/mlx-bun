import kernels.delta.Gates
import kernels.delta.Gated
import contracts.mlx.NormalizationReduction
import contracts.mlx.NormalizationExecution

namespace Inference.Kernels.Delta.SiluRmsHeads
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Trellis
abbrev BF := BFloat16Arithmetic.Value

-- The selected Qwen kernel has 128 coordinates per head: four consecutive
-- coordinates in each of 32 lanes, followed by one SIMD reduction.
def columns (lane : Fin 32) : List (Fin 128) := (List.finRange 4).map (Gated.laneIndex lane)
def laneExpr (contracted : Bool) (lane : Fin 32) : SquaredSum.Expr 128 :=
  SquaredSum.accumulate contracted (columns lane) .zero
def expression (contracted : Bool) (tree : Reduction.Tree 32) : SquaredSum.Expr 128 :=
  SquaredSum.reduceTree (laneExpr contracted) tree

theorem columns_complete : ((List.finRange 32).flatMap columns).Perm (List.finRange 128) := by
  change ((List.finRange 32).flatMap (fun lane => (List.finRange 4).map (Gated.laneIndex lane))).Perm (List.finRange 128)
  have h : (((List.finRange 32).product (List.finRange 4)).map Gated.laneEquiv).Perm (List.finRange 128) := by
    apply (List.perm_ext_iff_of_nodup
      (((List.nodup_finRange 32).product (List.nodup_finRange 4)).map Gated.laneEquiv.injective)
      (List.nodup_finRange 128)).mpr
    intro i
    constructor
    · intro _; exact List.mem_finRange i
    · intro _
      exact List.mem_map.mpr ⟨Gated.laneEquiv.symm i,
        List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩, Gated.laneEquiv.apply_symm_apply i⟩
  simpa only [List.product, List.map_flatMap, List.map_map, Function.comp_def,
    Gated.laneEquiv, Equiv.coe_fn_mk] using h

theorem expression_coverage (contracted : Bool) (tree : Reduction.Tree 32)
    (hc : (Reduction.leaves tree).Perm (List.finRange 32)) :
    (SquaredSum.indices (expression contracted tree)).Perm (List.finRange 128) := by
  unfold expression
  rw [SquaredSum.reduceTree_indices]
  have h := hc.flatMap (fun lane _ => SquaredSum.accumulate_indices contracted (columns lane) .zero)
  simp only [SquaredSum.indices, List.nil_append] at h
  exact h.trans columns_complete

def sourceSum (reduce : (Fin 32 → Float32) → Float32) (contracted : Bool) (input : Fin 128 → Float32) : Float32 :=
  reduce (fun lane => (List.finRange 4).foldl
    (fun acc offset => SquaredSum.arithmeticStep contracted input acc (Gated.laneIndex lane offset)) 0)

theorem sum_execution (reduce : (Fin 32 → Float32) → Float32) (reduction : FlushedReduction.SimdContract reduce)
    (contracted : Bool) (input : Fin 128 → Float32) :
    sourceSum reduce contracted input = SquaredSum.evaluate input (expression contracted reduction.tree) := by
  unfold sourceSum expression
  rw [reduction.execution, NormalizationReduction.evaluate_reduceTree]
  apply congrArg (fun f => FlushedReduction.evaluate f reduction.tree)
  funext lane
  rw [laneExpr, SquaredSum.evaluate_accumulate]
  simp only [columns, List.foldl_map, SquaredSum.evaluate]

structure Platform where
  expAbs : BF → BF
  expAbsError : BF → ℝ
  exponential : GateUpSplitTail.ExpAbsContract expAbs expAbsError
  reduce : (Fin 32 → Float32) → Float32
  reduction : FlushedReduction.SimdContract reduce
  contracted : Bool
  divide : Float32 → Float32 → Float32
  divError : Float32 → Float32 → ℝ
  division : Division.Contract divide divError
  rsqrt : Float32 → Float32
  rsqrtError : Float32 → ℝ
  rootAccuracy : Normalization.RsqrtContract rsqrt rsqrtError

def activate (p : Platform) (x : BF) : BF := BFloat16Arithmetic.mul x (GateUpSplitTail.sigmoidValue p.expAbs x)
noncomputable def silu (x : ℝ) : ℝ := x * GateUpTail.sigmoid x

structure ActivationFinite (p : Platform) (x : BF) : Prop where
  input : Model.isFinite x = true
  sigmoid : Gates.BetaValid p.expAbs x
  product : Model.isFinite (Model.mul (BFloat16Arithmetic.flush x)
    (BFloat16Arithmetic.flush (GateUpSplitTail.sigmoidValue p.expAbs x))) = true

noncomputable def activationBudget (p : Platform) (x : BF) : ℝ :=
  BFloat16Arithmetic.mulBudget x (GateUpSplitTail.sigmoidValue p.expAbs x) +
    |Model.toReal x| * Gates.betaBudget p.expAbs p.expAbsError x

theorem activate_finite (p : Platform) (x : BF) (hf : ActivationFinite p x) : Model.isFinite (activate p x) = true :=
  BFloat16Arithmetic.finite_flush _ hf.product

theorem activate_error (p : Platform) (x : BF) (hf : ActivationFinite p x) :
    |Model.toReal (activate p x) - silu (Model.toReal x)| ≤ activationBudget p x := by
  have hb := Gates.beta_total_error p.expAbs p.expAbsError p.exponential x hf.input hf.sigmoid (Model.toReal x) 0 (by simp)
  simp only [zero_div, add_zero] at hb
  have hm := BFloat16Arithmetic.mul_error x (GateUpSplitTail.sigmoidValue p.expAbs x) hf.input
    (Gates.beta_finite p.expAbs p.expAbsError p.exponential x hf.sigmoid) hf.product
  have hs := mul_le_mul_of_nonneg_left hb (abs_nonneg (Model.toReal x))
  rw [← abs_mul] at hs
  unfold silu activationBudget
  calc
    _ = |(Model.toReal (activate p x) - Model.toReal x * Model.toReal (GateUpSplitTail.sigmoidValue p.expAbs x)) +
      Model.toReal x * (Model.toReal (GateUpSplitTail.sigmoidValue p.expAbs x) - GateUpTail.sigmoid (Model.toReal x))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hm hs)

noncomputable def activationInputBudget (p : Platform) (x : BF) (target error : ℝ) : ℝ :=
  activationBudget p x + error * (1 + |target| / 4)

theorem activate_input_error (p : Platform) (x : BF) (hf : ActivationFinite p x) (target error : ℝ)
    (he : |Model.toReal x - target| ≤ error) :
    |Model.toReal (activate p x) - silu target| ≤ activationInputBudget p x target error := by
  have hl := activate_error p x hf
  have hi := SwiGLUStability.silu_perturbation (Model.toReal x) target error he
  calc
    _ = |(Model.toReal (activate p x) - silu (Model.toReal x)) + (silu (Model.toReal x) - silu target)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl hi)

def activated (p : Platform) (input : Fin 128 → BF) : Fin 128 → Float32 :=
  fun i => BFloat16.widen (activate p (input i))

-- No runtime condition selects a normalization on this fixed Q/K head path.
-- Value heads use activate directly; their coordinates have the theorem above.
def normalized (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32) (i : Fin 128) : BF :=
  BFloat16Arithmetic.mul (weight i) (BFloat16.narrow
    (NormalizationExecution.normalized p.divide (activated p input) (expression p.contracted p.reduction.tree) width eps p.rsqrt i))

def sourceNormalized (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32) (i : Fin 128) : BF :=
  let sum := sourceSum p.reduce p.contracted (activated p input)
  let inverse := p.rsqrt (FlushToZero.add (p.divide sum width) eps)
  BFloat16Arithmetic.mul (weight i) (BFloat16.narrow (FlushToZero.mul (activated p input i) inverse))

theorem normalized_execution (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32) (i : Fin 128) :
    sourceNormalized p input weight width eps i = normalized p input weight width eps i := by
  unfold sourceNormalized
  rw [sum_execution p.reduce p.reduction]
  rfl

def NormFinite (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32) : Prop :=
  NormalizationExecution.Finite p.divide (activated p input) weight (expression p.contracted p.reduction.tree) width eps p.rsqrt

noncomputable def normBudget (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (i : Fin 128) : ℝ :=
  NormalizationExecution.outputBudget p.divide p.divError (activated p input) weight
    (expression p.contracted p.reduction.tree) width eps idealEps epsError p.rsqrt p.rsqrtError i

theorem normalized_finite (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32)
    (hf : NormFinite p input weight width eps) (i : Fin 128) : Model.isFinite (normalized p input weight width eps i) = true :=
  BFloat16Arithmetic.finite_flush _ (hf.hOutput i)

theorem normalized_error (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : NormFinite p input weight width eps) (i : Fin 128) :
    |Model.toReal (normalized p input weight width eps i) -
      Normalization.rmsNorm (fun j => real (activated p input j)) (fun j => Model.toReal (weight j)) idealEps i| ≤
      normBudget p input weight width eps idealEps epsError i := by
  have h := NormalizationExecution.accuracy p.divide p.divError p.division (activated p input) weight
    (expression p.contracted p.reduction.tree) (expression_coverage p.contracted p.reduction.tree p.reduction.coverage)
    width eps idealEps epsError hp he p.rsqrt p.rsqrtError p.rootAccuracy hf i
  change |real (BFloat16.widen (normalized p input weight width eps i)) - _| ≤ _ at h
  rwa [BFloat16.widen_real _ (normalized_finite p input weight width eps hf i)] at h

noncomputable def inputBudget (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (target error : Fin 128 → ℝ) (i : Fin 128) : ℝ :=
  normBudget p input weight width eps idealEps epsError i + |Model.toReal (weight i)| *
    Normalization.inputBudget (fun j => real (activated p input j)) (fun j => silu (target j))
      (fun j => activationInputBudget p (input j) (target j) (error j)) idealEps i

theorem normalized_input_error (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32)
    (idealEps epsError : ℝ) (hp : 0 < idealEps) (he : |real eps - idealEps| ≤ epsError)
    (hf : NormFinite p input weight width eps) (ha : ∀ j, ActivationFinite p (input j))
    (target error : Fin 128 → ℝ) (hi : ∀ j, |Model.toReal (input j) - target j| ≤ error j) (i : Fin 128) :
    |Model.toReal (normalized p input weight width eps i) -
      Normalization.rmsNorm (fun j => silu (target j)) (fun j => Model.toReal (weight j)) idealEps i| ≤
      inputBudget p input weight width eps idealEps epsError target error i := by
  have hl := normalized_error p input weight width eps idealEps epsError hp he hf i
  have hs : ∀ j, |real (activated p input j) - silu (target j)| ≤ activationInputBudget p (input j) (target j) (error j) := by
    intro j
    rw [activated, BFloat16.widen_real _ (activate_finite p (input j) (ha j))]
    exact activate_input_error p (input j) (ha j) (target j) (error j) (hi j)
  have ht := Normalization.input_perturbation (fun j => real (activated p input j)) (fun j => silu (target j))
    (fun j => activationInputBudget p (input j) (target j) (error j)) (fun j => Model.toReal (weight j)) idealEps hp hs i
  calc
    _ = |(Model.toReal (normalized p input weight width eps i) -
      Normalization.rmsNorm (fun j => real (activated p input j)) (fun j => Model.toReal (weight j)) idealEps i) +
      (Normalization.rmsNorm (fun j => real (activated p input j)) (fun j => Model.toReal (weight j)) idealEps i -
      Normalization.rmsNorm (fun j => silu (target j)) (fun j => Model.toReal (weight j)) idealEps i)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hl ht)

end Inference.Kernels.Delta.SiluRmsHeads
