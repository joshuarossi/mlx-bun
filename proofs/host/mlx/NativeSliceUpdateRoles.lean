import host.mlx.NativeSliceUpdateGeometry
import host.mlx.NativeSliceDynamicRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def sliceUpdateNode (input update : Nat) (start stop strides : List Dim) (node : Node) : Node :=
  ⟨.sliceUpdate start stop strides,[input,update],node.shape,node.dtype⟩

theorem call_sliceUpdate_null (s : St) (out stream : Arg) (b off handle update input updateInput : Nat)
    (startBuffer startCount stopBuffer stopCount strideBuffer strideCount : Nat)
    (startBytes stopBytes strideBytes : List Byte) (start stop strides : List Dim) (node updateNode : Node)
    (slot : slotOf out = some (b,off,0))
    (producer : arrIns s [.big (Int.ofNat handle),.big (Int.ofNat update)] = some [input,updateInput])
    (starts : dimsArg (.jsPtr startBuffer 0 startBytes) (.big (Int.ofNat startCount)) = some start)
    (stops : dimsArg (.jsPtr stopBuffer 0 stopBytes) (.big (Int.ofNat stopCount)) = some stop)
    (steps : dimsArg (.jsPtr strideBuffer 0 strideBytes) (.big (Int.ofNat strideCount)) = some strides)
    (metadata : shapesOf s [input,updateInput] = some [(node.shape,node.dtype),(updateNode.shape,updateNode.dtype)])
    (inference : infer (.sliceUpdate start stop strides) [(node.shape,node.dtype),(updateNode.shape,updateNode.dtype)] =
      M.pure (some (.node node.shape node.dtype))) :
    Ffi.call s chars!"mlx_slice_update" [out,.big (Int.ofNat handle),.big (Int.ofNat update),.jsPtr startBuffer 0 startBytes,
      .big (Int.ofNat startCount),.jsPtr stopBuffer 0 stopBytes,.big (Int.ofNat stopCount),
      .jsPtr strideBuffer 0 strideBytes,.big (Int.ofNat strideCount),stream] =
      okW (createZero s (sliceUpdateNode input updateInput start stop strides node)) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_slice_update" = some .sliceUpdate := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  simp only [producer,starts,stops,steps]
  exact opOut_node_zero s out b off (.sliceUpdate start stop strides) [input,updateInput] _ _ _ slot metadata inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def sliceUpdateRole (roles : Nat → GraphNode) (input update : Nat) (starts stops strides : Shape) : GraphNode :=
  ⟨(roles input).shape,(roles input).dtype,some (.sliceUpdate starts stops strides,[input,update])⟩

