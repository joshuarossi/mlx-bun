import kernels.trellis.DownPartialIndex
namespace Inference.Kernels.Trellis.DownPartialSum
open Contracts.Mlx DownPartialSyntax PackedArraySemantics
set_option maxRecDepth 10000
abbrev Addition := Float32 → Float32 → Float32

def state (c : Nat) (group cols split : BitVec 32) : State := ⟨[
  ("c",.unsigned (BitVec.ofNat 32 c)),("group2",.unsigned group),
  ("SG_COLS",.unsigned cols),("k",.unsigned split)],[],[]⟩
def integer (state : State) (expression : PackedArraySyntax.Expr) : Option Nat :=
  (evaluate 32 state expression).bind (fun value => (asUInt value).map BitVec.toNat)

def evaluateFloat (add : Addition) (heap : ByteMemory.Bytes) (base : Nat) (integers : State)
    (target : String) (previous : Float32) : PackedArraySyntax.Expr → Option Float32
  | .variable name => if name=target then some previous else none
  | .index name [expression] => if name="sums" then
      (integer integers expression).bind (fun index =>
        if index<4096 then some (FloatMemory.load heap (base+4*index)) else none)
      else none
  | .add a b => do pure (add (←evaluateFloat add heap base integers target previous a)
    (←evaluateFloat add heap base integers target previous b))
  | _ => none

def iterations (integers : State) (code : SumLoop) : Option (List Nat) :=
  if code.counter="k" ∧ code.counter=code.test ∧ code.counter=code.increment then
    (integer integers code.start).bind (fun start => (integer integers code.bound).bind (fun bound =>
      GateLoopSource.iterations 6 (BitVec.ofNat 32 start) (BitVec.ofNat 32 bound) 1))
  else none

theorem iterations_selected (integers : State) : iterations integers sum=some (List.range 4) := rfl

private def index : PackedArraySyntax.Expr :=
  .add (.multiply (.add (.multiply (.variable "group2") (.literal .unsigned 4)) (.variable "k")) (.variable "SG_COLS"))
    (.modulo (.variable "c") (.variable "SG_COLS"))

theorem index_selected : ∀ c : Fin 1024, ∀ split : Fin 4,
    integer (state c.val (BitVec.ofNat 32 (c.val/512)) 512 (BitVec.ofNat 32 split.val)) index=some
      ((c.val/512*4+split.val)*512+c.val%512) := by decide +kernel

def stage (add : Addition) (heap : ByteMemory.Bytes) (base c : Nat) (group cols : BitVec 32) : Option Float32 :=
  (parse zeroTokens zeroSource).bind (fun initial =>
    (DownInitialSource.zeroLiteral initial.2).bind (fun zero =>
      (parse sumTokens sumSource).bind (fun code =>
        if code.target=initial.1 then
          (iterations (state c group cols 0) code).bind (fun splits =>
            splits.foldlM (fun previous split => evaluateFloat add heap base
              (state c group cols (BitVec.ofNat 32 split)) code.target previous code.value) zero)
        else none)))

theorem step_selected (add : Addition) (heap : ByteMemory.Bytes) (base c split : Nat)
    (columnBound : c<1024) (splitBound : split<4) (previous : Float32) :
    evaluateFloat add heap base (state c (BitVec.ofNat 32 (c/512)) 512 (BitVec.ofNat 32 split)) "t" previous sum.value=some
      (add (FloatMemory.load heap (base+4*((c/512*4+split)*512+c%512))) previous) := by
  rw [show sum.value=PackedArraySyntax.Expr.add (.index "sums" [index]) (.variable "t") from rfl]
  simp only [evaluateFloat,ite_true]
  rw [index_selected ⟨c,columnBound⟩ ⟨split,splitBound⟩,Option.bind_some,
    ite_eq_left (by omega)]
  rfl

attribute [local irreducible] iterations evaluateFloat parse

theorem stage_selected (add : Addition) (heap : ByteMemory.Bytes) (base c : Nat) (columnBound : c<1024) :
    stage add heap base c (BitVec.ofNat 32 (c/512)) 512=some
      (DownCodebook.scalarRows (fun split previous => add
        (FloatMemory.load heap (base+4*((c/512*4+split)*512+c%512))) previous) 0 4 0) := by
  rw [stage,parsed_zero,Option.bind_some]
  change (parse sumTokens sumSource).bind _=_
  rw [parsed_sum,Option.bind_some]
  change (iterations (state c (BitVec.ofNat 32 (c/512)) 512 0) sum).bind _=_
  rw [iterations_selected,Option.bind_some]
  have folded:=GateLoopSource.fold_exact (List.range 4)
    (fun split previous => evaluateFloat add heap base (state c (BitVec.ofNat 32 (c/512)) 512 (BitVec.ofNat 32 split)) "t" previous sum.value)
    (fun split previous => add (FloatMemory.load heap (base+4*((c/512*4+split)*512+c%512))) previous)
    (fun split member previous => step_selected add heap base c split columnBound (List.mem_range.mp member) previous) 0
  rw [show sum.target="t" from rfl,folded]
  rfl
end Inference.Kernels.Trellis.DownPartialSum
