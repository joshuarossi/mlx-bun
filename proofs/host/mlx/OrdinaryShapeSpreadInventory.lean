import host.mlx.NativeShapeSpreadInventory
import host.ts.renameOrdinary.ShapeSpreadCase

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ShapeSpread
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- The actual source13→14 shape spread installs fixed element meanings from
the selected native node while retaining every existing inventory family. -/
theorem retained_transport (FR : Ren → P.F.S → P.F.S → Prop) {notes : RetainedNotes}
    (R : Ren) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (handleLive : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (protoLive : live aArrayProto) (protoFixed : R.a aArrayProto = aArrayProto) (bound : s.next < 2^64) :
    ∃ result targetNode,
      interpC (step P.F input).run C₀ = some (output,C₀) ∧
      interpC (step P.F s).run C = some (result,C) ∧
      Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary 22582 sourceNode targetNode ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live input.next) framed before after old old' output result ∧
      RetainedInventory (notes.shapeSpread input.next (roles 22582).shape.valueRoles)
        ν₀ ν C₀ C R (LiveAfter live input.next) output result := by
  obtain ⟨i,targetNode,targetFrames,index,_,nodeRole,sourceRun,targetRun,post,retained⟩ :=
    inventory.shape_spread_step FR h roles ObjRel boundary H N tail native
      3126662 3126661 29363 viewObject bufferObject sourceNode sourceEnv input.stack.tail
      source_control source_frame source_view source_view_kind source_buffer source_buffer_kind
      source_node handleLive region protoLive protoFixed source_bound bound
  have sourceIndex : input.ffi.mlx.arrs.get 29363 = some 22582 := by host_kernel_rfl
  have same : i = 22582 := Option.some.inj (index.symm.trans sourceIndex)
  subst i
  rw [source_post] at sourceRun post retained
  exact ⟨_,targetNode,sourceRun,targetRun,nodeRole,post,retained⟩

end Host.Load.Run.Full.Ordinary.ShapeSpread
