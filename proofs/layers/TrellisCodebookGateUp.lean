import kernels.trellis.GateUpFlushToZero
import kernels.trellis.GateUpSplitTail
import kernels.trellis.GateUpTailFlushToZero
import kernels.trellis.SwiGLUStability
import kernels.trellis.CodebookInitialization

namespace Inference.Layers.TrellisCodebookGateUp
open Contracts.Mlx Contracts.Mlx.Numerics
open Kernels.Trellis
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
set_option maxRecDepth 10000

-- Static single-row geometry is 5120 input columns and 17408 output rows.
-- This composes the reviewed kernel translation. Tensor ownership, dispatch,
-- and the Metal/compiler connection are separate obligations.
structure Platform where
  load : M1Max.ThreadgroupLoad
  loads : M1Max.LoadContract load
  before : M1Max.WordMemory
  base : Nat
  aligned : base%4=0
  bounded : base+16384 ≤ 2^64
  reduce : DownExecution.SimdReduction
  reduction : GateUpFlushToZero.SimdContract reduce

structure Projection where
  words : DownExecution.PackedMatrix
  width : Nat
  validWidth : width=2 ∨ width=3 ∨ width=4
  scale : Nat → Float32

def table (p : Platform) : M1Max.WordMemory :=
  Memory.execute (CodebookInitialization.stores p.base 1024) p.before

theorem table_initialized (p : Platform) : CodebookLoad.Initialized (table p) p.base :=
  CodebookInitialization.initialized p.before p.base 1024 (Or.inr rfl)
    (CodebookInitialization.stores p.base 1024) (List.Perm.refl _)

def raw (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat) : Float32 :=
  p.reduce (fun lane => GateUpFlushToZero.sourceLane p.load (table p) p.base w.words w.width w.scale input row lane.val)

noncomputable def target (w : Projection) (input : Nat → BitVec 16) (row : Nat) : ℝ :=
  ∑ c : Fin 5120, GateUpAccuracy.term w.words w.width w.scale input row c.val

noncomputable def weight (w : Projection) (row col : Nat) : ℝ :=
  GateUpAccuracy.targetCoefficient w.words w.width row col * real (w.scale row)

noncomputable def projectReal (w : Projection) (input : Fin 5120 → ℝ) (row : Nat) : ℝ :=
  ∑ c : Fin 5120, weight w row c.val * input c

noncomputable def propagatedBudget (w : Projection) (inputError : Fin 5120 → ℝ) (row : Nat) : ℝ :=
  ∑ c : Fin 5120, |weight w row c.val| * inputError c

theorem target_eq (w : Projection) (input : Nat → BitVec 16) (row : Nat) :
    target w input row = projectReal w (fun c => real (GateUpExecution.widen (input c.val))) row := rfl

theorem propagated_error (w : Projection) (input : Nat → BitVec 16) (ideal inputError : Fin 5120 → ℝ)
    (hi : ∀ c, |real (GateUpExecution.widen (input c.val)) - ideal c| ≤ inputError c) (row : Nat) :
    |target w input row - projectReal w ideal row| ≤ propagatedBudget w inputError row := by
  rw [target_eq]
  unfold projectReal propagatedBudget
  rw [← Finset.sum_sub_distrib]
  calc
    _ ≤ ∑ c : Fin 5120, |weight w row c.val * real (GateUpExecution.widen (input c.val)) - weight w row c.val * ideal c| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ _ := by
      apply Finset.sum_le_sum
      intro c _
      rw [← mul_sub, abs_mul]
      exact mul_le_mul_of_nonneg_left (hi c) (abs_nonneg _)

def Finite (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat) : Prop :=
  FlushedDotProduct.Finite (fun col => DownExecution.coefficient w.words w.width row col)
    (fun _ => w.scale row) (fun col => GateUpExecution.widen (input col))
    (GateUpFlushToZero.projectionExpr p.reduction.tree)

