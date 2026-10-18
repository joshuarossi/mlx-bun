import host.mlx.NativeInferredGeometry
import host.mlx.NativeReshapeRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def inferredReshapeNode (input : Nat) (request result : List Dim) (dtype : Nat) : Node :=
  ⟨.reshape request,[input],result,dtype⟩

theorem call_reshape_result_null (s : St) (out stream : Arg) (b off handle input shapeBuffer count : Nat)
    (bytes : List Byte) (request result old : List Dim) (dtype : Nat)
    (slot : slotOf out = some (b,off,0)) (producer : arrIns s [.big (Int.ofNat handle)] = some [input])
    (decode : dimsArg (.jsPtr shapeBuffer 0 bytes) (.big (Int.ofNat count)) = some request)
    (metadata : shapesOf s [input] = some [(old,dtype)])
    (inference : infer (.reshape request) [(old,dtype)] = M.pure (some (.node result dtype))) :
    Ffi.call s chars!"mlx_reshape" [out,.big (Int.ofNat handle),.jsPtr shapeBuffer 0 bytes,.big (Int.ofNat count),stream] =
      okW (createZero s (inferredReshapeNode input request result dtype)) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_reshape" = some .reshape := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  simp only [producer,decode]
  exact opOut_node_zero s out b off (.reshape request) [input] _ result dtype slot metadata inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def inferredReshapeRole (roles : Nat → GraphNode) (input : Nat) (leading : Shape) (feature : Int) : GraphNode :=
  ⟨trailingResult leading feature,(roles input).dtype,some (.reshape (trailingRequest leading),[input])⟩

theorem inferredReshape_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {input fresh : Nat} {node node' : Node}
    {leading : Shape} {feature : Int} {request request' result result' : List Dim}
    (h : NodeRel roles ν₀ ν C₀ C R boundary input node node')
    (hq : Shape.Holds ν₀ C₀ (trailingRequest leading) request) (hq' : Shape.Holds ν C (trailingRequest leading) request')
    (hr : Shape.Holds ν₀ C₀ (trailingResult leading feature) result) (hr' : Shape.Holds ν C (trailingResult leading feature) result') :
    NodeRel (nodeWrite roles fresh (inferredReshapeRole roles input leading feature)) ν₀ ν C₀ C R boundary fresh
      (inferredReshapeNode input request result node.dtype) (inferredReshapeNode (R.node input) request' result' node'.dtype) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (inferredReshapeRole roles input leading feature).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨hr,h.source.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.reshape hq,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (inferredReshapeRole roles input leading feature).Holds ν C R _
    refine ⟨hr',h.target.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.reshape hq',rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- The requested trailing -1 and the inferred result keep distinct graph
annotations. Both actual inference calls follow pure integer geometry guards. -/
theorem reshape_trailing_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off handle input shapeBuffer : Nat) (bytes bytes' : List Byte)
    (leading : Shape) (feature : Int) (node : Node) (handleLive : H handle)
    (producer : Ffi.nodesOf s [handle] = some [input]) (sourceNode : s.nodes.get input = some node)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (sourceShape : ShapeBuffer.Holds (trailingRequest leading) ν₀ C₀ bytes)
    (targetShape : ShapeBuffer.Holds (trailingRequest leading) ν C bytes')
    (decodable : (trailingRequest leading).Decodable)
    (sourceGeometry : TrailingReshapeGeometry ν₀ (roles input).shape leading feature)
    (targetGeometry : TrailingReshapeGeometry ν (roles input).shape leading feature)
    (featureExact : F64.toInt? (F64.ofInt feature) = some feature)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (request request' result result' : List Dim) (node' : Node),
      Ffi.call s chars!"mlx_reshape" [out,.big (Int.ofNat handle),.jsPtr shapeBuffer 0 bytes,
        .big (Int.ofNat (trailingRequest leading).length),stream] =
        okW (NativeRoles.createZero s (inferredReshapeNode input request result node.dtype)) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_reshape" [out',.big (Int.ofNat (R.handle handle)),.jsPtr (R.a shapeBuffer) 0 bytes',
        .big (Int.ofNat (trailingRequest leading).length),stream'] =
        okW (NativeRoles.createZero s' (inferredReshapeNode (R.node input) request' result' node'.dtype)) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (inferredReshapeRole roles input leading feature)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (inferredReshapeNode input request result node.dtype))
        (NativeRoles.createZero s' (inferredReshapeNode (R.node input) request' result' node'.dtype)) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [handle] [input] ⟨handleLive,True.intro⟩ producer
  obtain ⟨node',hn',hr⟩ := h.node_view support.1 sourceNode
  obtain ⟨request,hq,decode⟩ := sourceShape.decode decodable shapeBuffer 0
  obtain ⟨request',hq',decode'⟩ := targetShape.decode decodable (R.a shapeBuffer) 0
  obtain ⟨result,inference,hresult⟩ := sourceGeometry.infer node.dtype hr.source.shape hq featureExact
  obtain ⟨result',inference',hresult'⟩ := targetGeometry.infer node'.dtype hr.target.shape hq' featureExact
  have metadata : Ffi.shapesOf s [input] = some [(node.shape,node.dtype)] := by
    simp only [Ffi.shapesOf,sourceNode,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node input] = some [(node'.shape,node'.dtype)] := by
    simp only [Ffi.shapesOf,hn',Option.bind_some,Option.map_some]
  exact ⟨request,request',result,result',node',call_reshape_result_null s out stream b off handle input shapeBuffer
      (trailingRequest leading).length bytes request result node.shape node.dtype sourceSlot ha decode metadata inference,
    call_reshape_result_null s' out' stream' (R.a b) off (R.handle handle) (R.node input) (R.a shapeBuffer)
      (trailingRequest leading).length bytes' request' result' node'.shape node'.dtype targetSlot ha' decode' metadata' inference',
    h.createZeroRoles _ _ (inferredReshape_created hr hq hq' hresult hresult')
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
