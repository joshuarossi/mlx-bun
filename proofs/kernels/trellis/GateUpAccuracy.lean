import contracts.mlx.DotProduct
import kernels.trellis.GateUpExecution
import kernels.trellis.CodebookAccuracy
import Mathlib.Algebra.BigOperators.Fin

namespace Inference.Kernels.Trellis.GateUpAccuracy
open Contracts.Mlx.Numerics GateUpExecution DownCodebook
open scoped BigOperators
open Contracts.Mlx

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

abbrev Pair := DotProduct.Expr × DotProduct.Expr

def step (run j : Nat) (acc : Pair) : Pair :=
  if j%2=1 then (acc.1, .fma (run*32+j) acc.2)
  else (.fma (run*32+j) acc.1, acc.2)

def run (r : Nat) (acc : Pair) : Pair := scalarRows (step r) 0 32 acc

def lanePair (lane : Nat) : Pair :=
  scalarRows (fun i => run (lane+32*i)) 0 5 (.zero, .zero)

def laneExpr (lane : Nat) : DotProduct.Expr := .add (lanePair lane).1 (lanePair lane).2

def evaluatePair (code scale input : Nat → Float32) (p : Pair) : Accumulators :=
  (DotProduct.evaluate code scale input p.1, DotProduct.evaluate code scale input p.2)

theorem scalarRows_map {α β : Type} (map : α → β) (left : Nat → α → α) (right : Nat → β → β)
    (h : ∀ i a, map (left i a) = right i (map a)) (start count : Nat) (acc : α) :
    map (scalarRows left start count acc) = scalarRows right start count (map acc) := by
  induction count generalizing start acc with
  | zero => rfl
  | succ count ih =>
    change map (scalarRows left (start+1) count (left start acc)) =
      scalarRows right (start+1) count (right start (map acc))
    rw [ih, h]

theorem evaluate_step (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row r j : Nat) (acc : Pair) :
    evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (step r j acc) =
      referenceStep words k scale input row r j
        (evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
          (fun col => widen (input col)) acc) := by
  unfold step referenceStep GateUpExecution.accumulate
  split <;> rfl

theorem evaluate_run (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row r : Nat) (acc : Pair) :
    evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (run r acc) =
      referenceRun words k scale input row r
        (evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
          (fun col => widen (input col)) acc) := by
  exact scalarRows_map _ _ _ (evaluate_step words k scale input row r) 0 32 acc

theorem evaluate_lane (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) :
    DotProduct.evaluate (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (laneExpr lane) = referenceLane words k scale input row lane := by
  have h := scalarRows_map
    (evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col))) _ _
    (fun i acc => evaluate_run words k scale input row (lane+32*i) acc) 0 5 (.zero, .zero)
  let eval := evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
    (fun col => widen (input col))
  calc
    _ = (eval (lanePair lane)).1 + (eval (lanePair lane)).2 := rfl
    _ = (scalarRows (fun i => referenceRun words k scale input row (lane+32*i)) 0 5 (0, 0)).1 +
        (scalarRows (fun i => referenceRun words k scale input row (lane+32*i)) 0 5 (0, 0)).2 :=
      congrArg (fun acc : Accumulators => acc.1+acc.2) h
    _ = _ := rfl

noncomputable def idealPair (term : Nat → ℝ) (acc : Pair) : ℝ :=
  DotProduct.ideal term acc.1 + DotProduct.ideal term acc.2

theorem ideal_step (term : Nat → ℝ) (r j : Nat) (acc : Pair) :
    idealPair term (step r j acc) = term (r*32+j) + idealPair term acc := by
  unfold step
  split <;> simp [idealPair, DotProduct.ideal] <;> ring

theorem scalarRows_sum {α : Type} (value : α → ℝ) (step : Nat → α → α) (term : Nat → ℝ)
    (h : ∀ i a, value (step i a)=term i+value a) (start count : Nat) (acc : α) :
    value (scalarRows step start count acc) = (∑ i : Fin count, term (start+i.val)) + value acc := by
  induction count generalizing start acc with
  | zero => simp [scalarRows]
  | succ count ih =>
    change value (scalarRows step (start+1) count (step start acc)) = _
    rw [ih, h, Fin.sum_univ_succ]
    simp only [Fin.val_zero, Nat.add_zero, Fin.val_succ]
    have he : (∑ i : Fin count, term (start+1+i.val)) = ∑ i : Fin count, term (start+(i.val+1)) := by
      apply Finset.sum_congr rfl
      intro i _
      congr 1
      omega
    rw [he]
    ring

theorem ideal_run (term : Nat → ℝ) (r : Nat) (acc : Pair) :
    idealPair term (run r acc) = (∑ j : Fin 32, term (r*32+j.val)) + idealPair term acc := by
  simpa only [run, Nat.zero_add] using scalarRows_sum (idealPair term) (step r)
    (fun j => term (r*32+j)) (ideal_step term r) 0 32 acc

theorem ideal_lane (term : Nat → ℝ) (lane : Nat) :
    DotProduct.ideal term (laneExpr lane) = ∑ i : Fin 5, ∑ j : Fin 32, term ((lane+32*i.val)*32+j.val) := by
  have h := scalarRows_sum (idealPair term) (fun i => run (lane+32*i))
    (fun i => ∑ j : Fin 32, term ((lane+32*i)*32+j.val))
    (fun i acc => ideal_run term (lane+32*i) acc) 0 5 (.zero, .zero)
  simpa only [laneExpr, lanePair, Nat.zero_add, idealPair, DotProduct.ideal, zero_add, add_zero] using h