noncomputable def projectionBudget (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat) : ℝ :=
  FlushedDotProduct.budget (fun col => DownExecution.coefficient w.words w.width row col)
    (fun _ => w.scale row) (fun col => GateUpExecution.widen (input col))
    (fun col => |GateUpAccuracy.targetCoefficient w.words w.width row col|/2^23)
    (GateUpFlushToZero.projectionExpr p.reduction.tree)

theorem raw_error (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat)
    (hf : Finite p w input row) :
    |real (raw p w input row)-target w input row| ≤ projectionBudget p w input row := by
  exact GateUpFlushToZero.source_error p.load p.loads (table p) p.base p.aligned p.bounded
    (table_initialized p) p.reduce p.reduction w.words w.width w.validWidth w.scale input row hf

theorem raw_eq (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat) :
    raw p w input row =
      FlushedDotProduct.evaluate (fun col => DownExecution.coefficient w.words w.width row col)
        (fun _ => w.scale row) (fun col => GateUpExecution.widen (input col))
        (GateUpFlushToZero.projectionExpr p.reduction.tree) := by
  unfold raw
  have lanes : (fun lane : Fin 32 => GateUpFlushToZero.sourceLane p.load (table p) p.base
      w.words w.width w.scale input row lane.val) =
      (fun lane => GateUpFlushToZero.referenceLane w.words w.width w.scale input row lane.val) := by
    funext lane
    exact GateUpFlushToZero.sourceLane_correct p.load p.loads (table p) p.base p.aligned p.bounded
      (table_initialized p) w.words w.width w.validWidth w.scale input row lane.val lane.isLt
  rw [lanes, p.reduction.execution, ← GateUpFlushToZero.evaluate_projection]

theorem raw_finite (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat)
    (hf : Finite p w input row) : (raw p w input row).isFinite=true := by
  rw [raw_eq]
  exact FlushedDotProduct.finite_evaluate _ _ _ _ hf

noncomputable def inputBudget (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat) : ℝ :=
  projectionBudget p w input row + BFloat16.epsilon (real (raw p w input row))

theorem narrow_error (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat)
    (hf : Finite p w input row) (hb : Model.isFinite (BFloat16.narrow (raw p w input row))=true) :
    |Model.toReal (BFloat16.narrow (raw p w input row))-target w input row| ≤ inputBudget p w input row := by
  have hp := raw_error p w input row hf
  have hc := BFloat16.narrow_error (raw p w input row) (raw_finite p w input row hf) hb
  unfold inputBudget
  calc
    _ = |(Model.toReal (BFloat16.narrow (raw p w input row))-real (raw p w input row)) +
        (real (raw p w input row)-target w input row)| := by congr 1; ring
    _ ≤ _ := by have h := (abs_add_le _ _).trans (add_le_add hc hp); linarith

theorem cast_error (p : Platform) (w : Projection) (input : Nat → BitVec 16) (row : Nat)
    (hf : Finite p w input row) (hb : Model.isFinite (BFloat16.narrow (raw p w input row))=true) :
    |real (BFloat16.cast (raw p w input row))-target w input row| ≤ inputBudget p w input row := by
  have hp := raw_error p w input row hf
  have hc := BFloat16.cast_error (raw p w input row) (raw_finite p w input row hf) hb
  unfold inputBudget
  calc
    _ = |(real (BFloat16.cast (raw p w input row))-real (raw p w input row)) +
        (real (raw p w input row)-target w input row)| := by congr 1; ring
    _ ≤ _ := by have h := (abs_add_le _ _).trans (add_le_add hc hp); linarith

noncomputable def layerTarget (gate up : Projection) (input : Nat → BitVec 16) (row : Nat) : ℝ :=
  GateUpTail.swiglu (target gate input row) (target up input row)

noncomputable def idealLayerTarget (gate up : Projection) (input : Fin 5120 → ℝ) (row : Nat) : ℝ :=
  GateUpTail.swiglu (projectReal gate input row) (projectReal up input row)

noncomputable def layerInputBudget (gate up : Projection) (input : Nat → BitVec 16)
    (ideal inputError : Fin 5120 → ℝ) (row : Nat) : ℝ :=
  propagatedBudget gate inputError row * (1 + |projectReal gate ideal row| / 4) * |target up input row| +
    |projectReal gate ideal row| * propagatedBudget up inputError row

