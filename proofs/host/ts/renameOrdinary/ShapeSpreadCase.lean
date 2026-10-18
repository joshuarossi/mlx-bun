import host.ts.renameOrdinary.HostCuts
import host.ts.RenameRouteDriver
import host.ts.RenameParametricShapeSpread

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro0 13 3126662 as Ordinary.ShapeSpread.viewObject
host_transport_object P.RestStream.micro0.micro0 13 3126661 as Ordinary.ShapeSpread.bufferObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.ShapeSpread
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

noncomputable def input : St Host.Load.LSt := P.RestStream.micro0.micro0.s13
noncomputable def output : St Host.Load.LSt := P.RestStream.micro0.micro0.s14
noncomputable def sourceNode : Host.Mlx.Ffi.Node :=
  (input.ffi.mlx.node? 29363).getD ⟨.zeros,[],[],0⟩
noncomputable def sourceEnv : Env := match input.stack with
  | .l (.spread _ _ env)::_ => env
  | _ => []

theorem source_control : input.ctl = .ret (.obj 3126662) := by host_kernel_rfl
theorem source_frame : input.stack = .l (.spread [] [] sourceEnv)::input.stack.tail := by host_kernel_rfl
theorem source_view : input.heap.get 3126662 = some (.obj viewObject) := by host_kernel_rfl
theorem source_view_kind : viewObject.kind = .typed .i32 3126661 0 (len sourceNode.shape) := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126661 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .extBuf (4*29363) 0 (len sourceNode.shape*4) := by host_kernel_rfl
theorem source_node : input.ffi.mlx.node? 29363 = some sourceNode := by host_kernel_rfl
theorem source_post :
    ({input with stack := input.stack.tail}.alloc
      (valueArray (sourceNode.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num)))).2.ret (.obj input.next) = output := by host_kernel_rfl
theorem source_bound : input.next < 2^64 := by decide +kernel
theorem source_run (C : CSrv) : interpC (step P.F input).run C = some (output,C) := by host_kernel_rfl

/-- The actual shape-spread source step reads all dimensions from its owned
native carrier. The target node, every read and the resulting JS shape array
follow from the host and annotated native invariants. -/
theorem transport (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (hhandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto) (ht : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live input.next) framed before after old old' output result := by
  obtain ⟨result,_,hr,hpost⟩ := Host.Load.Parametric.step_shape_spread_from_source FR R ν₀ ν C₀ C
    live framed before after old old' input s h roles ObjRel boundary H N tail native
    3126662 3126661 29363 viewObject bufferObject sourceNode sourceEnv input.stack.tail
    source_control source_frame source_view source_view_kind source_buffer source_buffer_kind
    source_node hhandle region hp hpr source_bound ht
  rw [source_post] at hpost
  exact ⟨result,hr,hpost⟩

theorem transport_fields (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (hhandle : H 29363) (region : R.region 117452 = 4*R.handle 29363)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto) (ht : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live input.next) framed before after old old' output result ∧
      ∃ node', Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary 22582 sourceNode node' ∧
        result.heap.get (R.a input.next) = some (valueArray (node'.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num))) := by
  obtain ⟨result,_,hr,hpost,i,node',hi,hrole,heap⟩ := Host.Load.Parametric.step_shape_spread_fields_from_source FR R ν₀ ν C₀ C
    live framed before after old old' input s h roles ObjRel boundary H N tail native
    3126662 3126661 29363 viewObject bufferObject sourceNode sourceEnv input.stack.tail
    source_control source_frame source_view source_view_kind source_buffer source_buffer_kind
    source_node hhandle region hp hpr source_bound ht
  rw [source_post] at hpost
  have index : input.ffi.mlx.arrs.get 29363 = some 22582 := by host_kernel_rfl
  have he : i = 22582 := Option.some.inj (hi.symm.trans index)
  subst i
  exact ⟨result,hr,hpost,node',hrole,heap⟩


end Host.Load.Run.Full.Ordinary.ShapeSpread
