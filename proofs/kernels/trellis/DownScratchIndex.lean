import kernels.trellis.DownScratchSyntax
namespace Inference.Kernels.Trellis.DownScratchIndex
open DownScratchSyntax PackedArraySemantics Contracts.Mlx
set_option maxRecDepth 100000

def context (k lane : Nat) : Option (List (String × Value)) :=
  (DownSetupSource.setup k lane).bind (fun state =>
    (DownSetupSource.parse columnsSource).bind (fun columns =>
      (DownSetupSource.executeDeclaration state columns).bind (fun state =>
        (GatePointerSyntax.parse localSource).bind (fun localCode =>
          (DownSetupSource.executeDeclaration state localCode).map State.variables))))

def localIndex (lane : Nat) : Nat := (lane/16)*256+255-(lane%16)*16

def expected (k lane : Nat) : List (String × Value) :=
  [("local",.unsigned (BitVec.ofNat 32 (localIndex lane))),("SG_COLS",.unsigned 512)] ++
    DownSetupSource.expected k lane ++ (DownSetupSource.initial k lane).variables

theorem context_closed : ∀ k : Fin 3, ∀ lane : Fin 32,
    context (PackedArrayGate.width k) lane.val=some (expected (PackedArrayGate.width k) lane.val) := by decide +kernel

def bindings (sg i : Nat) (context : List (String × Value)) : State := ⟨
  ("i",.unsigned (BitVec.ofNat 32 i))::("sg",.unsigned (BitVec.ofNat 32 sg))::context,[],[]⟩
def integer (state : State) (expression : PackedArraySyntax.Expr) : Option Nat :=
  (evaluate 16 state expression).bind (fun value => (asUInt value).map BitVec.toNat)

def target (k sg lane i : Nat) (code : StoreLoop) : Option Nat :=
  (context k lane).bind (fun vars => integer (bindings sg i vars) code.index)

theorem scalar_index (sg i : Nat) (localWord cols : BitVec 32) (tail : List (String × Value)) :
    integer (bindings sg i (("local",.unsigned localWord)::("SG_COLS",.unsigned cols)::tail)) store.index=
      some ((BitVec.ofNat 32 sg*cols+localWord-BitVec.ofNat 32 i).toNat) := rfl

theorem native_index : ∀ sg : Fin 8, ∀ lane : Fin 32, ∀ i : Fin 16,
    (BitVec.ofNat 32 sg.val*(512 : BitVec 32)+BitVec.ofNat 32 (localIndex lane.val)-BitVec.ofNat 32 i.val).toNat=
      DownCodebook.scratch sg.val lane.val i.val := by decide +kernel

theorem target_selected (k sg lane i : Nat) (valid : k=2 ∨ k=3 ∨ k=4)
    (sgBound : sg<8) (laneBound : lane<32) (column : i<16) :
    target k sg lane i store=some (DownCodebook.scratch sg lane i) := by
  have vars:=context_closed (PackedArrayMaterialization.widthIndex k valid) ⟨lane,laneBound⟩
  simp only [PackedArrayMaterialization.width_index] at vars
  rw [target,vars,Option.bind_some]
  unfold expected
  simp only [List.cons_append,List.nil_append]
  rw [scalar_index,native_index ⟨sg,sgBound⟩ ⟨lane,laneBound⟩ ⟨i,column⟩]

def valueIndex (k sg lane i : Nat) (code : StoreLoop) : Option Nat :=
  (context k lane).bind (fun vars => match code.value with
    | .index name [index] => if name="acc" then integer (bindings sg i vars) index else none
    | _ => none)

theorem scalar_value (sg i : Nat) (vars : List (String × Value)) :
    integer (bindings sg i vars) (.variable "i")=some (BitVec.ofNat 32 i).toNat := rfl

theorem value_selected (k sg lane i : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (laneBound : lane<32) (column : i<16) :
    valueIndex k sg lane i store=some i := by
  have vars:=context_closed (PackedArrayMaterialization.widthIndex k valid) ⟨lane,laneBound⟩
  simp only [PackedArrayMaterialization.width_index] at vars
  have small : i<2^32 := by omega
  rw [valueIndex,vars,Option.bind_some]
  change integer (bindings sg i (expected k lane)) (.variable "i")=some i
  rw [scalar_value,BitVec.toNat_ofNat,Nat.mod_eq_of_lt small]

def iterations (k lane : Nat) (code : StoreLoop) : Option (List Nat) :=
  if code.counter="i" ∧ code.counter=code.test ∧ code.counter=code.increment then
    (context k lane).bind (fun vars =>
      (integer (bindings 0 0 vars) code.start).bind (fun first =>
        (integer (bindings 0 0 vars) code.bound).bind (fun bound =>
          GateLoopSource.iterations 18 (BitVec.ofNat 32 first) (BitVec.ofNat 32 bound) 1)))
  else none

theorem iterations_closed : ∀ k : Fin 3, ∀ lane : Fin 32,
    iterations (PackedArrayGate.width k) lane.val store=some (List.range 16) := by decide +kernel
end Inference.Kernels.Trellis.DownScratchIndex
