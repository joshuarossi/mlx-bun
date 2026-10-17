import kernels.trellis.DownControlSource
namespace Inference.Kernels.Trellis.DownControlDispatch
open DownControlSyntax DownControlSource PackedArraySemantics Contracts.Mlx
set_option maxRecDepth 100000

def groupsSource : String := "constexpr uint SGS = (NB + 32u / LB - 1u) / (32u / LB);"
def groups (k lane : Nat) : Option (BitVec 32) :=
  (DownSetupSource.setup k lane).bind (fun state =>
    (DownSetupSource.parse groupsSource).bind (fun code =>
      (DownSetupSource.executeDeclaration state code).bind (fun result =>
        (lookupVariable result "SGS").bind asUInt)))

theorem groups_selected : ∀ k : Fin 3, ∀ lane : Fin 32,
    groups (PackedArrayGate.width k) lane.val=some 10 := by decide +kernel

def blocks (k lane : Nat) : Option (BitVec 32) :=
  ((DownSetupSource.setup k lane).bind (fun state => lookupVariable state "NB")).bind asUInt

theorem blocks_selected (k lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<32) :
    blocks k lane=some 20 := by
  rw [blocks,DownSetupSource.setup_value k lane valid laneBound "NB"]
  rfl

def active (k ty sg lane : Nat) : Option Value :=
  (groups k lane).bind (fun sgs => (blocks k lane).bind (fun nb =>
    (DownDispatchSource.run DownDispatchSource.groupSource [("ty",ty),("sg",sg)] "colGroup").bind (fun group =>
      (DownDispatchSource.dispatch k ty sg lane).bind (fun point =>
        execute activeSource (fun name =>
          if name="colGroup" then some (.unsigned group)
          else if name="SGS" then some (.unsigned sgs)
          else if name="blk" then some (.unsigned point.2.1)
          else if name="NB" then some (.unsigned nb) else none)))))

attribute [local irreducible] groups blocks DownDispatchSource.run DownDispatchSource.dispatch DownControlSource.execute

theorem active_selected (k ty sg lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) :
    active k ty sg lane=some (.boolean true) := by
  have gs:=groups_selected (PackedArrayMaterialization.widthIndex k valid) ⟨lane,laneBound⟩
  simp only [PackedArrayMaterialization.width_index] at gs
  rw [active,gs,Option.bind_some,blocks_selected k lane valid laneBound,Option.bind_some,
    DownDispatchSource.group_selected ⟨ty,tyBound⟩ ⟨sg,sgBound⟩,Option.bind_some,
    DownDispatchSource.dispatch_selected k ty sg lane valid tyBound sgBound laneBound,Option.bind_some]
  exact DownControlSource.active_selected ⟨2*(ty/32)+sg/4,by omega⟩
    ⟨(2*(ty/32)+sg/4)*2+lane/16,by omega⟩

def rows (k ty sg lane : Nat) (r0 : BitVec 32) : Option Value :=
  (active k ty sg lane).bind (fun value =>
    (boolean value).bind (fun enabled => (DownDispatchSource.count).bind (fun count =>
      execute rowsSource (fun name => if name="ROWS_PER" then some (.unsigned count)
        else rowEnvironment enabled r0 name))))

theorem rows_selected (k ty sg lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (tyBound : ty<160) (sgBound : sg<8) (laneBound : lane<32) (r0 : BitVec 32) :
    rows k ty sg lane r0=some (.unsigned 136) := by
  rw [rows,active_selected k ty sg lane valid tyBound sgBound laneBound,Option.bind_some]
  simp only [boolean,Option.bind_some]
  rw [DownDispatchSource.count_selected,Option.bind_some]
  have environment : (fun name => if name="ROWS_PER" then some (.unsigned (136 : BitVec 32)) else rowEnvironment true r0 name)=rowEnvironment true r0 := by
    funext name
    by_cases selected : name="ROWS_PER"
    · subst name; rfl
    · simp only [selected,ite_false]
  rw [environment]
  exact DownControlSource.rows_selected true r0

theorem shifted_private (k lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<32) :
    DownControlSource.shifted k lane=lookupVariable (PackedArrayDown.initial k (lane%16)) "shifted" := by
  have selected:=DownControlSource.shifted_selected (PackedArrayMaterialization.widthIndex k valid) ⟨lane,laneBound⟩
  simp only [PackedArrayMaterialization.width_index] at selected
  exact selected
end Inference.Kernels.Trellis.DownControlDispatch
