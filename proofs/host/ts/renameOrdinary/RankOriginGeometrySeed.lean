import host.ts.renameOrdinary.RankOriginResult
import host.ts.RenameMaterializeState
import host.mlx.ClosedGeometry
import host.mlx.NativeShapeValueRoles
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin.Geometry
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

noncomputable def sourceNode : Node := (RankOrigin.input.ffi.mlx.nodes.get 22582).getD ⟨.zeros,[],[],0⟩
def hiddenRole : GraphNode := ⟨closedShape [1,1,10240],12,none⟩
def entryRoles (rest : Nat → GraphNode) (i : Nat) : GraphNode := if i = 22582 then hiddenRole else rest i

theorem source_lookup : RankOrigin.input.ffi.mlx.nodes.get 22582 = some sourceNode := by host_kernel_rfl
theorem source_shape : sourceNode.shape = [.lit 1,.lit 1,.lit 10240] := by host_kernel_rfl
theorem source_dtype : sourceNode.dtype = 12 := by host_kernel_rfl

theorem hidden_role_shape (rest : Nat → GraphNode) : (entryRoles rest 22582).shape.valueRoles =
    [.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 10240))] := by
  host_kernel_rfl

/-- Literal shape metadata at this initialized input is independent of numeric
valuation and table allocation. The input tensor is an explicit graph root. -/
theorem source_annotation (ν : Nat → F64) (C : CSrv) (R : Ren) : hiddenRole.Holds ν C R sourceNode := by
  refine ⟨?_,source_dtype,?_⟩
  · rw [source_shape]
    exact closedShape_holds ν C [1,1,10240] (by dsimp [Host.Ts.Owned.listSupport]; decide +kernel)
  · intro p ins graph
    cases graph

/-- Initial numeric specialization keeps the three literal dimensions. This
witness does not assert geometry for an arbitrary related native graph. -/
theorem materialized_annotation (table C : CSrv) (ν : Nat → F64) (R : Ren) :
    hiddenRole.Holds ν C R ((materializer table).nativeNode sourceNode) := by
  refine ⟨?_,source_dtype,?_⟩
  · change Shape.Holds ν C hiddenRole.shape (sourceNode.shape.map (materializer table).dim)
    rw [source_shape]
    exact closedShape_holds ν C [1,1,10240] (by dsimp [Host.Ts.Owned.listSupport]; decide +kernel)
  · intro p ins graph
    cases graph

theorem materialized_lookup (table : CSrv) : (materializeNative table RankOrigin.input.ffi.mlx).nodes.get 22582 =
    some ((materializer table).nativeNode sourceNode) := by
  change (RankOrigin.input.ffi.mlx.nodes.map (materializer table).nativeNode).get 22582 = _
  rw [PTrie.get_map,source_lookup]
  rfl
end Host.Load.Run.Full.Ordinary.RankOrigin.Geometry
