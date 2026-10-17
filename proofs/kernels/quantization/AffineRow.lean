import kernels.quantization.AffineTile
import kernels.quantization.AffineLayout

namespace Inference.Kernels.Quantization.AffineRow
open Contracts.Mlx Contracts.Mlx.Numerics ArithmeticFold
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

structure Platform where
  tile : AffineTile.Platform
  reduce : (Fin 32 → Float32) → Float32
  reduction : FlushedReduction.SimdContract reduce

def bind (tiles : Fin steps → Fin 32 → Float32) (i : Nat) : Float32 :=
  if h : i < steps * 32 then tiles ⟨i/32, by omega⟩ ⟨i%32, by omega⟩ else 0
noncomputable def bindReal (tiles : Fin steps → Fin 32 → ℝ) (i : Nat) : ℝ :=
  if h : i < steps * 32 then tiles ⟨i/32, by omega⟩ ⟨i%32, by omega⟩ else 0

theorem bind_read (tiles : Fin steps → Fin 32 → Float32) (step : Fin steps) (lane : Fin 32) :
    bind tiles (AffineLayout.chunkIndex step lane).val = tiles step lane := by
  simp only [bind, dite_eq_left (AffineLayout.chunkIndex step lane).isLt]
  congr 1 <;> apply Fin.ext <;> dsimp [AffineLayout.chunkIndex] <;> have := lane.isLt <;> omega
theorem bindReal_read (tiles : Fin steps → Fin 32 → ℝ) (step : Fin steps) (lane : Fin 32) :
    bindReal tiles (AffineLayout.chunkIndex step lane).val = tiles step lane := by
  simp only [bindReal, dite_eq_left (AffineLayout.chunkIndex step lane).isLt]
  congr 1 <;> apply Fin.ext <;> dsimp [AffineLayout.chunkIndex] <;> have := lane.isLt <;> omega

def laneExpr (steps : Nat) (lane : Fin 32) : Arithmetic.Expr :=
  (List.finRange steps).foldl (fun acc step => .add acc (.input (AffineLayout.chunkIndex step lane).val)) .zero
def expression (steps : Nat) (tree : Reduction.Tree 32) : Arithmetic.Expr := reduceExpr (laneExpr steps) tree

def laneValue (tiles : Fin steps → Fin 32 → Float32) (lane : Fin 32) : Float32 :=
  (List.finRange steps).foldl (fun acc step => FlushToZero.add acc (tiles step lane)) 0
def source (p : Platform) (tiles : Fin steps → Fin 32 → Float32) : Float32 := p.reduce (laneValue tiles)
def output (p : Platform) (tiles : Fin steps → Fin 32 → Float32) : BF := BFloat16.narrow (source p tiles)

private theorem evaluate_lane (tiles : Fin steps → Fin 32 → Float32) (lane : Fin 32)
    (indices : List (Fin steps)) (acc : Arithmetic.Expr) :
    Arithmetic.evaluate (bind tiles) (indices.foldl (fun acc step => .add acc (.input (AffineLayout.chunkIndex step lane).val)) acc) =
      indices.foldl (fun acc step => FlushToZero.add acc (tiles step lane)) (Arithmetic.evaluate (bind tiles) acc) := by
  induction indices generalizing acc with
  | nil => rfl
  | cons step rest ih => simpa only [List.foldl_cons, Arithmetic.evaluate, bind_read] using ih (.add acc (.input (AffineLayout.chunkIndex step lane).val))

theorem execution (p : Platform) (tiles : Fin steps → Fin 32 → Float32) :
    Arithmetic.evaluate (bind tiles) (expression steps p.reduction.tree) = source p tiles := by
  rw [expression, evaluate_reduce, source, p.reduction.execution]
  congr 1
  funext lane
  exact evaluate_lane tiles lane (List.finRange steps) .zero

private theorem ideal_lane (tiles : Fin steps → Fin 32 → ℝ) (lane : Fin 32)
    (indices : List (Fin steps)) (acc : Arithmetic.Expr) :
    Arithmetic.ideal (bindReal tiles) (indices.foldl (fun acc step => .add acc (.input (AffineLayout.chunkIndex step lane).val)) acc) =
      Arithmetic.ideal (bindReal tiles) acc + (indices.map (fun step => tiles step lane)).sum := by
  induction indices generalizing acc with
  | nil => simp
  | cons step rest ih =>
    simp only [List.foldl_cons, ih, Arithmetic.ideal, bindReal_read, List.map_cons, List.sum_cons]
    ring

