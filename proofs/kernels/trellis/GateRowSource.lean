import kernels.trellis.GateRowSyntax
import kernels.trellis.GateTailSource
import kernels.trellis.GateUpOutput
namespace Inference.Kernels.Trellis.GateRowSource
open Contracts.Mlx Contracts.Mlx.M1Max GateRowSyntax
set_option maxRecDepth 10000

-- Builtin values are explicit launch inputs, bound to the selected 160×1024
-- launch. A hardware mapping of these inputs to a compiled thread is external.
def integer (group sg lane : Nat) (rowStep : BitVec 32) : Expr → Option (BitVec 32)
  | .variable name => if name="ROWS_TG" then some 32 else if name="R" then some 17408
    else if name="simdgroup_index_in_threadgroup" then some (BitVec.ofNat 32 sg)
    else if name="thread_index_in_simdgroup" then some (BitVec.ofNat 32 lane)
    else if name="rowStep" then some rowStep else if name="lane" then some (BitVec.ofNat 32 lane) else none
  | .builtin name component => if component="y" then
      if name="threadgroups_per_grid" then some 160
      else if name="thread_position_in_grid" then some (BitVec.ofNat 32 group) else none
    else none
  | .literal _ value => if value<2^31 then some (BitVec.ofNat 32 value) else none
  | .castUInt expression => integer group sg lane rowStep expression
  | .add a b => do pure ((←integer group sg lane rowStep a)+(←integer group sg lane rowStep b))
  | .multiply a b => do pure ((←integer group sg lane rowStep a)*(←integer group sg lane rowStep b))

def rows (group sg : Nat) : Option (List Nat) := do
  let step ←parseConstant constantSource
  if step.target="rowStep" then
    let increment ←integer group sg 0 0 step.value
    let loop ←parseLoop loopSource
    if loop.counter=loop.test ∧ loop.counter=loop.step then
      GateLoopSource.iterations 5 (←integer group sg 0 increment loop.initial)
        (←integer group sg 0 increment loop.bound) (←integer group sg 0 increment loop.increment)
    else none
  else none

attribute [local irreducible] parseConstant parseLoop

theorem rows_eq (group sg : Nat) : rows group sg=
    GateLoopSource.iterations 5 (BitVec.ofNat 32 (group*32+sg)) 17408 5120 := by
  unfold rows
  rw [parsed_constant]
  change (parseLoop loopSource).bind _=_
  rw [parsed_loop]
  change GateLoopSource.iterations 5 (BitVec.ofNat 32 group*BitVec.ofNat 32 32+BitVec.ofNat 32 sg) 17408 5120=_
  rw [←BitVec.ofNat_mul,←BitVec.ofNat_add]

def expected (group sg : Nat) : List Nat :=
  ((List.range 4).filter (fun iteration => decide (GateUpCodebook.row group sg iteration<17408))).map
    (GateUpCodebook.row group sg)

theorem iteration_values : ∀ base : Fin 5120,
    GateLoopSource.iterations 5 (BitVec.ofNat 32 base.val) 17408 5120=some
      (((List.range 4).filter (fun iteration => decide (base.val+5120*iteration<17408))).map
        (fun iteration => base.val+5120*iteration)) := by decide +kernel

theorem rows_selected (group sg : Nat) (groupBound : group<160) (simdBound : sg<32) :
    rows group sg=some (expected group sg) := by
  rw [rows_eq]
  have bound : group*32+sg<5120 := by omega
  exact iteration_values ⟨group*32+sg,bound⟩

def writer (lane : Nat) : Option Bool := do
  let binding ←parseConstant laneSource
  if binding.target≠"lane" then none else do
  let actualLane ←integer 0 0 lane 0 binding.value
  let guard ←parseWriter writerSource
  if guard.lane="lane" then do
    let selected ←integer 0 0 lane 0 guard.selected
    pure (actualLane=selected)
  else none

theorem writer_selected : ∀ lane : Fin 32, writer lane.val=some (decide (lane.val=0)) := by decide +kernel

