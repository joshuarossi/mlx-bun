import host.mlx.NativeSliceGeometry
import host.mlx.NativeSliceUpdateRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

inductive SliceResult where | fresh | alias
def SliceResult.same : SliceResult → Bool | .fresh => false | .alias => true
def sliceNode (input : Nat) (starts stops strides shape : List Dim) (dtype : Nat) : Node :=
  ⟨.slice starts stops strides,[input],shape,dtype⟩
def SliceResult.state (kind : SliceResult) (s : St) (input : Nat) (starts stops strides shape : List Dim) (dtype : Nat) : St :=
  match kind with
  | .fresh => createZero s (sliceNode input starts stops strides shape dtype)
  | .alias => (s.setArr 0 input).2
def SliceResult.support (kind : SliceResult) (fresh : Nat) (N : Nat → Prop) : Nat → Prop :=
  match kind with | .fresh => fun i => i = fresh ∨ N i | .alias => N

theorem opOut_slice_zero (kind : SliceResult) (s : St) (out : Arg) (b off input : Nat)
    (starts stops strides shape : List Dim) (node : Node)
    (slot : slotOf out = some (b,off,0)) (metadata : shapesOf s [input] = some [(node.shape,node.dtype)])
    (inference : infer (.slice starts stops strides) [(node.shape,node.dtype)] =
      M.pure (some (bif kind.same then .same 0 else .node shape node.dtype))) :
    opOut s out (.slice starts stops strides) [input] =
      okW (kind.state s input starts stops strides shape node.dtype) status0 [u64Write b off s.next] := by
  cases kind with
  | fresh => exact opOut_node_zero s out b off (.slice starts stops strides) [input] _ _ _ slot metadata inference
  | alias =>
    unfold opOut
    rw [slot,metadata]
    dsimp only
    rw [inference]
    rfl

theorem call_slice_null (kind : SliceResult) (s : St) (out stream : Arg) (b off handle input : Nat)
    (startBuffer startCount stopBuffer stopCount strideBuffer strideCount : Nat)
    (startBytes stopBytes strideBytes : List Byte) (starts stops strides shape : List Dim) (node : Node)
    (slot : slotOf out = some (b,off,0)) (producer : arrIns s [.big (Int.ofNat handle)] = some [input])
    (hs : dimsArg (.jsPtr startBuffer 0 startBytes) (.big (Int.ofNat startCount)) = some starts)
    (he : dimsArg (.jsPtr stopBuffer 0 stopBytes) (.big (Int.ofNat stopCount)) = some stops)
    (hr : dimsArg (.jsPtr strideBuffer 0 strideBytes) (.big (Int.ofNat strideCount)) = some strides)
    (metadata : shapesOf s [input] = some [(node.shape,node.dtype)])
    (inference : infer (.slice starts stops strides) [(node.shape,node.dtype)] =
      M.pure (some (bif kind.same then .same 0 else .node shape node.dtype))) :
    Ffi.call s chars!"mlx_slice" [out,.big (Int.ofNat handle),.jsPtr startBuffer 0 startBytes,.big (Int.ofNat startCount),
      .jsPtr stopBuffer 0 stopBytes,.big (Int.ofNat stopCount),.jsPtr strideBuffer 0 strideBytes,.big (Int.ofNat strideCount),stream] =
      okW (kind.state s input starts stops strides shape node.dtype) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_slice" = some .slice := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  simp only [producer,hs,he,hr]
  exact opOut_slice_zero kind s out b off input starts stops strides shape node slot metadata inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def sliceRole (roles : Nat → GraphNode) (input : Nat) (starts stops strides output : Shape) : GraphNode :=
  ⟨output,(roles input).dtype,some (.slice starts stops strides,[input])⟩
def sliceOutputRoles (kind : SliceResult) (roles : Nat → GraphNode) (fresh input : Nat)
    (starts stops strides output : Shape) : Nat → GraphNode :=
  match kind with | .fresh => nodeWrite roles fresh (sliceRole roles input starts stops strides output) | .alias => roles