theorem ideal (tree : Reduction.Tree 32) (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (tiles : Fin steps → Fin 32 → ℝ) :
    Arithmetic.ideal (bindReal tiles) (expression steps tree) = ∑ lane, ∑ step, tiles step lane := by
  rw [expression, ideal_reduce]
  have hl (lane : Fin 32) : Arithmetic.ideal (bindReal tiles) (laneExpr steps lane) = ∑ step, tiles step lane := by
    rw [laneExpr, ideal_lane]
    simp [Arithmetic.ideal, ← Fin.sum_univ_def]
  simp_rw [hl]
  exact Reduction.ideal_complete _ tree coverage

noncomputable def budget (p : Platform) (tiles : Fin steps → Fin 32 → Float32) (target error : Fin steps → Fin 32 → ℝ) : ℝ :=
  Arithmetic.budget (bind tiles) (bindReal target) (bindReal error) (expression steps p.reduction.tree) +
    BFloat16.epsilon (real (source p tiles))

theorem output_error (p : Platform) (tiles : Fin steps → Fin 32 → Float32) (target error : Fin steps → Fin 32 → ℝ)
    (hi : ∀ step lane, |real (tiles step lane) - target step lane| ≤ error step lane)
    (hf : Arithmetic.Finite (bind tiles) (expression steps p.reduction.tree))
    (hb : Model.isFinite (output p tiles) = true) :
    |Model.toReal (output p tiles) - ∑ lane, ∑ step, target step lane| ≤ budget p tiles target error := by
  have he : ∀ i, |real (bind tiles i) - bindReal target i| ≤ bindReal error i := by
    intro i
    unfold bind bindReal
    split
    · exact hi _ _
    · have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
      simp only [hz, sub_zero, abs_zero, le_refl]
  have ha := Arithmetic.error _ _ _ he (expression steps p.reduction.tree) hf
  rw [execution, ideal _ p.reduction.coverage] at ha
  have hfinite := Arithmetic.finite_evaluate _ (expression steps p.reduction.tree) hf
  rw [execution] at hfinite
  have hc := BFloat16.narrow_error (source p tiles) hfinite hb
  unfold budget
  calc
    _ = |(Model.toReal (output p tiles) - real (source p tiles)) +
      (real (source p tiles) - ∑ lane, ∑ step, target step lane)| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hc ha)
      simpa only [output, add_comm] using h

def groupIndex (step : Fin steps) (lane : Fin 32) : Fin (steps * 8) :=
  ⟨step.val * 8 + lane.val / 4, AffineLayout.group_bound step lane⟩

structure Weights3 (steps : Nat) where
  bytes : Fin steps → Fin 32 → Fin 2 → Fin 3 → BitVec 8
  scale : Fin (steps * 8) → BF
  bias : Fin (steps * 8) → BF
structure Weights4 (steps : Nat) where
  words : Fin steps → Fin 32 → Fin 4 → BitVec 16
  scale : Fin (steps * 8) → BF
  bias : Fin (steps * 8) → BF

def slice (x : Fin (steps * 512) → α) (step : Fin steps) (lane : Fin 32) : Fin 16 → α :=
  fun i => x (AffineLayout.inputIndex step lane i)
def decode3 (w : Fin 2 → Fin 3 → BitVec 8) (i : Fin 16) : Nat :=
  AffinePacking.field3 (w ⟨i.val / 8, by have := i.isLt; omega⟩) ⟨i.val % 8, by omega⟩
def decode4 (w : Fin 4 → BitVec 16) (i : Fin 16) : Nat :=
  AffinePacking.field4 (w ⟨i.val / 4, by have := i.isLt; omega⟩) ⟨i.val % 4, by omega⟩

theorem decode3_index (w : Fin 2 → Fin 3 → BitVec 8) (chunk : Fin 2) (i : Fin 8) :
    decode3 w (AffineInput.index8 chunk i) = AffinePacking.field3 (w chunk) i := by
  simp [decode3, AffineInput.index8, Nat.add_div, Nat.div_eq_of_lt i.isLt, Nat.mod_eq_of_lt i.isLt, Nat.not_le.mpr i.isLt]
