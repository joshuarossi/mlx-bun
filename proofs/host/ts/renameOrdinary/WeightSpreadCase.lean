import host.ts.renameOrdinary.WeightTypedCase
import host.ts.RenameRouteDriver
import host.ts.RenameParametricShapeSpread

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Load.Run.Full
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape.SpreadNative
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

noncomputable def input : St Host.Load.LSt := P.RestStream.micro0.micro5.s55
noncomputable def output : St Host.Load.LSt := P.RestStream.micro0.micro5.s56
noncomputable def viewObject : Obj := (input.obj? TypedNative.input.next).getD ⟨.ordinary,.null,[],[],true⟩
noncomputable def bufferObject : Obj := (input.obj? BufferNative.input.next).getD ⟨.ordinary,.null,[],[],true⟩
noncomputable def sourceNode : Host.Mlx.Ffi.Node :=
  (input.ffi.mlx.node? 1365).getD ⟨.zeros,[],[],0⟩
noncomputable def sourceEnv : Env := match input.stack with
  | .l (.spread _ _ env)::_ => env
  | _ => []

theorem source_control : input.ctl = .ret (.obj (TypedNative.input.next)) := by host_kernel_rfl
theorem source_frame : input.stack = .l (.spread [] [] sourceEnv)::input.stack.tail := by host_kernel_rfl
theorem source_view : input.heap.get (TypedNative.input.next) = some (.obj viewObject) := by host_kernel_rfl
theorem source_view_kind : viewObject.kind = .typed .i32 (BufferNative.input.next) 0 (len sourceNode.shape) := by host_kernel_rfl
theorem source_buffer : input.heap.get (BufferNative.input.next) = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .extBuf (4*1365) 0 (len sourceNode.shape*4) := by host_kernel_rfl
theorem source_node : input.ffi.mlx.node? 1365 = some sourceNode := by host_kernel_rfl
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
    (hhandle : H 1365) (region : R.region 5460 = 4*R.handle 1365)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto) (ht : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live input.next) framed before after old old' output result := by
  obtain ⟨result,_,hr,hpost⟩ := Host.Load.Parametric.step_shape_spread_from_source FR R ν₀ ν C₀ C
    live framed before after old old' input s h roles ObjRel boundary H N tail native
    (TypedNative.input.next) (BufferNative.input.next) 1365 viewObject bufferObject sourceNode sourceEnv input.stack.tail
    source_control source_frame source_view source_view_kind source_buffer source_buffer_kind
    source_node hhandle region hp hpr source_bound ht
  rw [source_post] at hpost
  exact ⟨result,hr,hpost⟩

theorem transport_fields_frame (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (hhandle : H 1365) (region : R.region 5460 = 4*R.handle 1365)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto) (ht : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live input.next) framed before after old old' output result ∧
      ∃ node', Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary 1329 sourceNode node' ∧
        result.heap.get (R.a input.next) = some (valueArray (node'.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num))) ∧
        ∀ a, a < s.next → result.heap.get a = s.heap.get a := by
  obtain ⟨result,_,hr,hpost,i,node',hi,hrole,heap,frame⟩ := Host.Load.Parametric.step_shape_spread_fields_frame_from_source FR R ν₀ ν C₀ C
    live framed before after old old' input s h roles ObjRel boundary H N tail native
    (TypedNative.input.next) (BufferNative.input.next) 1365 viewObject bufferObject sourceNode sourceEnv input.stack.tail
    source_control source_frame source_view source_view_kind source_buffer source_buffer_kind
    source_node hhandle region hp hpr source_bound ht
  rw [source_post] at hpost
  have index : input.ffi.mlx.arrs.get 1365 = some 1329 := by host_kernel_rfl
  have he : i = 1329 := Option.some.inj (hi.symm.trans index)
  subst i
  exact ⟨result,hr,hpost,node',hrole,heap,frame⟩


theorem transport_fields (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Host.Load.LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' input s)
    (roles : Nat → Host.Mlx.Ffi.Annotated.GraphNode)
    (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Host.Mlx.Ffi.NativeRoles.Live (NumberRoles ν₀ ν C₀ C) R
      (Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail input.ffi.mlx s.ffi.mlx)
    (hhandle : H 1365) (region : R.region 5460 = 4*R.handle 1365)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto) (ht : s.next < 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live input.next) framed before after old old' output result ∧
      ∃ node', Host.Mlx.Ffi.Annotated.NodeRel roles ν₀ ν C₀ C R boundary 1329 sourceNode node' ∧
        result.heap.get (R.a input.next) = some (valueArray (node'.shape.map (fun d : Host.Mlx.Ffi.Dim => Val.num d.num))) := by
  obtain ⟨result,run,relation,node',nodeRelation,heap,_⟩ := transport_fields_frame FR R ν₀ ν C₀ C live framed
    before after old old' s h roles ObjRel boundary H N tail native hhandle region hp hpr ht
  exact ⟨result,run,relation,node',nodeRelation,heap⟩

end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape.SpreadNative
