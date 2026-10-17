import contracts.mlx.FlushedDotProduct
import contracts.mlx.FlushedReduction
import kernels.trellis.GateUpAccuracy
import kernels.trellis.CodebookFlushToZero

namespace Inference.Kernels.Trellis.GateUpFlushToZero
open Contracts.Mlx Contracts.Mlx.Numerics GateUpExecution DownCodebook
open scoped BigOperators
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def accumulate (j : Nat) (weight input : Float32) (acc : Accumulators) : Accumulators :=
  if j%2=1 then (acc.1, FlushToZero.fma weight input acc.2)
  else (FlushToZero.fma weight input acc.1, acc.2)

def referenceStep (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row r j : Nat) (acc : Accumulators) : Accumulators :=
  accumulate j (FlushToZero.mul (DownExecution.coefficient words k row (r*32+j)) (scale row))
    (widen (input (r*32+j))) acc

def sourceStep (load : M1Max.ThreadgroupLoad) (memory : M1Max.WordMemory) (base : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row r j : Nat) (acc : Accumulators) : Accumulators :=
  accumulate j (FlushToZero.mul
    (CodebookLoad.read load memory base (GateUpCodebook.runWords (words row (r/8)) r k) ((31-j)*k)) (scale row))
    (stagedRead input r (j/8) (j%8)) acc

