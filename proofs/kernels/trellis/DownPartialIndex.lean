import kernels.trellis.DownPartialSyntax
namespace Inference.Kernels.Trellis.DownPartialIndex
open Contracts.Mlx PackedArraySemantics DownPartialSyntax
set_option maxRecDepth 10000
private def v := PackedArraySyntax.Expr.variable
open PackedArraySyntax.Expr in
def groupCode : GatePointerSyntax.Declaration := [
  ("group2",divide (v "c") (v "SG_COLS")),
  ("col",add (multiply (add (multiply (literal .unsigned 2) (divide (v "ty") (literal .unsigned 32))) (v "group2")) (v "SG_COLS"))
    (modulo (v "c") (v "SG_COLS")))]
theorem parsed_group : GatePointerSyntax.parse groupSource=some groupCode := rfl

def columns (k lane : Nat) : Option (BitVec 32) :=
  ((DownScratchIndex.context k lane).bind (fun vars => lookup "SG_COLS" vars)).bind asUInt

theorem columns_selected (k lane : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<32) :
    columns k lane=some 512 := by
  have selected:=DownScratchIndex.context_closed (PackedArrayMaterialization.widthIndex k valid) ⟨lane,laneBound⟩
  simp only [PackedArrayMaterialization.width_index] at selected
  rw [columns,selected,Option.bind_some]
  rfl

def group (ty c : Nat) (cols : BitVec 32) : Option (BitVec 32 × BitVec 32) :=
  (GatePointerSyntax.parse groupSource).bind (fun code =>
    (DownSetupSource.executeDeclaration ⟨[("ty",.unsigned (BitVec.ofNat 32 ty)),("c",.unsigned (BitVec.ofNat 32 c)),("SG_COLS",.unsigned cols)],[],[]⟩ code).bind
      (fun state => (lookupVariable state "group2").bind (fun value => (asUInt value).bind (fun group =>
        (lookupVariable state "col").bind (fun value => (asUInt value).map (fun col => (group,col)))))))

theorem group_selected (ty c : Nat) (tyBound : ty<160) (columnBound : c<1024) :
    group ty c 512=some (BitVec.ofNat 32 (c/512),BitVec.ofNat 32 (DownCodebook.column ty c)) := by
  rw [group,parsed_group,Option.bind_some]
  change some (BitVec.ofNat 32 ((BitVec.ofNat 32 c).toNat/512),
    ((2 : BitVec 32)*BitVec.ofNat 32 ((BitVec.ofNat 32 ty).toNat/32)+BitVec.ofNat 32 ((BitVec.ofNat 32 c).toNat/512))*512+
      BitVec.ofNat 32 ((BitVec.ofNat 32 c).toNat%512))=_
  apply congrArg some
  apply Prod.ext
  · rw [BitVec.toNat_ofNat,Nat.mod_eq_of_lt (show c<2^32 by omega)]
  · apply BitVec.eq_of_toNat_eq
    unfold DownCodebook.column
    simp (disch := omega) only [show (2 : BitVec 32).toNat=2 from rfl,show (512 : BitVec 32).toNat=512 from rfl,
      BitVec.toNat_add,BitVec.toNat_mul,BitVec.toNat_ofNat,Nat.mod_eq_of_lt]

def offsetEnvironment (y col : Nat) : DownPointerSemantics.Environment := fun name =>
  if name="y" then some (.uint (BitVec.ofNat 32 y))
  else if name="C" then some (.signed 5120)
  else if name="col" then some (.uint (BitVec.ofNat 32 col)) else none

def offset (y col : Nat) (code : Store) : Option (BitVec 64) :=
  if code.target="partial" ∧ code.value="t" then
    (DownPointerSemantics.evaluate (offsetEnvironment y col) code.index).bind (fun value => match value with
      | .ulong index => some index
      | _ => none)
  else none

theorem offset_selected (y col : Nat) (yBound : y<32) (colBound : col<5120) :
    (offset y col store).map BitVec.toNat=some (y*5120+col) := by
  have ySmall : y<2^32 := by omega
  have colSmall : col<2^32 := by omega
  change some ((BitVec.ofNat 64 (BitVec.ofNat 32 y).toNat*(5120 : BitVec 64)+BitVec.ofNat 64 (BitVec.ofNat 32 col).toNat).toNat)=_
  simp (disch := omega) only [show (5120 : BitVec 64).toNat=5120 from rfl,BitVec.toNat_add,BitVec.toNat_mul,BitVec.toNat_ofNat,Nat.mod_eq_of_lt]
end Inference.Kernels.Trellis.DownPartialIndex
