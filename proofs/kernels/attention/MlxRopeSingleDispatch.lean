import kernels.attention.MlxRopeSingleMemory
import kernels.attention.MlxRopeSingleAngles
import kernels.attention.RopeRowsDispatchMemory

namespace Inference.Kernels.Attention.MlxRopeSingleDispatch
open Contracts.Mlx MlxRopeSingleSyntax

-- Reviewed host translation of the pinned single-token partial-RoPE branch.
-- Native descriptor/flag attachment and copy allocation identity are inputs;
-- the guard checks the actual host branch and argument/grid bindings.
structure Metadata where
  batch : Nat
  heads : Nat
  tokens : Nat
  width : Nat
  rotary : Nat
  offsets : Nat
  contiguous : Bool
  withFreqs : Bool
  large : Bool
  forward : Bool
  traditional : Bool

def selected (m : Metadata) : Bool :=
  m.batch==1 && m.tokens==1 && m.width==256 && m.rotary==64 && m.offsets==1 &&
  m.contiguous && !m.withFreqs && !m.large && m.forward && !m.traditional

structure Dispatch where
  kernel : String
  gridX : Nat
  gridY : Nat
  stride : Nat
  inputIsOutput : Bool
  deriving DecidableEq, Repr

def dispatch (m : Metadata) : Option Dispatch :=
  if selected m then some ⟨"rope_single_bfloat16",m.rotary/2,m.batch*m.heads,m.width,true⟩ else none

def text (heads : Nat) : Metadata := ⟨1,heads,1,256,64,1,true,false,false,true,false⟩

theorem query_dispatch : dispatch (text 24)=some ⟨"rope_single_bfloat16",32,24,256,true⟩ := rfl
theorem key_dispatch : dispatch (text 4)=some ⟨"rope_single_bfloat16",32,4,256,true⟩ := rfl

theorem machine_index (head : Fin rows) (lane : Fin 32) (selectedRows : rows≤24) :
    (positions indices lane.val head.val 256 32).2<2^32 := by
  have := selected_range lane head
  omega

theorem uint32_indices (head : Fin rows) (lane : Fin 32) (selectedRows : rows≤24) :
    (BitVec.ofNat 32 (positions indices lane.val head.val 256 32).1).toNat=
      (positions indices lane.val head.val 256 32).1 ∧
    (BitVec.ofNat 32 (positions indices lane.val head.val 256 32).2).toNat=
      (positions indices lane.val head.val 256 32).2 := by
  have second := machine_index head lane selectedRows
  have first : (positions indices lane.val head.val 256 32).1<2^32 := by
    rw [selected_positions] at second ⊢
    dsimp at second ⊢
    omega
  exact ⟨Nat.mod_eq_of_lt first,Nat.mod_eq_of_lt second⟩

theorem device_address {rows base : Nat} {x : Fin rows → Fin 256 → ArrayStorage.BF}
    (source : RopeRowsMemory.Input x base) (head : Fin rows) (lane : Fin 32) :
    base+2*(positions indices lane.val head.val 256 32).2+2≤2^64 := by
  have inside := selected_range lane head
  have bounded := source.bounded
  omega

-- A preparation is the existing verified complete-head copy/reuse operation.
-- The actual partial branch always binds kernel input to preparation.output,
-- so parsed source loads see the copied CURRENT heap and stores reuse it.
theorem selected_execution {rows base : Nat} {x : Fin rows → Fin 256 → ArrayStorage.BF}
    {source : RopeRowsMemory.Input x base} {p : Rope.Platform}
    {theta : Fin rows → Fin 32 → Float32}
    (execution : RopeRowsDispatchMemory.Execution p source theta) :
    MlxRopeSingleMemory.Executes p execution.preparation.destination theta
      (RopeRowsDynamicMemory.initial execution.preparation.output.memory)
      execution.rotation.events execution.rotation.finish ∧
    execution.rotation.finish.memory=execution.output.memory :=
  ⟨MlxRopeSingleMemory.checked execution.rotation,rfl⟩

-- No stores outside the rotary prefix: the complete 256-element row survives
-- from preparation.output except the 32 disjoint captured operand pairs.
theorem retained_tail {rows base : Nat} {x : Fin rows → Fin 256 → ArrayStorage.BF}
    {source : RopeRowsMemory.Input x base} {p : Rope.Platform}
    {theta : Fin rows → Fin 32 → Float32}
    (execution : RopeRowsDispatchMemory.Execution p source theta)
    (head : Fin rows) (offset : Nat) (lower : 128≤offset) (upper : offset<512) :
    execution.output.memory (execution.destination+512*head.val+offset)=
      execution.preparation.output.memory (execution.destination+512*head.val+offset) := by
  change execution.rotation.finish.memory (execution.preparation.destination+512*head.val+offset)=_
  change execution.rotation.finish.memory (execution.preparation.destination+512*head.val+offset)=execution.preparation.output.memory (execution.preparation.destination+512*head.val+offset)
  rw [execution.rotation.memory_eq,execution.rotation.physical.trace.tail_byte head offset lower upper,
    execution.rotation.physical.before]

end Inference.Kernels.Attention.MlxRopeSingleDispatch