theorem layer_input_error (gate up : Projection) (input : Nat → BitVec 16) (ideal inputError : Fin 5120 → ℝ)
    (hi : ∀ c, |real (GateUpExecution.widen (input c.val)) - ideal c| ≤ inputError c) (row : Nat) :
    |layerTarget gate up input row - idealLayerTarget gate up ideal row| ≤ layerInputBudget gate up input ideal inputError row :=
  SwiGLUStability.swiglu_perturbation _ _ _ _ _ _
    (propagated_error gate input ideal inputError hi row) (propagated_error up input ideal inputError hi row)

def splitOutput (p : Platform) (gate up : Projection) (input : Nat → BitVec 16) (row : Nat)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value) : Float32 :=
  BFloat16.widen (GateUpSplitTail.tail expAbs (BFloat16.narrow (raw p gate input row)) (BFloat16.narrow (raw p up input row)))

noncomputable def layerBudget (p : Platform) (gate up : Projection) (input : Nat → BitVec 16)
    (row : Nat) (roundedUp localError : ℝ) : ℝ :=
  localError+inputBudget p gate input row*(1+|target gate input row|/4)*|roundedUp|+
    |target gate input row| *inputBudget p up input row

theorem split_compose (p : Platform) (gate up : Projection) (input : Nat → BitVec 16) (row : Nat)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value) (localError : ℝ)
    (hg : Finite p gate input row) (hu : Finite p up input row)
    (hgb : Model.isFinite (BFloat16.narrow (raw p gate input row))=true)
    (hub : Model.isFinite (BFloat16.narrow (raw p up input row))=true)
    (ho : Model.isFinite (GateUpSplitTail.tail expAbs
      (BFloat16.narrow (raw p gate input row)) (BFloat16.narrow (raw p up input row)))=true)
    (hl : |Model.toReal (GateUpSplitTail.tail expAbs
      (BFloat16.narrow (raw p gate input row)) (BFloat16.narrow (raw p up input row))) -
      GateUpTail.swiglu (Model.toReal (BFloat16.narrow (raw p gate input row)))
        (Model.toReal (BFloat16.narrow (raw p up input row)))| ≤ localError) :
    |real (splitOutput p gate up input row expAbs)-layerTarget gate up input row| ≤
      layerBudget p gate up input row (Model.toReal (BFloat16.narrow (raw p up input row))) localError := by
  unfold splitOutput
  rw [BFloat16.widen_real _ ho]
  exact SwiGLUStability.compose _ _ _ _ _ _ _ _ hl (narrow_error p gate input row hg hgb) (narrow_error p up input row hu hub)

theorem split_finite_error (p : Platform) (gate up : Projection) (input : Nat → BitVec 16) (row : Nat)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value) (error : BFloat16Arithmetic.Value → ℝ)
    (exponential : GateUpSplitTail.ExpAbsContract expAbs error)
    (hg : Finite p gate input row) (hu : Finite p up input row)
    (hs : GateUpSplitTail.SigmoidFinite expAbs (BFloat16.narrow (raw p gate input row)))
    (hp : GateUpSplitTail.ProductsFinite expAbs (BFloat16.narrow (raw p gate input row)) (BFloat16.narrow (raw p up input row))) :
    |real (splitOutput p gate up input row expAbs)-layerTarget gate up input row| ≤
      layerBudget p gate up input row (Model.toReal (BFloat16.narrow (raw p up input row)))
        (GateUpSplitTail.tailBudget expAbs (BFloat16.narrow (raw p gate input row)) (BFloat16.narrow (raw p up input row))
          (GateUpSplitTail.sigmoidBudget expAbs error (BFloat16.narrow (raw p gate input row)))) := by
  exact split_compose p gate up input row expAbs _ hg hu hp.hGate hp.hUp
    (GateUpSplitTail.output_finite expAbs _ _ hp) (GateUpSplitTail.tail_finite_error expAbs error exponential _ _ hs hp)