theorem sliceUpdate_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {input update fresh : Nat} {node node' : Node}
    {starts stops strides : Shape} {st st' sp sp' sr sr' : List Dim}
    (h : NodeRel roles ν₀ ν C₀ C R boundary input node node')
    (hs : Shape.Holds ν₀ C₀ starts st) (hs' : Shape.Holds ν C starts st')
    (he : Shape.Holds ν₀ C₀ stops sp) (he' : Shape.Holds ν C stops sp')
    (hr : Shape.Holds ν₀ C₀ strides sr) (hr' : Shape.Holds ν C strides sr') :
    NodeRel (nodeWrite roles fresh (sliceUpdateRole roles input update starts stops strides)) ν₀ ν C₀ C R boundary fresh
      (sliceUpdateNode input update st sp sr node) (sliceUpdateNode (R.node input) (R.node update) st' sp' sr' node') := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (sliceUpdateRole roles input update starts stops strides).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨h.source.shape,h.source.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.sliceUpdate hs he hr,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (sliceUpdateRole roles input update starts stops strides).Holds ν C R _
    refine ⟨h.target.shape,h.target.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.sliceUpdate hs' he' hr',rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem sliceUpdate_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off handle update input updateInput startBuffer stopBuffer strideBuffer : Nat)
    (startBytes startBytes' stopBytes stopBytes' strideBytes strideBytes' : List Byte)
    (starts stops strides : Shape) (node updateNode : Node) (handlesLive : listSupport H [handle,update])
    (producer : Ffi.nodesOf s [handle,update] = some [input,updateInput])
    (sourceNode : s.nodes.get input = some node) (sourceUpdate : s.nodes.get updateInput = some updateNode)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (sourceStarts : ShapeBuffer.Holds starts ν₀ C₀ startBytes) (targetStarts : ShapeBuffer.Holds starts ν C startBytes')
    (sourceStops : ShapeBuffer.Holds stops ν₀ C₀ stopBytes) (targetStops : ShapeBuffer.Holds stops ν C stopBytes')
    (sourceStrides : ShapeBuffer.Holds strides ν₀ C₀ strideBytes) (targetStrides : ShapeBuffer.Holds strides ν C strideBytes')
    (startsDecodable : starts.Decodable) (stopsDecodable : stops.Decodable) (stridesDecodable : strides.Decodable)
    (sourceGeometry : SliceUpdateGeometry ν₀ (roles input).shape (roles updateInput).shape starts stops strides)
    (targetGeometry : SliceUpdateGeometry ν (roles input).shape (roles updateInput).shape starts stops strides)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (st st' sp sp' sr sr' : List Dim) (node' : Node),
      Ffi.call s chars!"mlx_slice_update" [out,.big (Int.ofNat handle),.big (Int.ofNat update),.jsPtr startBuffer 0 startBytes,
        .big (Int.ofNat starts.length),.jsPtr stopBuffer 0 stopBytes,.big (Int.ofNat stops.length),
        .jsPtr strideBuffer 0 strideBytes,.big (Int.ofNat strides.length),stream] =
        okW (NativeRoles.createZero s (sliceUpdateNode input updateInput st sp sr node)) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_slice_update" [out',.big (Int.ofNat (R.handle handle)),.big (Int.ofNat (R.handle update)),
        .jsPtr (R.a startBuffer) 0 startBytes',.big (Int.ofNat starts.length),.jsPtr (R.a stopBuffer) 0 stopBytes',
        .big (Int.ofNat stops.length),.jsPtr (R.a strideBuffer) 0 strideBytes',.big (Int.ofNat strides.length),stream'] =
        okW (NativeRoles.createZero s' (sliceUpdateNode (R.node input) (R.node updateInput) st' sp' sr' node')) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (sliceUpdateRole roles input updateInput starts stops strides)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (sliceUpdateNode input updateInput st sp sr node))
        (NativeRoles.createZero s' (sliceUpdateNode (R.node input) (R.node updateInput) st' sp' sr' node')) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [handle,update] [input,updateInput] handlesLive producer
  obtain ⟨node',hn',hr⟩ := h.node_view support.1 sourceNode
  obtain ⟨updateNode',hu',hur⟩ := h.node_view support.2.1 sourceUpdate
  obtain ⟨st,hs,decodeS⟩ := sourceStarts.decode startsDecodable startBuffer 0
  obtain ⟨st',hs',decodeS'⟩ := targetStarts.decode startsDecodable (R.a startBuffer) 0
  obtain ⟨sp,he,decodeE⟩ := sourceStops.decode stopsDecodable stopBuffer 0
  obtain ⟨sp',he',decodeE'⟩ := targetStops.decode stopsDecodable (R.a stopBuffer) 0
  obtain ⟨sr,hstep,decodeR⟩ := sourceStrides.decode stridesDecodable strideBuffer 0
  obtain ⟨sr',hstep',decodeR'⟩ := targetStrides.decode stridesDecodable (R.a strideBuffer) 0
  have inference := sourceGeometry.infer node.dtype updateNode.dtype hr.source.shape hur.source.shape hs he hstep
  have inference' := targetGeometry.infer node'.dtype updateNode'.dtype hr.target.shape hur.target.shape hs' he' hstep'
  have metadata : Ffi.shapesOf s [input,updateInput] = some [(node.shape,node.dtype),(updateNode.shape,updateNode.dtype)] := by
    simp only [Ffi.shapesOf,sourceNode,sourceUpdate,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node input,R.node updateInput] = some [(node'.shape,node'.dtype),(updateNode'.shape,updateNode'.dtype)] := by
    simp only [Ffi.shapesOf,hn',hu',Option.bind_some,Option.map_some]
  exact ⟨st,st',sp,sp',sr,sr',node',call_sliceUpdate_null s out stream b off handle update input updateInput
      startBuffer starts.length stopBuffer stops.length strideBuffer strides.length startBytes stopBytes strideBytes st sp sr node updateNode
      sourceSlot ha decodeS decodeE decodeR metadata inference,
    call_sliceUpdate_null s' out' stream' (R.a b) off (R.handle handle) (R.handle update) (R.node input) (R.node updateInput)
      (R.a startBuffer) starts.length (R.a stopBuffer) stops.length (R.a strideBuffer) strides.length startBytes' stopBytes' strideBytes'
      st' sp' sr' node' updateNode' targetSlot ha' decodeS' decodeE' decodeR' metadata' inference',
    h.createZeroRoles _ _ (sliceUpdate_created hr hs hs' he he' hstep hstep')
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
