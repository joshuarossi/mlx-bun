import host.mlx.OrdinaryCachedSource
import host.mlx.OrdinaryCachedObjects
import host.mlx.OrdinaryCachedBounds

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedCall
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

theorem required_items_absent (i : Nat) (live : N0 i) : source.items.get i = none := by
  simp [N0] at live
  rcases live with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> host_kernel_rfl

/-- Checked source-side data for the actual ordinary native call. The target
interpretation and unrelated live cache roots belong to the body invariant. -/
structure InitialWitness (ν : Nat → F64) (C : CSrv) (nodes : Nat → GraphNode)
    (objects : Nat → Host.Mlx.Ffi.Annotated.Object) : Prop where
  nodeLookups : ∀ i, N0 i → source.nodes.get i = some (initialNode i)
  nodeAnnotations : ∀ i, N0 i → (initialRoles nodes i).Holds ν C
    Host.Ts.Owned.Annotated.identity (initialNode i)
  opaqueCut : ∀ i, N0 i → (initialRoles nodes i).graph = none → boundary i
  nodeBounds : ∀ i, N0 i → i < source.nnext
  objectLookups : ∀ h, requiredHandles h → source.obj? h = some (initialObject h)
  objectAnnotations : ∀ h, requiredHandles h → (objectRoles objects h).Holds ν C
    Host.Ts.Owned.Annotated.identity (initialObject h)
  handleBounds : ∀ h, requiredHandles h → h < source.next
  objectHandles : ∀ h, requiredHandles h → source.arrs.get h = none
  itemAbsence : ∀ i, N0 i → source.items.get i = none
  itemsBound : ∀ i x, source.items.get i = some x → i < source.nnext
  objectsBound : ∀ h o, source.objs.get h = some o → h < source.next
  arraysBound : ∀ h i, source.arrs.get h = some i → h < source.next
  nodeCounterBound : source.nnext < 2^64
  handleCounterBound : source.next < 2^64

theorem initial_witness (ν : Nat → F64) (C : CSrv) (nodes : Nat → GraphNode)
    (objects : Nat → Host.Mlx.Ffi.Annotated.Object) : InitialWitness ν C nodes objects := {
  nodeLookups := initial_node_lookup
  nodeAnnotations := initial_annotations ν C nodes
  opaqueCut := initial_role_cut nodes
  nodeBounds := initial_support
  objectLookups := initial_object_lookup
  objectAnnotations := initial_object_annotations ν C objects
  handleBounds := required_handle_bound
  objectHandles := required_handles_are_objects
  itemAbsence := required_items_absent
  itemsBound := source_items_bound
  objectsBound := source_objects_bound
  arraysBound := source_arrays_bound
  nodeCounterBound := by rw [source_counter]; decide +kernel
  handleCounterBound := by rw [source_handle_counter]; decide +kernel }

end Host.Load.Run.Full.Ordinary.CachedCall