abbrev ColumnIndex := Fin 32 × Fin 5 × Fin 32

def columnEquiv : ColumnIndex ≃ Fin 5120 where
  toFun p := ⟨(p.1.val+32*p.2.1.val)*32+p.2.2.val, by
    have := p.1.isLt; have := p.2.1.isLt; have := p.2.2.isLt; omega⟩
  invFun c := (⟨c.val/32%32, by omega⟩, ⟨c.val/1024, by have := c.isLt; omega⟩,
    ⟨c.val%32, by omega⟩)
  left_inv p := by
    rcases p with ⟨⟨lane, hl⟩, ⟨i, hi⟩, ⟨j, hj⟩⟩
    apply Prod.ext
    · apply Fin.ext; dsimp only; omega
    · apply Prod.ext <;> apply Fin.ext <;> dsimp only <;> omega
  right_inv c := by
    apply Fin.ext
    dsimp only
    have := c.isLt
    omega

theorem ideal_projection (term : Nat → ℝ) :
    ((List.finRange 32).map (fun lane => DotProduct.ideal term (laneExpr lane.val))).sum =
      ∑ c : Fin 5120, term c.val := by
  rw [← Fin.sum_univ_def]
  simp only [ideal_lane]
  have h := Equiv.sum_comp columnEquiv (fun c => term c.val)
  simpa only [ColumnIndex, Fintype.sum_prod_type, columnEquiv, Equiv.coe_fn_mk] using h

noncomputable def targetCoefficient (words : DownExecution.PackedMatrix) (k row col : Nat) : ℝ :=
  CodebookAccuracy.ideal (Codebook.PackedState.read (words row (col/256)) k (col%256))

theorem coefficient_error (words : DownExecution.PackedMatrix) (k row col : Nat) :
    |real (DownExecution.coefficient words k row col)-targetCoefficient words k row col| ≤
      |targetCoefficient words k row col| / 2^23 :=
  CodebookAccuracy.relative_error _

def LaneFinite (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) : Prop :=
  DotProduct.Finite (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
    (fun col => widen (input col)) (laneExpr lane)

noncomputable def laneBudget (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) : ℝ :=
  DotProduct.budget (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
    (fun col => widen (input col)) (fun col => |targetCoefficient words k row col| / 2^23) (laneExpr lane)

noncomputable def term (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row col : Nat) : ℝ :=
  targetCoefficient words k row col * real (scale row) * real (widen (input col))

theorem lane_error (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) (hf : LaneFinite words k scale input row lane) :
    |real (referenceLane words k scale input row lane) -
      DotProduct.ideal (term words k scale input row) (laneExpr lane)| ≤
        laneBudget words k scale input row lane := by
  have h := DotProduct.error (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
    (fun col => widen (input col)) (targetCoefficient words k row)
    (fun col => |targetCoefficient words k row col| / 2^23) (coefficient_error words k row) (laneExpr lane) hf
  rw [evaluate_lane] at h
  exact h

noncomputable def projectionBudget (reduce : DownExecution.SimdReduction) (hardware : Reduction.SimdContract reduce)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row : Nat) : ℝ :=
  Reduction.budget (fun lane => referenceLane words k scale input row lane.val)
    (fun lane => laneBudget words k scale input row lane.val) hardware.tree

theorem reference_error (reduce : DownExecution.SimdReduction) (hardware : Reduction.SimdContract reduce)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row : Nat)
    (hf : ∀ lane : Fin 32, LaneFinite words k scale input row lane.val)
    (ht : Reduction.Finite (fun lane => referenceLane words k scale input row lane.val) hardware.tree) :
    |real (reduce (fun lane => referenceLane words k scale input row lane.val)) -
      ∑ c : Fin 5120, term words k scale input row c.val| ≤ projectionBudget reduce hardware words k scale input row := by
  have h := Reduction.simd_error reduce hardware (fun lane => referenceLane words k scale input row lane.val)
    (fun lane => DotProduct.ideal (term words k scale input row) (laneExpr lane.val))
    (fun lane => laneBudget words k scale input row lane.val)
    (fun lane => lane_error words k scale input row lane.val (hf lane)) ht
  rw [ideal_projection] at h
  exact h

theorem projection_error (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (memory : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (reduce : DownExecution.SimdReduction) (hardware : Reduction.SimdContract reduce)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row : Nat)
    (hf : ∀ lane : Fin 32, LaneFinite words k scale input row lane.val)
    (ht : Reduction.Finite (fun lane => referenceLane words k scale input row lane.val) hardware.tree) :
    |real (reduce (fun lane => sourceLane load memory base words k scale input row lane.val)) -
      ∑ c : Fin 5120, term words k scale input row c.val| ≤ projectionBudget reduce hardware words k scale input row := by
  rw [projection_correct load loads memory base ha hn initialized words k hk scale input row reduce]
  exact reference_error reduce hardware words k scale input row hf ht

end Inference.Kernels.Trellis.GateUpAccuracy
