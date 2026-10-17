import kernels.quantization.MlxQmv

namespace Inference.Layers.AffineVerifyLinear
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Quantization
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

-- The selected Qwen projections have no additive linear bias and no adapter.
-- Quantization biases are included in the decoded weights, as required by
-- affineRow and MLX quantizedMatmul. The input width is 512 * steps.
structure Projection3 (steps rows : Nat) where
  platform : AffineRow.Platform
  weights : Fin rows → AffineRow.Weights3 steps
structure Projection4 (steps rows : Nat) where
  platform : AffineRow.Platform
  weights : Fin rows → AffineRow.Weights4 steps

def Projection3.forward (p : Projection3 steps rows) (x : Fin (steps * 512) → BF) (row : Fin rows) : BF :=
  AffineRow.output p.platform (AffineRow.tiles3 p.platform x (p.weights row))
def Projection4.forward (p : Projection4 steps rows) (x : Fin (steps * 512) → BF) (row : Fin rows) : BF :=
  AffineRow.output p.platform (AffineRow.tiles4 p.platform x (p.weights row))

def Projection3.plainForward (p : Projection3 steps rows) (x : Fin (steps * 512) → BF) (row : Fin rows) : BF :=
  AffineRow.output p.platform (MlxQmv.tiles3 p.platform x (p.weights row))
def Projection4.plainForward (p : Projection4 steps rows) (x : Fin (steps * 512) → BF) (row : Fin rows) : BF :=
  AffineRow.output p.platform (MlxQmv.tiles4 p.platform x (p.weights row))

theorem Projection3.plain_eq (p : Projection3 steps rows) (x : Fin (steps * 512) → BF) : p.plainForward x = p.forward x := by
  funext row
  rw [plainForward, MlxQmv.tiles3_eq]
  rfl
theorem Projection4.plain_eq (p : Projection4 steps rows) (x : Fin (steps * 512) → BF) : p.plainForward x = p.forward x := by
  funext row
  rw [plainForward, MlxQmv.tiles4_eq]
  rfl

noncomputable def Projection3.target (p : Projection3 steps rows) (x : Fin (steps * 512) → ℝ) (row : Fin rows) : ℝ :=
  ∑ i, x i * AffineRow.weight3 (p.weights row) i
noncomputable def Projection4.target (p : Projection4 steps rows) (x : Fin (steps * 512) → ℝ) (row : Fin rows) : ℝ :=
  ∑ i, x i * AffineRow.weight4 (p.weights row) i

structure Projection3.Finite (p : Projection3 steps rows) (x : Fin (steps * 512) → BF) : Prop where
  tiles : ∀ row step lane, AffineTile.Finite3 p.platform.tile (AffineRow.slice x step lane) ((p.weights row).bytes step lane)
    ((p.weights row).scale (AffineRow.groupIndex step lane)) ((p.weights row).bias (AffineRow.groupIndex step lane))
  reduction : ∀ row, Arithmetic.Finite (AffineRow.bind (AffineRow.tiles3 p.platform x (p.weights row))) (AffineRow.expression steps p.platform.reduction.tree)
  cast : ∀ row, Model.isFinite (p.forward x row) = true
structure Projection4.Finite (p : Projection4 steps rows) (x : Fin (steps * 512) → BF) : Prop where
  tiles : ∀ row step lane, AffineTile.Finite4 p.platform.tile (AffineRow.slice x step lane) ((p.weights row).words step lane)
    ((p.weights row).scale (AffineRow.groupIndex step lane)) ((p.weights row).bias (AffineRow.groupIndex step lane))
  reduction : ∀ row, Arithmetic.Finite (AffineRow.bind (AffineRow.tiles4 p.platform x (p.weights row))) (AffineRow.expression steps p.platform.reduction.tree)
  cast : ∀ row, Model.isFinite (p.forward x row) = true

noncomputable def Projection3.budget (p : Projection3 steps rows) (x : Fin (steps * 512) → BF)
    (target error : Fin (steps * 512) → ℝ) (row : Fin rows) : ℝ :=
  AffineRow.budget p.platform (AffineRow.tiles3 p.platform x (p.weights row))
    (AffineRow.targets3 target (p.weights row)) (AffineRow.tileBudgets3 p.platform x (p.weights row) target error)
noncomputable def Projection4.budget (p : Projection4 steps rows) (x : Fin (steps * 512) → BF)
    (target error : Fin (steps * 512) → ℝ) (row : Fin rows) : ℝ :=
  AffineRow.budget p.platform (AffineRow.tiles4 p.platform x (p.weights row))
    (AffineRow.targets4 target (p.weights row)) (AffineRow.tileBudgets4 p.platform x (p.weights row) target error)

theorem Projection3.forward_error (p : Projection3 steps rows) (x : Fin (steps * 512) → BF)
    (target error : Fin (steps * 512) → ℝ) (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : p.Finite x) (row : Fin rows) :
    |Model.toReal (p.forward x row) - p.target target row| ≤ p.budget x target error row :=
  AffineRow.row3_error p.platform x (p.weights row) target error hi (hf.tiles row) (hf.reduction row) (hf.cast row)
