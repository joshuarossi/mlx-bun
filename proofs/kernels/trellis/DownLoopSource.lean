import kernels.trellis.DownLoopSyntax
import kernels.trellis.DownControlDispatch
namespace Inference.Kernels.Trellis.DownLoopSource
open DownLoopSyntax PackedArraySemantics Contracts.Mlx
set_option maxRecDepth 100000

def state (rows : Nat) (r : BitVec 32) : State := ⟨[
  ("r",.unsigned r),("rows",.unsigned (BitVec.ofNat 32 rows)),
  ("U",.signed 2),("P",.signed 16)],[],[]⟩
def integer (rows : Nat) (r : BitVec 32) (expression : PackedArraySyntax.Expr) : Option (BitVec 32) :=
  (evaluate 16 (state rows r) expression).bind asUInt

def initialValue : Option (BitVec 32) :=
  (parseInitial initialSource).bind (fun code =>
    if code.1="r" then integer 0 0 code.2 else none)

def iterate : Nat → Nat → BitVec 32 → Loop → Option (List Nat × BitVec 32)
  | 0,_,_,_ => none
  | fuel+1,rows,current,code =>
    if code.counter="r" then
      (integer rows current code.left).bind (fun left =>
        (integer rows current code.right).bind (fun right =>
          if (if code.strict then left.toNat<right.toNat else left.toNat≤right.toNat) then
            (integer rows current code.increment).bind (fun increment =>
              (iterate fuel rows (current+increment) code).map (fun rest => (current.toNat::rest.1,rest.2)))
          else some ([],current)))
    else none
structure Rows where
  paired : List Nat
  tail : List Nat
  finalCounter : BitVec 32
  deriving DecidableEq,Repr

def rowRuns (rows : Nat) : Option Rows :=
  initialValue.bind (fun initial =>
    (parseLoop pairSource).bind (fun pair =>
      (iterate 70 rows initial pair).bind (fun pairs =>
        (parseLoop tailSource).bind (fun tail =>
          (iterate 3 rows pairs.2 tail).map (fun tails => ⟨pairs.1,tails.1,tails.2⟩)))))

theorem row_runs_selected : rowRuns 136=some ⟨(List.range 68).map (fun r => 2*r),[],136⟩ := by decide +kernel

def inner (isI : Bool) : Option (List Nat) :=
  (GateLoopSource.parseLoop (if isI then iSource else uSource)).bind (fun code =>
    if code.counter=code.test ∧ code.counter=code.step then
      (integer 136 0 code.start).bind (fun initial =>
        (integer 136 0 code.bound).bind (fun bound =>
          (integer 136 0 code.increment).bind (fun increment =>
            GateLoopSource.iterations 18 initial bound increment)))
    else none)

theorem inner_selected : ∀ isI : Bool, inner isI=some (List.range (if isI then 16 else 2)) := by decide +kernel

structure Event where
  r : Nat
  u : Nat
  i : Nat
  paired : Bool
  deriving DecidableEq,Repr

def sourceRows (k ty sg lane : Nat) : Option Rows :=
  (DownDispatchSource.dispatch k ty sg lane).bind (fun point =>
    (DownControlDispatch.rows k ty sg lane point.2.2).bind (fun value =>
      (asUInt value).bind (fun rows => rowRuns rows.toNat)))

attribute [local irreducible] rowRuns DownDispatchSource.dispatch DownControlDispatch.rows

theorem count_bind {α : Type} (continuation : BitVec 32 → Option α)
    (k ty sg lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) (r0 : BitVec 32) :
    ((DownControlDispatch.rows k ty sg lane r0).bind (fun value => (asUInt value).bind continuation))=continuation 136 := by
  rw [DownControlDispatch.rows_selected k ty sg lane valid tyBound sgBound laneBound,Option.bind_some]
  rfl

theorem source_rows_selected (k ty sg lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) :
    sourceRows k ty sg lane=some ⟨(List.range 68).map (fun r => 2*r),[],136⟩ := by
  have first : sourceRows k ty sg lane=rowRuns 136 := by
    rw [sourceRows,DownDispatchSource.dispatch_selected k ty sg lane valid tyBound sgBound laneBound,Option.bind_some]
    exact count_bind (fun rows => rowRuns rows.toNat) k ty sg lane valid tyBound sgBound laneBound _
  exact first.trans row_runs_selected

def events (k ty sg lane : Nat) : Option (List Event) :=
  (sourceRows k ty sg lane).bind (fun rows =>
    (inner false).bind (fun us => (inner true).map (fun is =>
      rows.paired.flatMap (fun r => us.flatMap (fun u => is.map (fun i => ⟨r,u,i,true⟩))) ++
      rows.tail.flatMap (fun r => is.map (fun i => ⟨r,0,i,false⟩)))))

def orderedEvents : List Event :=
  (List.range 68).flatMap (fun r => (List.range 2).flatMap (fun u => (List.range 16).map (fun i => ⟨2*r,u,i,true⟩)))

theorem events_selected (k ty sg lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) :
    events k ty sg lane=some orderedEvents := by
  rw [events,source_rows_selected k ty sg lane valid tyBound sgBound laneBound,Option.bind_some,
    inner_selected false,Option.bind_some,inner_selected true,Option.map_some]
  simp only [List.flatMap_map,List.flatMap_nil,List.append_nil]
  rfl

theorem event_bounds (point : Event) (member : point∈orderedEvents) :
    point.r%2=0 ∧ point.r<136 ∧ point.u<2 ∧ point.i<16 ∧ point.paired=true ∧ point.r+1<136 := by
  obtain ⟨r,rBound,member⟩:=List.mem_flatMap.mp member
  obtain ⟨u,uBound,member⟩:=List.mem_flatMap.mp member
  obtain ⟨i,iBound,equal⟩:=List.mem_map.mp member
  have hr:=List.mem_range.mp rBound
  have hu:=List.mem_range.mp uBound
  have hi:=List.mem_range.mp iBound
  subst point
  change (2*r)%2=0 ∧ 2*r<136 ∧ u<2 ∧ i<16 ∧ true=true ∧ 2*r+1<136
  exact ⟨by omega,by omega,hu,hi,rfl,by omega⟩
end Inference.Kernels.Trellis.DownLoopSource
