import host.mlx.NativeProducerInputs
import host.mlx.NativeShapeBuffer
import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- Dynamic slice inference depends on fixed ranks and dtype, while every
output size keeps its varying fixed dimension annotation. -/
theorem sliceDynamic_infer {ν : Nat → F64} {C : CSrv}
    {sizeRoles inputRoles startRoles : Shape} {sizes input start : List Dim}
    (axes : List Nat) (dtype startDtype : Nat)
    (hs : Shape.Holds ν C sizeRoles sizes) (hi : Shape.Holds ν C inputRoles input)
    (ht : Shape.Holds ν C startRoles start)
    (rank : len sizeRoles = len inputRoles) (integer : isInteger startDtype = true)
    (startRank : Nat.ble (len startRoles) 1 = true)
    (bounds : axes.all (Nat.blt · (len inputRoles)) = true) :
    infer (.sliceDynamic axes sizes) [(input,dtype),(start,startDtype)] = M.pure (some (.node sizes dtype)) := by
  have ranks : Nat.beq (len sizeRoles) (len inputRoles) = true := by rw [rank]; exact Nat.beq_refl _
  simp only [infer,← hs.len_eq,← hi.len_eq,← ht.len_eq,ranks,integer,startRank,bounds,
    Bool.true_and,Bool.cond_true]

def sliceDynamicRole (roles : Nat → GraphNode) (input start : Nat) (axes : List Nat) (sizes : Shape) : GraphNode :=
  ⟨sizes,(roles input).dtype,some (.sliceDynamic axes sizes,[input,start])⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.Annotated

def sliceDynamicNode (input start : Nat) (axes : List Nat) (sizes : List Dim) (dtype : Nat) : Node :=
  ⟨.sliceDynamic axes sizes,[input,start],sizes,dtype⟩

theorem call_sliceDynamic_null (s : St) (out stream : Arg) (b off handle start input startInput : Nat)
    (axisBuffer axisCount sizeBuffer sizeCount : Nat) (axisBytes sizeBytes : List Byte)
    (axes : List Nat) (sizes inputShape startShape : List Dim) (dtype startDtype : Nat)
    (slot : slotOf out = some (b,off,0))
    (ha : arrIns s [.big (Int.ofNat handle),.big (Int.ofNat start)] = some [input,startInput])
    (ax : (dimsArg (.jsPtr axisBuffer 0 axisBytes) (.big (Int.ofNat axisCount))).bind natsOfDims = some axes)
    (sz : dimsArg (.jsPtr sizeBuffer 0 sizeBytes) (.big (Int.ofNat sizeCount)) = some sizes)
    (metadata : shapesOf s [input,startInput] = some [(inputShape,dtype),(startShape,startDtype)])
    (inference : infer (.sliceDynamic axes sizes) [(inputShape,dtype),(startShape,startDtype)] =
      M.pure (some (.node sizes dtype))) :
    Ffi.call s chars!"mlx_slice_dynamic"
      [out,.big (Int.ofNat handle),.big (Int.ofNat start),.jsPtr axisBuffer 0 axisBytes,.big (Int.ofNat axisCount),
        .jsPtr sizeBuffer 0 sizeBytes,.big (Int.ofNat sizeCount),stream] =
      okW (NativeRoles.createZero s (sliceDynamicNode input startInput axes sizes dtype)) status0 [u64Write b off s.next] := by
  have sy : symOf chars!"mlx_slice_dynamic" = some .sliceDynamic := by decide +kernel
  unfold Ffi.call
  rw [sy]
  simp only [ha,ax,sz]
  exact opOut_node_zero s out b off (.sliceDynamic axes sizes) [input,startInput] _ sizes dtype slot metadata inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