theorem Projection4.forward_error (p : Projection4 steps rows) (x : Fin (steps * 512) → BF)
    (target error : Fin (steps * 512) → ℝ) (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : p.Finite x) (row : Fin rows) :
    |Model.toReal (p.forward x row) - p.target target row| ≤ p.budget x target error row :=
  AffineRow.row4_error p.platform x (p.weights row) target error hi (hf.tiles row) (hf.reduction row) (hf.cast row)

theorem Projection3.plain_error (p : Projection3 steps rows) (x : Fin (steps * 512) → BF)
    (target error : Fin (steps * 512) → ℝ) (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : p.Finite x) (row : Fin rows) :
    |Model.toReal (p.plainForward x row) - p.target target row| ≤ p.budget x target error row := by
  rw [p.plain_eq]
  exact p.forward_error x target error hi hf row
theorem Projection4.plain_error (p : Projection4 steps rows) (x : Fin (steps * 512) → BF)
    (target error : Fin (steps * 512) → ℝ) (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : p.Finite x) (row : Fin rows) :
    |Model.toReal (p.plainForward x row) - p.target target row| ≤ p.budget x target error row := by
  rw [p.plain_eq]
  exact p.forward_error x target error hi hf row

theorem Projection3.forward_finite (p : Projection3 steps rows) (x : Fin (steps * 512) → BF) (hf : p.Finite x) (row : Fin rows) :
    Model.isFinite (p.forward x row) = true := hf.cast row
theorem Projection4.forward_finite (p : Projection4 steps rows) (x : Fin (steps * 512) → BF) (hf : p.Finite x) (row : Fin rows) :
    Model.isFinite (p.forward x row) = true := hf.cast row

-- A graph fixes this constructor when loading its weights. Eliminating the
-- sum type proves both static specializations; it adds no fit test to inference.
inductive Projection (steps rows : Nat) where
  | bits3 : Projection3 steps rows → Projection steps rows
  | bits4 : Projection4 steps rows → Projection steps rows

def Projection.forward (p : Projection steps rows) (x : Fin (steps * 512) → BF) : Fin rows → BF :=
  match p with | .bits3 p => p.forward x | .bits4 p => p.forward x
noncomputable def Projection.target (p : Projection steps rows) (x : Fin (steps * 512) → ℝ) : Fin rows → ℝ :=
  match p with | .bits3 p => p.target x | .bits4 p => p.target x
noncomputable def Projection.budget (p : Projection steps rows) (x : Fin (steps * 512) → BF)
    (target error : Fin (steps * 512) → ℝ) : Fin rows → ℝ :=
  match p with | .bits3 p => p.budget x target error | .bits4 p => p.budget x target error
def Projection.Finite (p : Projection steps rows) (x : Fin (steps * 512) → BF) : Prop :=
  match p with | .bits3 p => p.Finite x | .bits4 p => p.Finite x

theorem Projection.forward_error (p : Projection steps rows) (x : Fin (steps * 512) → BF)
    (target error : Fin (steps * 512) → ℝ) (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (hf : p.Finite x) (row : Fin rows) :
    |Model.toReal (p.forward x row) - p.target target row| ≤ p.budget x target error row := by
  cases p with
  | bits3 p => exact p.forward_error x target error hi hf row
  | bits4 p => exact p.forward_error x target error hi hf row

theorem Projection.forward_finite (p : Projection steps rows) (x : Fin (steps * 512) → BF) (hf : p.Finite x) (row : Fin rows) :
    Model.isFinite (p.forward x row) = true := by
  cases p with
  | bits3 p => exact p.forward_finite x hf row
  | bits4 p => exact p.forward_finite x hf row

-- A device barrier / command dependency supplies visibility. Storage and the
-- value observed at each output index are proved independently of ordering.
def store (values : Fin rows → BF) (before : Nat → BF) (schedule : List Nat) : Nat → BF :=
  Memory.writeCells (fun i => if h : i < rows then values ⟨i, h⟩ else before i) schedule before

theorem stored_read (values : Fin rows → BF) (before : Nat → BF) (schedule : List Nat)
    (order : schedule.Perm (List.range rows)) (i : Fin rows) : store values before schedule i.val = values i := by
  have hi : i.val ∈ schedule := order.mem_iff.mpr (List.mem_range.mpr i.isLt)
  simp only [store, Memory.writeCells_read, hi, ite_true, i.isLt, dite_true]

theorem stored_frame (values : Fin rows → BF) (before : Nat → BF) (schedule : List Nat)
    (order : schedule.Perm (List.range rows)) (i : Nat) (hi : rows ≤ i) : store values before schedule i = before i := by
  have hn : i ∉ schedule := fun h => (Nat.not_lt.mpr hi) (List.mem_range.mp (order.mem_iff.mp h))
  simp only [store, Memory.writeCells_read, hn, ite_false]

end Inference.Layers.AffineVerifyLinear
