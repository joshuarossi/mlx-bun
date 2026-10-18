import host.mlx.NativeLiteralGeometry
import host.mlx.NativeSliceDynamicRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def reshapeNode (input : Nat) (shape : List Dim) (dtype : Nat) : Node := ⟨.reshape shape,[input],shape,dtype⟩

theorem call_reshape_null (s : St) (out stream : Arg) (b off handle input shapeBuffer count : Nat)
    (bytes : List Byte) (shape old : List Dim) (dtype : Nat)
    (slot : slotOf out = some (b,off,0)) (ha : arrIns s [.big (Int.ofNat handle)] = some [input])
    (hs : dimsArg (.jsPtr shapeBuffer 0 bytes) (.big (Int.ofNat count)) = some shape)
    (metadata : shapesOf s [input] = some [(old,dtype)])
    (inference : infer (.reshape shape) [(old,dtype)] = M.pure (some (.node shape dtype))) :
    Ffi.call s chars!"mlx_reshape" [out,.big (Int.ofNat handle),.jsPtr shapeBuffer 0 bytes,.big (Int.ofNat count),stream] =
      okW (createZero s (reshapeNode input shape dtype)) status0 [u64Write b off s.next] := by
  have sy : symOf chars!"mlx_reshape" = some .reshape := by decide +kernel
  unfold Ffi.call
  rw [sy]
  simp only [ha,hs]
  exact opOut_node_zero s out b off (.reshape shape) [input] _ shape dtype slot metadata inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def reshapeRole (roles : Nat → GraphNode) (input : Nat) (shape : Shape) : GraphNode :=
  ⟨shape,(roles input).dtype,some (.reshape shape,[input])⟩

theorem reshape_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {input fresh : Nat}
    {node node' : Node} {shapeRoles : Shape} {shape shape' : List Dim}
    (hr : NodeRel roles ν₀ ν C₀ C R boundary input node node')
    (hs : Shape.Holds ν₀ C₀ shapeRoles shape) (ht : Shape.Holds ν C shapeRoles shape') :
    NodeRel (nodeWrite roles fresh (reshapeRole roles input shapeRoles)) ν₀ ν C₀ C R boundary fresh
      (reshapeNode input shape node.dtype) (reshapeNode (R.node input) shape' node'.dtype) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (reshapeRole roles input shapeRoles).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨hs,hr.source.dtype,?_⟩
    intro p ins he
    cases he
    exact ⟨.reshape hs,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (reshapeRole roles input shapeRoles).Holds ν C R _
    refine ⟨ht,hr.target.dtype,?_⟩
    intro p ins he
    cases he
    exact ⟨.reshape ht,rfl⟩
  · intro he
    simp only [nodeWrite,ite_true] at he
    cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Explicit reshape geometry is checked by integer products over fixed
dimension meanings. Both original inference calls and fresh producer writes
follow from those guards and the decoded shape buffers. -/
theorem reshape_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off handle input shapeBuffer : Nat) (bytes bytes' : List Byte)
    (shapeRoles : Shape) (node : Node) (handleLive : H handle)
    (producer : Ffi.nodesOf s [handle] = some [input]) (sourceNode : s.nodes.get input = some node)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (sourceShape : ShapeBuffer.Holds shapeRoles ν₀ C₀ bytes) (targetShape : ShapeBuffer.Holds shapeRoles ν C bytes')
    (decodable : shapeRoles.Decodable)
    (sourceGeometry : ReshapeGeometry ν₀ (roles input).shape shapeRoles)
    (targetGeometry : ReshapeGeometry ν (roles input).shape shapeRoles)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ shape shape' node', s'.nodes.get (R.node input) = some node' ∧
      Ffi.call s chars!"mlx_reshape" [out,.big (Int.ofNat handle),.jsPtr shapeBuffer 0 bytes,.big (Int.ofNat shapeRoles.length),stream] =
        okW (NativeRoles.createZero s (reshapeNode input shape node.dtype)) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_reshape" [out',.big (Int.ofNat (R.handle handle)),.jsPtr (R.a shapeBuffer) 0 bytes',
        .big (Int.ofNat shapeRoles.length),stream'] =
        okW (NativeRoles.createZero s' (reshapeNode (R.node input) shape' node'.dtype)) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (reshapeRole roles input shapeRoles)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (reshapeNode input shape node.dtype))
        (NativeRoles.createZero s' (reshapeNode (R.node input) shape' node'.dtype)) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [handle] [input] ⟨handleLive,True.intro⟩ producer
  obtain ⟨node',hn',hr⟩ := h.node_view support.1 sourceNode
  obtain ⟨shape,hs,sz⟩ := sourceShape.decode decodable shapeBuffer 0
  obtain ⟨shape',hs',sz'⟩ := targetShape.decode decodable (R.a shapeBuffer) 0
  have inference := sourceGeometry.infer hr.source.shape hs node.dtype
  have inference' := targetGeometry.infer hr.target.shape hs' node'.dtype
  have metadata : Ffi.shapesOf s [input] = some [(node.shape,node.dtype)] := by
    simp only [Ffi.shapesOf,sourceNode,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node input] = some [(node'.shape,node'.dtype)] := by
    simp only [Ffi.shapesOf,hn',Option.bind_some,Option.map_some]
  exact ⟨shape,shape',node',hn',
    call_reshape_null s out stream b off handle input shapeBuffer shapeRoles.length bytes shape node.shape node.dtype
      sourceSlot ha sz metadata inference,
    call_reshape_null s' out' stream' (R.a b) off (R.handle handle) (R.node input) (R.a shapeBuffer) shapeRoles.length bytes'
      shape' node'.shape node'.dtype targetSlot ha' sz' metadata' inference',
    h.createZeroRoles _ _ (reshape_created hr hs hs') (fun _ ne _ _ p => NodeRel.write_frame ne p)
      sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