theorem decode4_index (w : Fin 4 → BitVec 16) (chunk : Fin 4) (i : Fin 4) :
    decode4 w (AffineInput.index4 chunk i) = AffinePacking.field4 (w chunk) i := by
  simp [decode4, AffineInput.index4, Nat.add_div, Nat.div_eq_of_lt i.isLt, Nat.mod_eq_of_lt i.isLt, Nat.not_le.mpr i.isLt]

noncomputable def localWeight3 (w : Weights3 steps) (step : Fin steps) (lane : Fin 32) (i : Fin 16) : ℝ :=
  Model.toReal (w.scale (groupIndex step lane)) * decode3 (w.bytes step lane) i + Model.toReal (w.bias (groupIndex step lane))
noncomputable def localWeight4 (w : Weights4 steps) (step : Fin steps) (lane : Fin 32) (i : Fin 16) : ℝ :=
  Model.toReal (w.scale (groupIndex step lane)) * decode4 (w.words step lane) i + Model.toReal (w.bias (groupIndex step lane))

noncomputable def weight3 (w : Weights3 steps) (i : Fin (steps * 512)) : ℝ :=
  let p := (AffineLayout.inputEquiv steps).symm i
  localWeight3 w p.1 p.2.1 p.2.2
noncomputable def weight4 (w : Weights4 steps) (i : Fin (steps * 512)) : ℝ :=
  let p := (AffineLayout.inputEquiv steps).symm i
  localWeight4 w p.1 p.2.1 p.2.2

theorem weight3_read (w : Weights3 steps) (step : Fin steps) (lane : Fin 32) (i : Fin 16) :
    weight3 w (AffineLayout.inputIndex step lane i) = localWeight3 w step lane i := by
  change (let p := (AffineLayout.inputEquiv steps).symm ((AffineLayout.inputEquiv steps) (step, lane, i));
    localWeight3 w p.1 p.2.1 p.2.2) = _
  rw [Equiv.symm_apply_apply]
theorem weight4_read (w : Weights4 steps) (step : Fin steps) (lane : Fin 32) (i : Fin 16) :
    weight4 w (AffineLayout.inputIndex step lane i) = localWeight4 w step lane i := by
  change (let p := (AffineLayout.inputEquiv steps).symm ((AffineLayout.inputEquiv steps) (step, lane, i));
    localWeight4 w p.1 p.2.1 p.2.2) = _
  rw [Equiv.symm_apply_apply]

def tiles3 (p : Platform) (x : Fin (steps * 512) → BF) (w : Weights3 steps) (step : Fin steps) (lane : Fin 32) : Float32 :=
  AffineTile.value3 p.tile (slice x step lane) (w.bytes step lane) (w.scale (groupIndex step lane)) (w.bias (groupIndex step lane))
def tiles4 (p : Platform) (x : Fin (steps * 512) → BF) (w : Weights4 steps) (step : Fin steps) (lane : Fin 32) : Float32 :=
  AffineTile.value4 p.tile (slice x step lane) (w.words step lane) (w.scale (groupIndex step lane)) (w.bias (groupIndex step lane))

noncomputable def targets3 (x : Fin (steps * 512) → ℝ) (w : Weights3 steps) (step : Fin steps) (lane : Fin 32) : ℝ :=
  AffineTile.target3 (slice x step lane) (w.bytes step lane) (w.scale (groupIndex step lane)) (w.bias (groupIndex step lane))
noncomputable def targets4 (x : Fin (steps * 512) → ℝ) (w : Weights4 steps) (step : Fin steps) (lane : Fin 32) : ℝ :=
  AffineTile.target4 (slice x step lane) (w.words step lane) (w.scale (groupIndex step lane)) (w.bias (groupIndex step lane))

theorem target_tile3 (x : Fin (steps * 512) → ℝ) (w : Weights3 steps) (step : Fin steps) (lane : Fin 32) :
    targets3 x w step lane = ∑ i, x (AffineLayout.inputIndex step lane i) * weight3 w (AffineLayout.inputIndex step lane i) := by
  rw [← AffineTile.input_coverage3]
  unfold targets3 AffineTile.target3
  apply Finset.sum_congr rfl
  intro c _
  apply Finset.sum_congr rfl
  intro i _
  rw [weight3_read, localWeight3, decode3_index]
  rfl