theorem slice_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {input fresh : Nat} {node node' : Node}
    {starts stops strides output : Shape} {st st' sp sp' sr sr' shape shape' : List Dim}
    (h : NodeRel roles ν₀ ν C₀ C R boundary input node node')
    (hs : Shape.Holds ν₀ C₀ starts st) (hs' : Shape.Holds ν C starts st')
    (he : Shape.Holds ν₀ C₀ stops sp) (he' : Shape.Holds ν C stops sp')
    (hr : Shape.Holds ν₀ C₀ strides sr) (hr' : Shape.Holds ν C strides sr')
    (ho : Shape.Holds ν₀ C₀ output shape) (ho' : Shape.Holds ν C output shape') :
    NodeRel (nodeWrite roles fresh (sliceRole roles input starts stops strides output)) ν₀ ν C₀ C R boundary fresh
      (sliceNode input st sp sr shape node.dtype) (sliceNode (R.node input) st' sp' sr' shape' node'.dtype) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (sliceRole roles input starts stops strides output).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨ho,h.source.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.slice hs he hr,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (sliceRole roles input starts stops strides output).Holds ν C R _
    refine ⟨ho',h.target.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.slice hs' he' hr',rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem slice_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (kind : SliceResult) (out out' stream stream' : Arg) (b off handle input startBuffer stopBuffer strideBuffer : Nat)
    (startBytes startBytes' stopBytes stopBytes' strideBytes strideBytes' : List Byte)
    (starts stops strides output : Shape) (node : Node) (handleLive : H handle)
    (producer : Ffi.nodesOf s [handle] = some [input]) (sourceNode : s.nodes.get input = some node)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (sourceStarts : ShapeBuffer.Holds starts ν₀ C₀ startBytes) (targetStarts : ShapeBuffer.Holds starts ν C startBytes')
    (sourceStops : ShapeBuffer.Holds stops ν₀ C₀ stopBytes) (targetStops : ShapeBuffer.Holds stops ν C stopBytes')
    (sourceStrides : ShapeBuffer.Holds strides ν₀ C₀ strideBytes) (targetStrides : ShapeBuffer.Holds strides ν C strideBytes')
    (startsDecodable : starts.Decodable) (stopsDecodable : stops.Decodable) (stridesDecodable : strides.Decodable)
    (sourceGeometry : SliceGeometry ν₀ (roles input).shape output starts stops strides kind.same)
    (targetGeometry : SliceGeometry ν (roles input).shape output starts stops strides kind.same)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (st st' sp sp' sr sr' shape shape' : List Dim) (node' : Node),
      Ffi.call s chars!"mlx_slice" [out,.big (Int.ofNat handle),.jsPtr startBuffer 0 startBytes,.big (Int.ofNat starts.length),
        .jsPtr stopBuffer 0 stopBytes,.big (Int.ofNat stops.length),.jsPtr strideBuffer 0 strideBytes,.big (Int.ofNat strides.length),stream] =
        okW (kind.state s input st sp sr shape node.dtype) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_slice" [out',.big (Int.ofNat (R.handle handle)),.jsPtr (R.a startBuffer) 0 startBytes',.big (Int.ofNat starts.length),
        .jsPtr (R.a stopBuffer) 0 stopBytes',.big (Int.ofNat stops.length),.jsPtr (R.a strideBuffer) 0 strideBytes',
        .big (Int.ofNat strides.length),stream'] =
        okW (kind.state s' (R.node input) st' sp' sr' shape' node'.dtype) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (sliceOutputRoles kind roles s.nnext input starts stops strides output) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (kind.support s.nnext N) tail
        (kind.state s input st sp sr shape node.dtype) (kind.state s' (R.node input) st' sp' sr' shape' node'.dtype) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [handle] [input] ⟨handleLive,True.intro⟩ producer
  obtain ⟨node',hn',hr⟩ := h.node_view support.1 sourceNode
  obtain ⟨st,hs,decodeS⟩ := sourceStarts.decode startsDecodable startBuffer 0
  obtain ⟨st',hs',decodeS'⟩ := targetStarts.decode startsDecodable (R.a startBuffer) 0
  obtain ⟨sp,he,decodeE⟩ := sourceStops.decode stopsDecodable stopBuffer 0
  obtain ⟨sp',he',decodeE'⟩ := targetStops.decode stopsDecodable (R.a stopBuffer) 0
  obtain ⟨sr,hstep,decodeR⟩ := sourceStrides.decode stridesDecodable strideBuffer 0
  obtain ⟨sr',hstep',decodeR'⟩ := targetStrides.decode stridesDecodable (R.a strideBuffer) 0
  obtain ⟨shape,ho,inference⟩ := sourceGeometry.infer node.dtype hr.source.shape hs he hstep
  obtain ⟨shape',ho',inference'⟩ := targetGeometry.infer node'.dtype hr.target.shape hs' he' hstep'
  have metadata : Ffi.shapesOf s [input] = some [(node.shape,node.dtype)] := by
    simp only [Ffi.shapesOf,sourceNode,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node input] = some [(node'.shape,node'.dtype)] := by
    simp only [Ffi.shapesOf,hn',Option.bind_some,Option.map_some]
  refine ⟨st,st',sp,sp',sr,sr',shape,shape',node',
    call_slice_null kind s out stream b off handle input startBuffer starts.length stopBuffer stops.length strideBuffer strides.length
      startBytes stopBytes strideBytes st sp sr shape node sourceSlot ha decodeS decodeE decodeR metadata inference,
    call_slice_null kind s' out' stream' (R.a b) off (R.handle handle) (R.node input)
      (R.a startBuffer) starts.length (R.a stopBuffer) stops.length (R.a strideBuffer) strides.length
      startBytes' stopBytes' strideBytes' st' sp' sr' shape' node' targetSlot ha' decodeS' decodeE' decodeR' metadata' inference',?_⟩
  cases kind with
  | fresh =>
    exact h.createZeroRoles _ _ (slice_created hr hs hs' he he' hstep hstep' ho ho')
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles
  | alias => exact h.setArr_zero input support.1 sourceHandles targetHandles

end Host.Mlx.Ffi.NativeRoles.Live
