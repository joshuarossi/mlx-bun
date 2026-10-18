import host.ts.renameOrdinary.RankOriginGeometrySeed
import host.ts.renameOrdinary.initialClosure.Facts
import host.mlx.NativeIdentitySeed
import host.ts.StoreEntries

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.NativeSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi

noncomputable def native : Host.Mlx.Ffi.St := input.ffi.mlx
noncomputable def handles (h : Nat) : Prop := h < native.next
noncomputable def nodes (i : Nat) : Prop := i < native.nnext
noncomputable def roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode :=
  Geometry.entryRoles (Host.Mlx.Ffi.Annotated.Initial.nodeRoles native)
def boundary (_ : Nat) : Prop := True
def objectRelation (_ : Nat) (source target : Host.Mlx.Ffi.Obj) : Prop := source = target

theorem source_next : native.next = 29371 := by host_kernel_rfl
theorem source_nnext : native.nnext = 22587 := by host_kernel_rfl
theorem source_node_shapes : Host.Mlx.Ffi.Annotated.Initial.allPaged Host.Mlx.Ffi.Annotated.Initial.checkNode native.nodes = true := by host_kernel_rfl
theorem source_array_keys : native.arrs.checkBound native.next = true := by host_kernel_rfl
theorem source_object_keys : native.objs.checkBound native.next = true := by host_kernel_rfl
theorem source_item_keys : native.items.checkBound native.nnext = true := by host_kernel_rfl
theorem source_array_nodes : Host.Mlx.Ffi.Annotated.Initial.allPaged (fun i => Nat.blt i native.nnext) native.arrs = true := by host_kernel_rfl
theorem source_item_numbers : Host.Mlx.Ffi.Annotated.Initial.allPaged (ClosureCheck.number 10) native.items = true := by host_kernel_rfl
theorem source_token_numbers : native.tokens.all (ClosureCheck.number 10) = true := by host_kernel_rfl
theorem source_pending : native.pending = [] := by host_kernel_rfl
theorem source_error_handler : native.errh = some (.extPtr 281474976715479 0) := by host_kernel_rfl
theorem source_handle : native.arrs.get 29363 = some 22582 := by host_kernel_rfl

theorem source_annotation (ρ : Nat → F64) (C : CSrv) (i : Nat) (n : Node)
    (read : native.nodes.get i = some n) : (roles i).Holds ρ C identity n := by
  by_cases selected : i = 22582
  · subst i
    have same : n = Geometry.sourceNode := Option.some.inj (read.symm.trans Geometry.source_lookup)
    rw [same]
    exact Geometry.source_annotation ρ C identity
  · change (Geometry.entryRoles (Host.Mlx.Ffi.Annotated.Initial.nodeRoles native) i).Holds ρ C identity n
    rw [Geometry.entryRoles,ite_eq_right selected]
    exact Host.Mlx.Ffi.Annotated.Initial.nodeRoles_holds native source_node_shapes ρ C identity i n read

theorem handle_live : handles 29363 := by rw [handles,source_next]; decide +kernel

end Host.Load.Run.Full.Ordinary.RankOrigin.NativeSeed