theorem target_tile4 (x : Fin (steps * 512) → ℝ) (w : Weights4 steps) (step : Fin steps) (lane : Fin 32) :
    targets4 x w step lane = ∑ i, x (AffineLayout.inputIndex step lane i) * weight4 w (AffineLayout.inputIndex step lane i) := by
  rw [← AffineTile.input_coverage4]
  unfold targets4 AffineTile.target4
  apply Finset.sum_congr rfl
  intro c _
  apply Finset.sum_congr rfl
  intro i _
  rw [weight4_read, localWeight4, decode4_index]
  rfl

theorem target_row3 (x : Fin (steps * 512) → ℝ) (w : Weights3 steps) :
    (∑ lane, ∑ step, targets3 x w step lane) = ∑ i, x i * weight3 w i := by
  simp_rw [target_tile3]
  exact AffineLayout.lane_coverage (fun i => x i * weight3 w i)
theorem target_row4 (x : Fin (steps * 512) → ℝ) (w : Weights4 steps) :
    (∑ lane, ∑ step, targets4 x w step lane) = ∑ i, x i * weight4 w i := by
  simp_rw [target_tile4]
  exact AffineLayout.lane_coverage (fun i => x i * weight4 w i)

noncomputable def tileBudgets3 (p : Platform) (x : Fin (steps * 512) → BF) (w : Weights3 steps)
    (target error : Fin (steps * 512) → ℝ) (step : Fin steps) (lane : Fin 32) : ℝ :=
  AffineTile.budget3 p.tile (slice x step lane) (w.bytes step lane) (w.scale (groupIndex step lane)) (w.bias (groupIndex step lane))
    (slice target step lane) (slice error step lane)
noncomputable def tileBudgets4 (p : Platform) (x : Fin (steps * 512) → BF) (w : Weights4 steps)
    (target error : Fin (steps * 512) → ℝ) (step : Fin steps) (lane : Fin 32) : ℝ :=
  AffineTile.budget4 p.tile (slice x step lane) (w.words step lane) (w.scale (groupIndex step lane)) (w.bias (groupIndex step lane))
    (slice target step lane) (slice error step lane)

theorem row3_error (p : Platform) (x : Fin (steps * 512) → BF) (w : Weights3 steps) (target error : Fin (steps * 512) → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i)
    (ht : ∀ step lane, AffineTile.Finite3 p.tile (slice x step lane) (w.bytes step lane)
      (w.scale (groupIndex step lane)) (w.bias (groupIndex step lane)))
    (hf : Arithmetic.Finite (bind (tiles3 p x w)) (expression steps p.reduction.tree))
    (hb : Model.isFinite (output p (tiles3 p x w)) = true) :
    |Model.toReal (output p (tiles3 p x w)) - ∑ i, target i * weight3 w i| ≤
      budget p (tiles3 p x w) (targets3 target w) (tileBudgets3 p x w target error) := by
  rw [← target_row3]
  apply output_error p _ _ _ _ hf hb
  intro step lane
  exact AffineTile.value3_error p.tile _ _ _ _ _ _ (fun i => hi (AffineLayout.inputIndex step lane i)) (ht step lane)

theorem row4_error (p : Platform) (x : Fin (steps * 512) → BF) (w : Weights4 steps) (target error : Fin (steps * 512) → ℝ)
    (hi : ∀ i, |Model.toReal (x i) - target i| ≤ error i)
    (ht : ∀ step lane, AffineTile.Finite4 p.tile (slice x step lane) (w.words step lane)
      (w.scale (groupIndex step lane)) (w.bias (groupIndex step lane)))
    (hf : Arithmetic.Finite (bind (tiles4 p x w)) (expression steps p.reduction.tree))
    (hb : Model.isFinite (output p (tiles4 p x w)) = true) :
    |Model.toReal (output p (tiles4 p x w)) - ∑ i, target i * weight4 w i| ≤
      budget p (tiles4 p x w) (targets4 target w) (tileBudgets4 p x w target error) := by
  rw [← target_row4]
  apply output_error p _ _ _ _ hf hb
  intro step lane
  exact AffineTile.value4_error p.tile _ _ _ _ _ _ (fun i => hi (AffineLayout.inputIndex step lane i)) (ht step lane)

end Inference.Kernels.Quantization.AffineRow