theorem sourceStep_correct (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (memory : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row r j : Nat)
    (hr : r<160) (hj : j<32) (acc : Accumulators) :
    sourceStep load memory base words k scale input row r j acc = referenceStep words k scale input row r j acc := by
  unfold sourceStep referenceStep
  rw [GateUpCodebook.load_correct load loads memory base ha hn initialized _ r k j hk hj]
  rw [stagedRead_correct input r (j/8) (j%8) hr (by omega) (by omega)]
  have hb : (r*32+j)/256=r/8 := by omega
  have ht : (r*32+j)%256=r%8*32+j := by omega
  have hj' : r*32+j/8*8+j%8=r*32+j := by omega
  rw [hj']
  unfold DownExecution.coefficient
  rw [hb, ht]

def evaluatePair (code scale input : Nat → Float32) (p : GateUpAccuracy.Pair) : Accumulators :=
  (FlushedDotProduct.evaluate code scale input p.1, FlushedDotProduct.evaluate code scale input p.2)

theorem evaluate_step (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row r j : Nat) (acc : GateUpAccuracy.Pair) :
    evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (GateUpAccuracy.step r j acc) =
      referenceStep words k scale input row r j
        (evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
          (fun col => widen (input col)) acc) := by
  unfold GateUpAccuracy.step referenceStep GateUpFlushToZero.accumulate
  split <;> rfl

def referenceRun (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row r : Nat) (acc : Accumulators) : Accumulators :=
  scalarRows (referenceStep words k scale input row r) 0 32 acc

def referenceLane (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) : Float32 :=
  let acc := scalarRows (fun i => referenceRun words k scale input row (lane+32*i)) 0 5 (0, 0)
  FlushToZero.add acc.1 acc.2

theorem evaluate_run (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row r : Nat) (acc : GateUpAccuracy.Pair) :
    evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (GateUpAccuracy.run r acc) =
      referenceRun words k scale input row r
        (evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
          (fun col => widen (input col)) acc) := by
  exact GateUpAccuracy.scalarRows_map _ _ _ (evaluate_step words k scale input row r) 0 32 acc

theorem evaluate_lane (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) :
    FlushedDotProduct.evaluate (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (GateUpAccuracy.laneExpr lane) = referenceLane words k scale input row lane := by
  let eval := evaluatePair (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
    (fun col => widen (input col))
  have h := GateUpAccuracy.scalarRows_map eval _ _
    (fun i acc => evaluate_run words k scale input row (lane+32*i) acc) 0 5 (.zero, .zero)
  calc
    _ = FlushToZero.add (eval (GateUpAccuracy.lanePair lane)).1 (eval (GateUpAccuracy.lanePair lane)).2 := rfl
    _ = FlushToZero.add
        (scalarRows (fun i => referenceRun words k scale input row (lane+32*i)) 0 5 (0, 0)).1
        (scalarRows (fun i => referenceRun words k scale input row (lane+32*i)) 0 5 (0, 0)).2 :=
      congrArg (fun acc : Accumulators => FlushToZero.add acc.1 acc.2) h
    _ = _ := rfl

def sourceRun (load : M1Max.ThreadgroupLoad) (memory : M1Max.WordMemory) (base : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row r : Nat) (acc : Accumulators) : Accumulators :=
  tiledRows (sourceStep load memory base words k scale input row r) 0 4 8 acc

def sourceLane (load : M1Max.ThreadgroupLoad) (memory : M1Max.WordMemory) (base : Nat)
    (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row lane : Nat) : Float32 :=
  let acc := scalarRows (fun i => sourceRun load memory base words k scale input row (lane+32*i)) 0 5 (0, 0)
  FlushToZero.add acc.1 acc.2

theorem sourceRun_correct (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (memory : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row r : Nat) (hr : r<160) (acc : Accumulators) :
    sourceRun load memory base words k scale input row r acc = referenceRun words k scale input row r acc := by
  unfold sourceRun referenceRun
  rw [tiledRows_correct]
  apply DownExecution.scalarRows_congr
  intro j _ hj a
  exact sourceStep_correct load loads memory base ha hn initialized words k hk scale input row r j hr hj a

theorem sourceLane_correct (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (memory : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row lane : Nat) (hl : lane<32) :
    sourceLane load memory base words k scale input row lane = referenceLane words k scale input row lane := by
  have h := DownExecution.scalarRows_congr
    (fun i => sourceRun load memory base words k scale input row (lane+32*i))
    (fun i => referenceRun words k scale input row (lane+32*i)) 0 5 (0, 0)
    (fun i _ hi acc => sourceRun_correct load loads memory base ha hn initialized words k hk scale input
      row (lane+32*i) (by omega) acc)
  exact congrArg (fun acc : Accumulators => FlushToZero.add acc.1 acc.2) h

def projectionExpr : Reduction.Tree 32 → DotProduct.Expr
  | .leaf lane => GateUpAccuracy.laneExpr lane.val
  | .add a b => .add (projectionExpr a) (projectionExpr b)

abbrev SimdContract := FlushedReduction.SimdContract

theorem evaluate_projection (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row : Nat) (tree : Reduction.Tree 32) :
    FlushedDotProduct.evaluate (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (projectionExpr tree) =
      FlushedReduction.evaluate (fun lane => referenceLane words k scale input row lane.val) tree := by
  induction tree with
  | leaf lane => exact evaluate_lane words k scale input row lane.val
  | add a b ia ib => simp only [projectionExpr, FlushedDotProduct.evaluate, FlushedReduction.evaluate, ia, ib]

theorem projection_ideal (term : Nat → ℝ) (tree : Reduction.Tree 32) :
    DotProduct.ideal term (projectionExpr tree) =
      Reduction.ideal (fun lane => DotProduct.ideal term (GateUpAccuracy.laneExpr lane.val)) tree := by
  induction tree with
  | leaf => rfl
  | add a b ia ib => simp only [projectionExpr, DotProduct.ideal, Reduction.ideal, ia, ib]

theorem projection_error (words : DownExecution.PackedMatrix) (k : Nat) (scale : Nat → Float32)
    (input : Nat → BitVec 16) (row : Nat) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (hf : FlushedDotProduct.Finite (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (projectionExpr tree)) :
    |real (FlushedDotProduct.evaluate (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
        (fun col => widen (input col)) (projectionExpr tree)) -
      ∑ c : Fin 5120, GateUpAccuracy.term words k scale input row c.val| ≤
        FlushedDotProduct.budget (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
          (fun col => widen (input col)) (fun col => |GateUpAccuracy.targetCoefficient words k row col| / 2^23)
          (projectionExpr tree) := by
  have h := FlushedDotProduct.error (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
    (fun col => widen (input col)) (GateUpAccuracy.targetCoefficient words k row)
    (fun col => |GateUpAccuracy.targetCoefficient words k row col| / 2^23)
    (GateUpAccuracy.coefficient_error words k row) (projectionExpr tree) hf
  rw [projection_ideal, Reduction.ideal_complete _ tree coverage] at h
  rw [GateUpAccuracy.ideal_projection] at h
  exact h

theorem source_error (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (memory : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (reduce : DownExecution.SimdReduction) (hardware : SimdContract reduce)
    (words : DownExecution.PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale : Nat → Float32) (input : Nat → BitVec 16) (row : Nat)
    (hf : FlushedDotProduct.Finite (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
      (fun col => widen (input col)) (projectionExpr hardware.tree)) :
    |real (reduce (fun lane => sourceLane load memory base words k scale input row lane.val)) -
      ∑ c : Fin 5120, GateUpAccuracy.term words k scale input row c.val| ≤
        FlushedDotProduct.budget (fun col => DownExecution.coefficient words k row col) (fun _ => scale row)
          (fun col => widen (input col)) (fun col => |GateUpAccuracy.targetCoefficient words k row col| / 2^23)
          (projectionExpr hardware.tree) := by
  have lanes : (fun lane : Fin 32 => sourceLane load memory base words k scale input row lane.val) =
      (fun lane => referenceLane words k scale input row lane.val) := by
    funext lane
    exact sourceLane_correct load loads memory base ha hn initialized words k hk scale input row lane.val lane.isLt
  rw [lanes, hardware.execution, ← evaluate_projection]
  exact projection_error words k scale input row hardware.tree hardware.coverage hf

end Inference.Kernels.Trellis.GateUpFlushToZero
