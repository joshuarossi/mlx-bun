import host.mlx.NativeMetalRetained

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.MetalCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

private theorem metadata_output_length {α β : Type} {rel : α → β → Prop} {xs : List α} {ys : List β}
    (held : ListR rel xs ys) : xs.length = ys.length := by
  induction held with
  | nil => rfl
  | cons _ _ ih => exact congrArg Nat.succ ih

/-- The captured ordinary source5760 Metal call derives its argument and
slot roles from the retained inventories and carries the updated producer
policy forward with its exact two output node IDs. -/
theorem retained_transport {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object) (configRole : Config)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole : Value)
    (note : notes.runtime.control = callNote fnRole thisRole
      ((MetalFamilyHost.arguments 3127256 18215 29387 29386 2).map FixedArgument.role))
    (selected : notes.buffers.owners 3127256 = some (handleSlotNotes 29388))
    (signatureFrame : ¬ framed 4589) (kernelLive : H 18215) (inputsLive : H 29387) (configLive : H 29386) (slotLive : H 29388)
    (fixedConfig : objects 29386 = .config configRole)
    (targetNodes : s.ffi.mlx.nnext + configRole.outs.length < 2^64)
    (targetHandles : s.ffi.mlx.next < 2^64) (targetHeap : s.next < 2^64) :
    let newRoles := kernelOutputRoles roles 18215 inputs configRole 22603 0 configRole.outs
    let newObjects := objectWrite objects 29388 (.vec [22603,22604])
    let newSupport := outputSupport N [22603,22604]
    ∃ t, interpC (step Host.Load.ffi input).run C₀ = some (output,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C newRoles boundary newObjects H newSupport tail host)
        R live framed before after old old' output t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote nativeStatusRole,notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live output t ∧
      ProducerAnnotations roots H newSupport newRoles newObjects ∧
      ProducerSupport roots H newSupport output.ffi.mlx := by
  dsimp only
  have callee := source_kind
  rw [source_caps] at callee
  obtain ⟨_,_,configHeld,_⟩ := h.native.2.config_view_roles 29386 configLive configRole config fixedConfig source_config
  have lengths := metadata_output_length configHeld.output
  have counter : input.ffi.mlx.nnext = 22603 := source_node_counter
  have sourceNodes : input.ffi.mlx.nnext + configRole.outs.length < 2^64 := by
    rw [lengths,source_output_count,counter]
    decide +kernel
  obtain ⟨t,left,right,post,retained,newPolicy,producers⟩ := MetalFamilyHost.retained_from_source ν₀ ν C₀ C R
    roles boundary objects H N tail host live framed before after old old' input s h inventory
    4798 4589 3127256 18215 29387 29386 2 29388 calleeObject signatureObject bufferObject returns (.obj 4817)
    kernelName kernelSource kernelHeader 7 2 inputs [] configRole config source_control source_callee callee
    source_signature source_signature_kind source_buffer source_buffer_kind signatureFrame kernelLive inputsLive configLive slotLive
    source_kernel source_inputs source_output source_config fixedConfig roots policy sourceNodes targetNodes
    (by decide +kernel) targetHandles (by decide +kernel) targetHeap fnRole thisRole note selected
  have endpoint : finishBuffer input (MetalFamilyHost.resultWorld input.ffi 18215 inputs config 29388) 3127256 0 bufferObject
      (cellParts .u64 (.big (Int.ofNat 29388)) 8 0) (cellParts .u64 (.big (Int.ofNat 29388)) 8 0)
      MetalFamilyHost.symbol (MetalFamilyHost.callArgs 3127256 18215 29387 29386 2 29388) = output := MetalHost.source_post
  rw [endpoint] at left post retained producers
  have outputIds : (MetalFamilyHost.result input.ffi 18215 inputs config).2 = [22603,22604] := MetalNative.result_nodes
  rw [outputIds,counter] at post newPolicy
  rw [outputIds] at producers
  exact ⟨t,left,right,post,retained,newPolicy,producers⟩

end Host.Load.Run.Full.Ordinary.MetalCall