theorem sliceDynamic_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {input start fresh : Nat}
    {node node' : Node} {sizeRoles : Shape} {sizes sizes' : List Dim}
    (axes : List Nat) (hr : NodeRel roles ν₀ ν C₀ C R boundary input node node')
    (hs : Shape.Holds ν₀ C₀ sizeRoles sizes) (ht : Shape.Holds ν C sizeRoles sizes') :
    NodeRel (nodeWrite roles fresh (sliceDynamicRole roles input start axes sizeRoles)) ν₀ ν C₀ C R boundary fresh
      (sliceDynamicNode input start axes sizes node.dtype)
      (sliceDynamicNode (R.node input) (R.node start) axes sizes' node'.dtype) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (sliceDynamicRole roles input start axes sizeRoles).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨hs,hr.source.dtype,?_⟩
    intro p ins he
    cases he
    exact ⟨.sliceDynamic axes hs,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (sliceDynamicRole roles input start axes sizeRoles).Holds ν C R _
    refine ⟨ht,hr.target.dtype,?_⟩
    intro p ins he
    cases he
    exact ⟨.sliceDynamic axes ht,rfl⟩
  · intro he
    simp only [nodeWrite,ite_true] at he
    cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Both original dynamic-slice calls follow source producer lookup, fixed
metadata guards and annotated tagged size buffers. Fresh node/handle support
is added, preserving every indexed object and callback payload relation. -/
theorem sliceDynamic_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off handle start input startInput axisBuffer axisCount sizeBuffer : Nat)
    (axisBytes sizeBytes sizeBytes' : List Byte) (axes : List Nat) (sizeRoles : Shape)
    (node startNode : Node) (handleLive : H handle) (startLive : H start)
    (producers : Ffi.nodesOf s [handle,start] = some [input,startInput])
    (sourceNode : s.nodes.get input = some node) (sourceStart : s.nodes.get startInput = some startNode)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (sourceAxes : (dimsArg (.jsPtr axisBuffer 0 axisBytes) (.big (Int.ofNat axisCount))).bind natsOfDims = some axes)
    (sourceSizes : ShapeBuffer.Holds sizeRoles ν₀ C₀ sizeBytes)
    (targetSizes : ShapeBuffer.Holds sizeRoles ν C sizeBytes') (decodable : sizeRoles.Decodable)
    (rank : len sizeRoles = len (roles input).shape) (integer : isInteger (roles startInput).dtype = true)
    (startRank : Nat.ble (len (roles startInput).shape) 1 = true)
    (bounds : axes.all (Nat.blt · (len (roles input).shape)) = true)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ sizes sizes' node' startNode',
      s'.nodes.get (R.node input) = some node' ∧ s'.nodes.get (R.node startInput) = some startNode' ∧
      Ffi.call s chars!"mlx_slice_dynamic"
        [out,.big (Int.ofNat handle),.big (Int.ofNat start),.jsPtr axisBuffer 0 axisBytes,.big (Int.ofNat axisCount),
          .jsPtr sizeBuffer 0 sizeBytes,.big (Int.ofNat sizeRoles.length),stream] =
        okW (NativeRoles.createZero s (sliceDynamicNode input startInput axes sizes node.dtype)) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_slice_dynamic"
        [out',.big (Int.ofNat (R.handle handle)),.big (Int.ofNat (R.handle start)),.jsPtr (R.a axisBuffer) 0 axisBytes,
          .big (Int.ofNat axisCount),.jsPtr (R.a sizeBuffer) 0 sizeBytes',.big (Int.ofNat sizeRoles.length),stream'] =
        okW (NativeRoles.createZero s' (sliceDynamicNode (R.node input) (R.node startInput) axes sizes' node'.dtype))
          status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (sliceDynamicRole roles input startInput axes sizeRoles)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (sliceDynamicNode input startInput axes sizes node.dtype))
        (NativeRoles.createZero s' (sliceDynamicNode (R.node input) (R.node startInput) axes sizes' node'.dtype)) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [handle,start] [input,startInput] ⟨handleLive,startLive,True.intro⟩ producers
  obtain ⟨node',hn',hr⟩ := h.node_view support.1 sourceNode
  obtain ⟨startNode',ht',htr⟩ := h.node_view support.2.1 sourceStart
  obtain ⟨sizes,hs,sz⟩ := sourceSizes.decode decodable sizeBuffer 0
  obtain ⟨sizes',hs',sz'⟩ := targetSizes.decode decodable (R.a sizeBuffer) 0
  have inputDtype := hr.source.dtype
  have startDtype := htr.source.dtype
  have inputDtype' := hr.target.dtype
  have startDtype' := htr.target.dtype
  have inference := sliceDynamic_infer axes node.dtype startNode.dtype hs hr.source.shape htr.source.shape
    rank (by rw [startDtype]; exact integer) startRank bounds
  have inference' := sliceDynamic_infer axes node'.dtype startNode'.dtype hs' hr.target.shape htr.target.shape
    rank (by rw [startDtype']; exact integer) startRank bounds
  have metadata : Ffi.shapesOf s [input,startInput] = some [(node.shape,node.dtype),(startNode.shape,startNode.dtype)] := by
    simp only [Ffi.shapesOf,sourceNode,sourceStart,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node input,R.node startInput] = some [(node'.shape,node'.dtype),(startNode'.shape,startNode'.dtype)] := by
    simp only [Ffi.shapesOf,hn',ht',Option.bind_some,Option.map_some]
  have axes' : (dimsArg (.jsPtr (R.a axisBuffer) 0 axisBytes) (.big (Int.ofNat axisCount))).bind natsOfDims = some axes := by
    cases axisCount <;> simpa only [dimsArg,argNat_big_nat] using sourceAxes
  refine ⟨sizes,sizes',node',startNode',hn',ht',?_,?_,?_⟩
  · exact call_sliceDynamic_null s out stream b off handle start input startInput axisBuffer axisCount sizeBuffer
      sizeRoles.length axisBytes sizeBytes axes sizes node.shape startNode.shape node.dtype startNode.dtype
      sourceSlot ha sourceAxes sz metadata inference
  · exact call_sliceDynamic_null s' out' stream' (R.a b) off (R.handle handle) (R.handle start) (R.node input) (R.node startInput)
      (R.a axisBuffer) axisCount (R.a sizeBuffer) sizeRoles.length axisBytes sizeBytes' axes sizes' node'.shape startNode'.shape
      node'.dtype startNode'.dtype targetSlot ha' axes' sz' metadata' inference'
  · exact h.createZeroRoles _ _ (sliceDynamic_created axes hr hs hs')
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles

end Host.Mlx.Ffi.NativeRoles.Live