theorem row_member (group sg row : Nat) (member : row ∈ expected group sg) :
    ∃ iteration, iteration<4 ∧ GateUpCodebook.row group sg iteration<17408 ∧ row=GateUpCodebook.row group sg iteration := by
  obtain ⟨iteration,member,equal⟩:=List.mem_map.mp member
  obtain ⟨range,valid⟩:=List.mem_filter.mp member
  exact ⟨iteration,List.mem_range.mp range,of_decide_eq_true valid,equal.symm⟩

theorem dispatch_unique (row : Nat) (rowBound : row<17408) :
    ∃! owner : Fin 160 × Fin 32, row ∈ expected owner.1.val owner.2.val := by
  have cover:=GateUpCodebook.row_coverage row rowBound
  refine ⟨(⟨row%5120/32,cover.1⟩,⟨row%32,cover.2.1⟩),?_,?_⟩
  · apply List.mem_map.mpr
    refine ⟨row/5120,List.mem_filter.mpr ⟨List.mem_range.mpr cover.2.2.1,?_⟩,cover.2.2.2⟩
    simp only [cover.2.2.2,decide_eq_true_eq]
    exact rowBound
  · intro owner member
    obtain ⟨iteration,iterationBound,valid,equal⟩:=row_member owner.1.val owner.2.val row member
    have inverse:=GateUpCodebook.row_inverse owner.1.val owner.2.val iteration owner.1.isLt owner.2.isLt
    apply Prod.ext
    · apply Fin.ext
      change owner.1.val=row%5120/32
      rw [equal]
      exact inverse.1.symm
    · apply Fin.ext
      change owner.2.val=row%32
      rw [equal]
      exact inverse.2.1.symm

theorem launch_groups : min 160 ((17408+32-1)/32)=160 := by decide

theorem writer_unique : ∃! lane : Fin 32, writer lane.val=some true := by
  refine ⟨⟨0,by decide⟩,?_,?_⟩
  · change writer 0=some true
    rw [writer_selected ⟨0,by decide⟩]
    rfl
  · intro other same
    rw [writer_selected] at same
    have zero : other.val=0 := of_decide_eq_true (Option.some.inj same)
    exact Fin.ext zero

theorem source_dispatch_unique (row : Nat) (rowBound : row<17408) :
    ∃! owner : Fin 160 × Fin 32, (rows owner.1.val owner.2.val).map (fun emitted => decide (row ∈ emitted))=some true := by
  have same : ∀ owner : Fin 160 × Fin 32,
      (rows owner.1.val owner.2.val).map (fun emitted => decide (row ∈ emitted))=some true ↔
        row ∈ expected owner.1.val owner.2.val := by
    intro owner
    rw [rows_selected owner.1.val owner.2.val owner.1.isLt owner.2.isLt]
    simp
  obtain ⟨owner,member,unique⟩:=dispatch_unique row rowBound
  exact ⟨owner,(same owner).2 member,fun other selected => unique other ((same other).1 selected)⟩

theorem dispatch_unique_iteration (row : Nat) (rowBound : row<17408) :
    ∃! point : Fin 160 × Fin 32 × Fin 4, GateUpCodebook.row point.1.val point.2.1.val point.2.2.val=row := by
  have cover:=GateUpCodebook.row_coverage row rowBound
  refine ⟨(⟨row%5120/32,cover.1⟩,⟨row%32,cover.2.1⟩,⟨row/5120,cover.2.2.1⟩),cover.2.2.2,?_⟩
  intro point same
  have inverse:=GateUpCodebook.row_inverse point.1.val point.2.1.val point.2.2.val point.1.isLt point.2.1.isLt
  rw [same] at inverse
  apply Prod.ext
  · apply Fin.ext
    exact inverse.1.symm
  · apply Prod.ext
    · apply Fin.ext
      exact inverse.2.1.symm
    · apply Fin.ext
      exact inverse.2.2.symm
end Inference.Kernels.Trellis.GateRowSource
