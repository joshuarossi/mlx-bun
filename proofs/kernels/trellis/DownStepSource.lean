import kernels.trellis.DownWindowSource
import contracts.mlx.FlushToZero
namespace Inference.Kernels.Trellis.DownStepSource
open Contracts.Mlx Contracts.Mlx.M1Max DownStepSyntax
set_option maxRecDepth 10000
structure Operations where
  mul : Float32 → Float32 → Float32
  fma : Float32 → Float32 → Float32 → Float32

def standard : Operations := ⟨HMul.hMul,Float32.fma⟩
def flushing : Operations := ⟨FlushToZero.mul,FlushToZero.fma⟩

def integers (i u : Nat) : PackedArraySemantics.State := ⟨[
  ("i",.unsigned (BitVec.ofNat 32 i)),("u",.unsigned (BitVec.ofNat 32 u))],[],[]⟩
def integer (i u : Nat) (expression : PackedArraySyntax.Expr) : Option (BitVec 32) :=
  (PackedArraySemantics.evaluate 16 (integers i u) expression).bind PackedArraySemantics.asUInt

abbrev Frame := String → List (BitVec 32) → Option Float32

def frame (paired : Bool) (i u : Nat) (coefficient scale input previous : Float32) : Frame := fun name indices =>
  if name="code" ∧ indices=[] then some coefficient
  else if name="sr" ∧ indices=(if paired then [BitVec.ofNat 32 u] else []) then some scale
  else if name="xr" ∧ indices=(if paired then [BitVec.ofNat 32 u] else []) then some input
  else if name="acc" ∧ indices=[BitVec.ofNat 32 i] then some previous else none

def evaluate (ops : Operations) (i u : Nat) (locals : Frame) : PackedArraySyntax.Expr → Option Float32
  | .variable name => locals name []
  | .index name indices => (indices.mapM (integer i u)).bind (locals name)
  | .multiply a b => do pure (ops.mul (←evaluate ops i u locals a) (←evaluate ops i u locals b))
  | _ => none

def execute (ops : Operations) (i u : Nat) (locals : Frame) (code : Step) : Option (Nat × Float32) :=
  if code.target="acc" then
    (code.indices.mapM (integer i u)).bind (fun indices => match indices with
      | [target] => do
        let weight ←evaluate ops i u locals code.weight
        let input ←evaluate ops i u locals code.input
        let previous ←evaluate ops i u locals code.previous
        pure (target.toNat,ops.fma weight input previous)
      | _ => none)
  else none

theorem execute_selected (ops : Operations) (paired : Bool) (i u : Nat) (column : i<16)
    (coefficient scale input previous : Float32) :
    execute ops i u (frame paired i u coefficient scale input previous) (DownStepSyntax.step paired)=some
      (i,ops.fma (ops.mul coefficient scale) input previous) := by
  change execute ops i u (frame paired i u coefficient scale input previous)
    ⟨"acc",[.variable "i"],.multiply (.variable "code") (if paired then .index "sr" [.variable "u"] else .variable "sr"),
      (if paired then .index "xr" [.variable "u"] else .variable "xr"),.index "acc" [.variable "i"]⟩=_
  cases paired <;>
    simp [execute,evaluate,frame,integer,integers,
      PackedArraySemantics.evaluate,PackedArraySemantics.lookupVariable,PackedArraySemantics.lookup,
      PackedArraySemantics.asUInt,BitVec.toNat_ofNat] <;> omega

def row1 (r0 r : Nat) (paired : Bool) : Nat := r0+r+(if paired then 1 else 0)

def memoryStep (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (r0 r u block lane i : Nat) (paired : Bool) (load : ThreadgroupLoad) (memory : WordMemory)
    (base : Nat) (previous : Float32) : Option (Nat × Float32) :=
  (DownReadSource.read input activation r0 r u paired false).bind (fun x =>
    (DownReadSource.read input activation r0 r u paired true).bind (fun scale =>
      (DownWindowSource.code input (r0+r) (row1 r0 r paired) block lane u i paired load memory base).bind (fun coefficient =>
        (parse stepTokens (if paired then pairStepSource else tailStepSource)).bind
          (execute ops i u (frame paired i u coefficient scale x previous)))))

attribute [local irreducible] execute DownReadSource.read DownWindowSource.code parse

theorem memory_step (ops : Operations) (input : PackedArrayDownMaterialization.Input k)
    {values : Fin 17408 → ArrayStorage.BF} (activation : ArrayStorage.BFBuffer values)
    (r0 r u block lane i : Nat) (paired : Bool)
    (pairBound : row1 r0 r paired<17408) (uBound : if paired then u<2 else u=0)
    (blockBound : block<20) (laneBound : lane<16) (column : i<16)
    (load : ThreadgroupLoad) (memory : WordMemory) (base : Nat) (previous : Float32) :
    memoryStep ops input activation r0 r u block lane i paired load memory base previous=some
      (i,ops.fma
        (ops.mul (CodebookLoad.read load memory base
          (DownCodebook.Lane.alignedWord (input.matrix (r0+r+(if paired then u else 0)) block) k lane) (i*k))
          (Models.Qwen.CheckpointTrellis.scale input.scales (r0+r+(if paired then u else 0))))
        (BFloat16.widen (values ⟨r0+r+(if paired then u else 0),by cases paired <;> simp_all [row1]; omega⟩)) previous) := by
  have row0Bound : r0+r<17408 := by cases paired <;> simp_all [row1]; omega
  have rowBound : r0+r+(if paired then u else 0)<17408 := by cases paired <;> simp_all [row1]; omega
  have rowEq : PackedArrayDownMaterialization.selectedRow (r0+r) (row1 r0 r paired) u=
      r0+r+(if paired then u else 0) := by
    cases paired <;> simp_all [PackedArrayDownMaterialization.selectedRow,row1]
    split <;> omega
  rw [memoryStep,DownReadSource.original input activation r0 r u paired false rowBound,Option.bind_some,
    DownReadSource.original input activation r0 r u paired true rowBound,Option.bind_some,
    DownWindowSource.code_current input (r0+r) (row1 r0 r paired) block lane u i paired row0Bound pairBound blockBound laneBound uBound column load memory base,
    Option.bind_some,parsed_steps,Option.bind_some,execute_selected ops paired i u column]
  rw [rowEq]
  rfl
end Inference.Kernels.Trellis.DownStepSource
