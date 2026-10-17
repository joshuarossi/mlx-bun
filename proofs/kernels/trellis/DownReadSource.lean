import kernels.trellis.DownStepSyntax
import kernels.trellis.DownDispatchPointer
namespace Inference.Kernels.Trellis.DownReadSource
open Contracts.Mlx Models.Qwen DownStepSyntax PackedArraySemantics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

def integers (r0 r u : Nat) : State := ⟨[
  ("r0",.unsigned (BitVec.ofNat 32 r0)),("r",.unsigned (BitVec.ofNat 32 r)),
  ("u",.unsigned (BitVec.ofNat 32 u))],[],[]⟩

def index (r0 r u : Nat) (code : Read) : Option Nat :=
  (evaluate 16 (integers r0 r u) code.index).bind (fun value => (asUInt value).map BitVec.toNat)

theorem index_selected (r0 r u : Nat) (paired scale : Bool)
    (bound : r0+r+(if paired then u else 0)<17408) :
    index r0 r u (DownStepSyntax.read paired scale)=some (r0+r+(if paired then u else 0)) := by
  have rows := DownPointerSource.uint_row r0 r (if paired then u else 0) bound
  cases paired with
  | false =>
    have reduced : (BitVec.ofNat 32 r0+BitVec.ofNat 32 r).toNat=r0+r := by
      simpa only [Bool.false_eq_true,ite_false,BitVec.toNat_add,BitVec.toNat_ofNat,Nat.zero_mod,Nat.add_zero,Nat.mod_mod] using rows
    change some (BitVec.ofNat 32 r0+BitVec.ofNat 32 r).toNat=some (r0+r+0)
    rw [reduced,Nat.add_zero]
  | true =>
    simp only [ite_true] at rows
    change some (BitVec.ofNat 32 r0+BitVec.ofNat 32 r+BitVec.ofNat 32 u).toNat=some (r0+r+u)
    rw [rows]

def indicesMatch (paired : Bool) (code : Read) : Bool :=
  match paired,code.indices with
  | false,[] => true
  | true,[.variable name] => name="u"
  | _,_ => false

def load (input : PackedArrayDownMaterialization.Input k) {values : Fin 17408 → ArrayStorage.BF}
    (activation : ArrayStorage.BFBuffer values) (r0 r u : Nat) (paired scale : Bool) (code : Read) : Option Float32 :=
  if code.target=(if scale then "sr" else "xr") ∧ indicesMatch paired code=true ∧
      code.array=(if scale then "scales" else "x") then
    (index r0 r u code).bind (fun row => if h : row<17408 then
      if scale then some (Float16.widen (Model.ofBits (HalfMemory.load input.storage.code.bytes (input.storage.scale.base+2*row))))
      else some (BFloat16.widen (activation.read ⟨row,h⟩))
      else none)
  else none

def read (input : PackedArrayDownMaterialization.Input k) {values : Fin 17408 → ArrayStorage.BF}
    (activation : ArrayStorage.BFBuffer values) (r0 r u : Nat) (paired scale : Bool) : Option Float32 :=
  (parse (readTokens (!paired)) (if paired then (if scale then pairScaleSource else pairInputSource)
      else (if scale then tailScaleSource else tailInputSource))).bind (load input activation r0 r u paired scale)

def value (input : PackedArrayDownMaterialization.Input k) (activation : Fin 17408 → ArrayStorage.BF)
    (row : Fin 17408) (scale : Bool) : Float32 :=
  if scale then CheckpointTrellis.scale input.scales row.val else BFloat16.widen (activation row)

attribute [local irreducible] parse index

theorem original (input : PackedArrayDownMaterialization.Input k) {values : Fin 17408 → ArrayStorage.BF}
    (activation : ArrayStorage.BFBuffer values) (r0 r u : Nat) (paired scale : Bool)
    (bound : r0+r+(if paired then u else 0)<17408) :
    read input activation r0 r u paired scale=some
      (value input values ⟨r0+r+(if paired then u else 0),bound⟩ scale) := by
  rw [read,parsed_reads,Option.bind_some]
  unfold load
  have names : (DownStepSyntax.read paired scale).target=(if scale then "sr" else "xr") ∧
      indicesMatch paired (DownStepSyntax.read paired scale)=true ∧
      (DownStepSyntax.read paired scale).array=(if scale then "scales" else "x") := by
    cases paired <;> exact ⟨rfl,rfl,rfl⟩
  rw [ite_eq_left names,index_selected r0 r u paired scale bound,Option.bind_some,dite_eq_left bound]
  cases scale with
  | false =>
    rw [activation.read_correct]
    rfl
  | true =>
    rw [input.storage.scale_load ⟨_,bound⟩]
    rfl
end Inference.Kernels.Trellis.DownReadSource