theorem split_overflow_error (p : Platform) (gate up : Projection) (input : Nat → BitVec 16) (row : Nat)
    (expAbs : BFloat16Arithmetic.Value → BFloat16Arithmetic.Value)
    (hg : Finite p gate input row) (hu : Finite p up input row)
    (hp : GateUpSplitTail.ProductsFinite expAbs (BFloat16.narrow (raw p gate input row)) (BFloat16.narrow (raw p up input row)))
    (he : expAbs (BFloat16.narrow (raw p gate input row))=Model.posInf FloatFormat.bfloat16) :
    |real (splitOutput p gate up input row expAbs)-layerTarget gate up input row| ≤
      layerBudget p gate up input row (Model.toReal (BFloat16.narrow (raw p up input row)))
        (GateUpSplitTail.tailBudget expAbs (BFloat16.narrow (raw p gate input row)) (BFloat16.narrow (raw p up input row))
          (1/(1+Real.exp (|Model.toReal (BFloat16.narrow (raw p gate input row))|)))) := by
  exact split_compose p gate up input row expAbs _ hg hu hp.hGate hp.hUp
    (GateUpSplitTail.output_finite expAbs _ _ hp) (GateUpSplitTail.tail_overflow_error expAbs _ _ hp he)

def floatOutput (p : Platform) (gate up : Projection) (input : Nat → BitVec 16) (row : Nat)
    (expNeg : Float32 → Float32) : Float32 :=
  GateUpTailFlushToZero.tail expNeg (BFloat16.cast (raw p gate input row)) (BFloat16.cast (raw p up input row))

theorem float_finite_error (p : Platform) (gate up : Projection) (input : Nat → BitVec 16) (row : Nat)
    (expNeg : Float32 → Float32) (error : Float32 → ℝ) (exponential : GateUpTail.ExpNegContract expNeg error)
    (hg : Finite p gate input row) (hu : Finite p up input row)
    (hgb : Model.isFinite (BFloat16.narrow (raw p gate input row))=true)
    (hub : Model.isFinite (BFloat16.narrow (raw p up input row))=true)
    (hf : GateUpTailFlushToZero.Finite expNeg (BFloat16.cast (raw p gate input row)) (BFloat16.cast (raw p up input row))) :
    |real (floatOutput p gate up input row expNeg)-layerTarget gate up input row| ≤
      layerBudget p gate up input row (real (BFloat16.cast (raw p up input row)))
        (GateUpTailFlushToZero.tailBudget expNeg error (BFloat16.cast (raw p gate input row)) (BFloat16.cast (raw p up input row))) := by
  exact SwiGLUStability.compose _ _ _ _ _ _ _ _
    (GateUpTailFlushToZero.tail_error expNeg error exponential _ _ hf)
    (cast_error p gate input row hg hgb) (cast_error p up input row hu hub)

theorem float_overflow_error (p : Platform) (gate up : Projection) (input : Nat → BitVec 16) (row : Nat)
    (expNeg : Float32 → Float32)
    (hg : Finite p gate input row) (hu : Finite p up input row)
    (hgb : Model.isFinite (BFloat16.narrow (raw p gate input row))=true)
    (hub : Model.isFinite (BFloat16.narrow (raw p up input row))=true)
    (he : expNeg (BFloat16.cast (raw p gate input row))=Float32.inf)
    (hp : GateUpTailFlushToZero.ProductsFinite expNeg (BFloat16.cast (raw p gate input row)) (BFloat16.cast (raw p up input row))) :
    |real (floatOutput p gate up input row expNeg)-layerTarget gate up input row| ≤
      layerBudget p gate up input row (real (BFloat16.cast (raw p up input row)))
        (GateUpTailFlushToZero.overflowBudget expNeg (BFloat16.cast (raw p gate input row)) (BFloat16.cast (raw p up input row))) := by
  exact SwiGLUStability.compose _ _ _ _ _ _ _ _
    (GateUpTailFlushToZero.tail_overflow_error expNeg _ _ he hp)
    (cast_error p gate input row hg hgb) (cast_error p up input row hu hub)

end Inference.Layers.TrellisCodebookGateUp
