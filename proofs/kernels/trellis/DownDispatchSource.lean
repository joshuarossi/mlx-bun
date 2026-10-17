import kernels.trellis.DownSetupSource
import kernels.trellis.DownPointerArrays
namespace Inference.Kernels.Trellis.DownDispatchSource
open PackedArraySemantics Contracts.Mlx
set_option maxRecDepth 100000

def ySource : String := "const uint y = ty % 32u;"
def splitSource : String := "const uint split = y + 32u * (sg % 4u);"
def groupSource : String := "const uint colGroup = 2u * (ty / 32u) + sg / 4u;"
def blockSource : String := "const uint blk = colGroup * (32u / LB) + lane / LB;"
def rowSource : String := "const uint r0 = split * ROWS_PER;"
def countSource : String := "constexpr uint ROWS_PER = ((uint)R + (uint)SPLITS - 1u) / (uint)SPLITS;"

def state (values : List (String × Nat)) : State := ⟨values.map (fun pair => (pair.1,.unsigned (BitVec.ofNat 32 pair.2))),[],[]⟩
def run (text : String) (values : List (String × Nat)) (name : String) : Option (BitVec 32) :=
  (GatePointerSyntax.parse text).bind (fun code =>
    (DownSetupSource.executeDeclaration (state values) code).bind (fun state =>
      (lookupVariable state name).bind asUInt))
def count : Option (BitVec 32) :=
  (DownSetupSource.parse countSource).bind (fun code =>
    (DownSetupSource.executeDeclaration ⟨[("R",.signed 17408),("SPLITS",.signed 128)],[],[]⟩ code).bind
      (fun state => (lookupVariable state "ROWS_PER").bind asUInt))

theorem count_selected : count=some 136 := by decide +kernel

theorem y_selected : ∀ ty : Fin 160,
    run ySource [("ty",ty.val)] "y"=some (BitVec.ofNat 32 (ty.val%32)) := by decide +kernel

theorem split_selected : ∀ y : Fin 32, ∀ sg : Fin 8,
    run splitSource [("y",y.val),("sg",sg.val)] "split"=
      some (BitVec.ofNat 32 (y.val+32*(sg.val%4))) := by decide +kernel

theorem group_selected : ∀ ty : Fin 160, ∀ sg : Fin 8,
    run groupSource [("ty",ty.val),("sg",sg.val)] "colGroup"=
      some (BitVec.ofNat 32 (2*(ty.val/32)+sg.val/4)) := by decide +kernel

theorem block_selected : ∀ group : Fin 10, ∀ lane : Fin 32,
    run blockSource [("colGroup",group.val),("LB",16),("lane",lane.val)] "blk"=
      some (BitVec.ofNat 32 (group.val*2+lane.val/16)) := by decide +kernel

theorem row_selected : ∀ split : Fin 128,
    run rowSource [("split",split.val),("ROWS_PER",136)] "r0"=
      some (BitVec.ofNat 32 (split.val*136)) := by decide +kernel

def laneCount (k lane : Nat) : Option (BitVec 32) :=
  ((DownSetupSource.setup k lane).bind (fun state => lookupVariable state "LB")).bind asUInt

theorem lane_count (k lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<32) :
    laneCount k lane=some 16 := by
  rw [laneCount,DownSetupSource.setup_value k lane valid laneBound "LB"]
  rfl

-- Each source stage consumes the successful result of its predecessor.
-- The threadgroup builtins and native launch still supply ty, sg and lane.
def dispatch (k ty sg lane : Nat) : Option (BitVec 32 × BitVec 32 × BitVec 32) :=
  (laneCount k lane).bind (fun lb => count.bind (fun rows =>
    (run ySource [("ty",ty)] "y").bind (fun y =>
      (run splitSource [("y",y.toNat),("sg",sg)] "split").bind (fun split =>
        (run groupSource [("ty",ty),("sg",sg)] "colGroup").bind (fun group =>
          (run blockSource [("colGroup",group.toNat),("LB",lb.toNat),("lane",lane)] "blk").bind (fun block =>
            (run rowSource [("split",split.toNat),("ROWS_PER",rows.toNat)] "r0").map (fun row => (split,block,row))))))))

attribute [local irreducible] run count

theorem dispatch_selected (k ty sg lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) :
    dispatch k ty sg lane=some
      (BitVec.ofNat 32 (ty%32+32*(sg%4)),BitVec.ofNat 32 ((2*(ty/32)+sg/4)*2+lane/16),
        BitVec.ofNat 32 ((ty%32+32*(sg%4))*136)) := by
  have yBound : ty%32<32 := Nat.mod_lt _ (by decide)
  have groupBound : 2*(ty/32)+sg/4<10 := by omega
  have splitBound : ty%32+32*(sg%4)<128 := by omega
  have ys : ty%32<2^32 := by omega
  have gs : 2*(ty/32)+sg/4<2^32 := by omega
  have ss : ty%32+32*(sg%4)<2^32 := by omega
  simp only [dispatch,lane_count k lane valid laneBound,show (16 : BitVec 32).toNat=16 from rfl,
    show (136 : BitVec 32).toNat=136 from rfl,count_selected,Option.bind_some,y_selected ⟨ty,tyBound⟩,
    BitVec.toNat_ofNat,Nat.mod_eq_of_lt ys,split_selected ⟨ty%32,yBound⟩ ⟨sg,sgBound⟩,
    group_selected ⟨ty,tyBound⟩ ⟨sg,sgBound⟩,Nat.mod_eq_of_lt gs,
    block_selected ⟨_,groupBound⟩ ⟨lane,laneBound⟩,Nat.mod_eq_of_lt ss,
    row_selected ⟨_,splitBound⟩,Option.map_some]
end Inference.Kernels.Trellis.DownDispatchSource
