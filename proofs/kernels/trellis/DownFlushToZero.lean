import kernels.trellis.DownReduction
import kernels.trellis.GateUpFlushToZero

namespace Inference.Kernels.Trellis.DownFlushToZero
open Contracts.Mlx Contracts.Mlx.Numerics DownCodebook
open DownExecution (PackedMatrix coefficient laneColumn scratchMemory scalarRows_congr)
open scoped BigOperators
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

-- The same source loop and scratch schedule as DownExecution, with flushing
-- at arithmetic boundaries. Packed loads and bf16 conversion remain exact
-- bit operations and nearest-even conversion, respectively.
def splitExpr (split : Nat) : DotProduct.Expr :=
  scalarRows (fun row acc => .fma row acc) (split*136) 136 .zero

def splitSum (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (split col : Nat) : Float32 :=
  scalarRows (fun row acc => FlushToZero.fma
    (FlushToZero.mul (coefficient words k row col) (scale row)) (input row) acc) (split*136) 136 0

theorem evaluate_split (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (split col : Nat) :
    FlushedDotProduct.evaluate (fun row => coefficient words k row col) scale input (splitExpr split) =
      splitSum words k scale input split col := by
  exact GateUpAccuracy.scalarRows_map
    (FlushedDotProduct.evaluate (fun row => coefficient words k row col) scale input)
    (fun row acc => DotProduct.Expr.fma row acc)
    (fun row acc => FlushToZero.fma
      (FlushToZero.mul (coefficient words k row col) (scale row)) (input row) acc)
    (fun _ _ => rfl) (split*136) 136 .zero

def laneSum (load : M1Max.ThreadgroupLoad) (memory : M1Max.WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty sg lane i : Nat) : Float32 :=
  let block := (2*(ty/32)+sg/4)*2+lane/16
  pairedRows (fun row acc => FlushToZero.fma
    (FlushToZero.mul (CodebookLoad.read load memory base
      (Lane.alignedWord (words row block) k (lane%16)) (i*k)) (scale row))
    (input row) acc) ((ty%32+32*(sg%4))*136) 68 0

theorem lane_correct (load : M1Max.ThreadgroupLoad) (hardware : M1Max.LoadContract load)
    (memory : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty sg lane i : Nat) (hl : lane<32) (hi : i<16) :
    laneSum load memory base words k scale input ty sg lane i =
      splitSum words k scale input (ty%32+32*(sg%4)) (laneColumn ty sg lane i) := by
  unfold laneSum splitSum
  rw [pairedRows_correct]
  have hc := DownExecution.lane_column ty sg lane i hl hi
  apply scalarRows_congr
  intro row _ _ acc
  rw [load_correct load hardware memory base ha hn initialized _ k (lane%16) i hk (by omega) hi]
  unfold coefficient
  rw [hc.1, hc.2]

theorem scratch_read (load : M1Max.ThreadgroupLoad) (hardware : M1Max.LoadContract load)
    (memory : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty j : Nat) :
    scratchMemory (laneSum load memory base words k scale input ty) j =
      splitSum words k scale input (ty%32+32*(j/512%4))
        ((2*(ty/32)+j/512/4)*512+j%512) := by
  unfold scratchMemory
  rw [lane_correct load hardware memory base ha hn initialized words k hk scale input
    ty _ _ _ (by omega) (by omega)]
  congr 1
  unfold laneColumn
  omega

def partialExpr (y : Nat) : DotProduct.Expr :=
  scalarRows (fun s acc => .add (splitExpr (y+32*s)) acc) 0 4 .zero

def partialSum (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (y col : Nat) : Float32 :=
  scalarRows (fun s acc => FlushToZero.add (splitSum words k scale input (y+32*s) col) acc) 0 4 0

theorem evaluate_partial (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (y col : Nat) :
    FlushedDotProduct.evaluate (fun row => coefficient words k row col) scale input (partialExpr y) =
      partialSum words k scale input y col := by
  apply GateUpAccuracy.scalarRows_map
  intro s acc
  change FlushToZero.add
    (FlushedDotProduct.evaluate (fun row => coefficient words k row col) scale input (splitExpr (y+32*s))) _ = _
  rw [evaluate_split]

def firstStage (scratch : Nat → Float32) (c : Nat) : Float32 :=
  scalarRows (fun s acc => FlushToZero.add (scratch ((c/512*4+s)*512+c%512)) acc) 0 4 0

theorem first_correct (load : M1Max.ThreadgroupLoad) (hardware : M1Max.LoadContract load)
    (memory : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (initialized : CodebookLoad.Initialized memory base)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty c : Nat) (_hc : c<1024) :
    firstStage (scratchMemory (laneSum load memory base words k scale input ty)) c =
      partialSum words k scale input (ty%32) (column ty c) := by
  unfold firstStage partialSum
  apply scalarRows_congr
  intro s _ hs acc
  rw [scratch_read load hardware memory base ha hn initialized words k hk scale input ty]
  have hsplit : ((c/512*4+s)*512+c%512)/512%4 = s := by omega
  have hcol : (2*(ty/32)+((c/512*4+s)*512+c%512)/512/4)*512+
      ((c/512*4+s)*512+c%512)%512 = column ty c := by unfold column; omega
  rw [hsplit, hcol]

def threadgroup (load : M1Max.ThreadgroupLoad) (before : M1Max.WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32) (ty c : Nat) : Float32 :=
  let table := Memory.execute (CodebookInitialization.stores base 256) before
  let values := laneSum load table base words k scale input ty
  let scratch := Memory.execute (DownMemory.stores base values) table
  firstStage (fun j => scratch (base/4+j)) c

-- The scratch proof is polymorphic in stored values, so it applies unchanged
-- to flushed arithmetic. The codebook entries are also unchanged, as proved
-- by CodebookFlushToZero.initialization_correct.
theorem threadgroup_correct (load : M1Max.ThreadgroupLoad) (hardware : M1Max.LoadContract load)
    (before : M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (ty c : Nat) (hc : c<1024) :
    threadgroup load before base words k scale input ty c =
      partialSum words k scale input (ty%32) (column ty c) := by
  let table := Memory.execute (CodebookInitialization.stores base 256) before
  let values := laneSum load table base words k scale input ty
  have initialized := CodebookInitialization.initialized before base 256 (Or.inl rfl)
    (CodebookInitialization.stores base 256) (List.Perm.refl _)
  have h : firstStage (fun j => Memory.execute (DownMemory.stores base values) table (base/4+j)) c =
      firstStage (scratchMemory values) c := by
    unfold firstStage
    apply scalarRows_congr
    intro s _ hs acc
    dsimp only
    rw [DownMemory.scratch_written table base values (DownMemory.stores base values)
      (List.Perm.refl _) _ (by omega)]
  exact h.trans (first_correct load hardware table base ha hn initialized words k hk scale input ty c hc)

def projectionExpr : Reduction.Tree 32 → DotProduct.Expr
  | .leaf y => partialExpr y.val
  | .add a b => .add (projectionExpr a) (projectionExpr b)

theorem evaluate_projection (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (col : Nat) (tree : Reduction.Tree 32) :
    FlushedDotProduct.evaluate (fun row => coefficient words k row col) scale input (projectionExpr tree) =
      FlushedReduction.evaluate (fun y => partialSum words k scale input y.val col) tree := by
  induction tree with
  | leaf y => exact evaluate_partial words k scale input y.val col
  | add a b ia ib =>
    simp only [projectionExpr, FlushedDotProduct.evaluate, FlushedReduction.evaluate, ia, ib]

theorem ideal_split (term : Nat → ℝ) (split : Nat) :
    DotProduct.ideal term (splitExpr split) = ∑ r : Fin 136, term (split*136+r.val) := by
  simpa only [splitExpr, DotProduct.ideal, add_zero] using
    GateUpAccuracy.scalarRows_sum (DotProduct.ideal term) (fun row acc => .fma row acc) term
      (fun _ _ => rfl) (split*136) 136 .zero

theorem ideal_partial (term : Nat → ℝ) (y : Nat) :
    DotProduct.ideal term (partialExpr y) = ∑ s : Fin 4, ∑ r : Fin 136, term ((y+32*s.val)*136+r.val) := by
  have h := GateUpAccuracy.scalarRows_sum (DotProduct.ideal term)
    (fun s acc => .add (splitExpr (y+32*s)) acc)
    (fun s => ∑ r : Fin 136, term ((y+32*s)*136+r.val))
    (fun s acc => by simp only [DotProduct.ideal, ideal_split]) 0 4 .zero
  simpa only [partialExpr, DotProduct.ideal, Nat.zero_add, add_zero] using h

theorem projection_ideal (term : Nat → ℝ) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) :
    DotProduct.ideal term (projectionExpr tree) = ∑ r : Fin 17408, term r.val := by
  have h : DotProduct.ideal term (projectionExpr tree) =
      Reduction.ideal (fun y => DotProduct.ideal term (partialExpr y.val)) tree := by
    clear coverage
    induction tree with
    | leaf => rfl
    | add a b ia ib => simp only [projectionExpr, DotProduct.ideal, Reduction.ideal, ia, ib]
  rw [h, Reduction.ideal_complete _ tree coverage, ← Fin.sum_univ_def]
  simp only [ideal_partial]
  have rows := DownReduction.rows_once (fun r => term r.val)
  simpa only [DownReduction.RowIndex, Fintype.sum_prod_type, DownReduction.rowEquiv, Equiv.coe_fn_mk] using rows

def output (load : M1Max.ThreadgroupLoad) (before : Nat → M1Max.WordMemory) (base : Nat)
    (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (reduce : DownExecution.SimdReduction) (convert : Float32 → Float32) (col : Nat) : Float32 :=
  convert (reduce (fun y => threadgroup load (before (32*(col/1024)+y.val)) base words k scale input
    (32*(col/1024)+y.val) (col%1024)))

theorem output_correct (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (before : Nat → M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (reduce : DownExecution.SimdReduction) (convert : Float32 → Float32)
    (col : Nat) (hc : col<5120) :
    output load before base words k scale input reduce convert col =
      convert (reduce (fun y => partialSum words k scale input y.val col)) := by
  unfold output
  apply congrArg convert
  apply congrArg reduce
  funext y
  rw [threadgroup_correct load loads _ base ha hn words k hk scale input _ _ (by omega)]
  obtain ⟨_, _, hy, hc⟩ := partial_coverage y.val col y.isLt hc
  rw [hy, hc]

def Finite (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (col : Nat) (tree : Reduction.Tree 32) : Prop :=
  FlushedDotProduct.Finite (fun row => coefficient words k row col) scale input (projectionExpr tree)

noncomputable def budget (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (col : Nat) (tree : Reduction.Tree 32) : ℝ :=
  FlushedDotProduct.budget (fun row => coefficient words k row col) scale input
    (fun row => |DownAccuracy.idealCoefficient words k row col| / 2^23) (projectionExpr tree)

theorem projection_error (words : PackedMatrix) (k : Nat) (scale input : Nat → Float32)
    (col : Nat) (reduce : DownExecution.SimdReduction) (hardware : GateUpFlushToZero.SimdContract reduce)
    (hf : Finite words k scale input col hardware.tree) :
    |real (reduce (fun y => partialSum words k scale input y.val col)) -
      DownReduction.dotProduct words k scale input col| ≤ budget words k scale input col hardware.tree := by
  have h := FlushedDotProduct.error (fun row => coefficient words k row col) scale input
    (fun row => DownAccuracy.idealCoefficient words k row col)
    (fun row => |DownAccuracy.idealCoefficient words k row col| / 2^23)
    (fun row => CodebookAccuracy.relative_error _) (projectionExpr hardware.tree) hf
  rw [projection_ideal _ hardware.tree hardware.coverage, evaluate_projection, ← hardware.execution] at h
  exact h

theorem output_bfloat_error (load : M1Max.ThreadgroupLoad) (loads : M1Max.LoadContract load)
    (before : Nat → M1Max.WordMemory) (base : Nat) (ha : base%4=0) (hn : base+16384 ≤ 2^64)
    (words : PackedMatrix) (k : Nat) (hk : k=2 ∨ k=3 ∨ k=4)
    (scale input : Nat → Float32) (col : Nat) (hc : col<5120)
    (reduce : DownExecution.SimdReduction) (hardware : GateUpFlushToZero.SimdContract reduce)
    (convert : Float32 → Float32) (conversion : BFloat16.RneContract convert)
    (hf : Finite words k scale input col hardware.tree)
    (hb : FloatLib.Floats.Formats.BinaryInterchange.Model.isFinite
      (BFloat16.narrow (reduce (fun y => partialSum words k scale input y.val col)))=true) :
    |real (output load before base words k scale input reduce convert col) -
      DownReduction.dotProduct words k scale input col| ≤ budget words k scale input col hardware.tree +
        BFloat16.epsilon (real (reduce (fun y => partialSum words k scale input y.val col))) := by
  have hp := projection_error words k scale input col reduce hardware hf
  have hfinite : (reduce (fun y => partialSum words k scale input y.val col)).isFinite=true := by
    rw [hardware.execution, ← evaluate_projection]
    exact FlushedDotProduct.finite_evaluate _ _ _ _ hf
  have hcvt := BFloat16.rne_error convert conversion _ hfinite hb
  rw [output_correct load loads before base ha hn words k hk scale input reduce convert col hc]
  calc
    _ = |(real (convert (reduce (fun y => partialSum words k scale input y.val col))) -
          real (reduce (fun y => partialSum words k scale input y.val col))) +
        (real (reduce (fun y => partialSum words k scale input y.val col)) - DownReduction.dotProduct words k scale input col)| := by
      congr 1
      ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hcvt hp)
      linarith

end Inference.Kernels.Trellis.DownFlushToZero
