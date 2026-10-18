import host.mlx.NativeQuantizedRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def transposeShape (input : Shape) (axes : List Nat) : Shape := axes.map (nthD (constantDimension 0) input)

theorem transposeShape_holds {ν : Nat → F64} {C : CSrv} {input : Shape} {shape : List Dim}
    (h : Shape.Holds ν C input shape) (axes : List Nat) :
    Shape.Holds ν C (transposeShape input axes) (axes.map (nthD (.lit 0) shape)) := by
  induction axes with
  | nil => exact .nil
  | cons a axes ih =>
    exact .cons (InferenceRoles.nthD_roles h (constantDimension_holds ν C 0 (by decide +kernel)) a) ih

theorem transposeShape_subst (θ : Nat → SymE) (input : Shape) (axes : List Nat) :
    Shape.subst θ (transposeShape input axes) = transposeShape (Shape.subst θ input) axes := by
  have hz : (constantDimension 0).subst θ = constantDimension 0 := rfl
  unfold transposeShape Shape.subst
  rw [List.map_map]
  apply List.map_congr_left
  intro a _
  have mapped := Host.Ts.nthD_map (Dimension.subst θ) (constantDimension 0) input a
  rw [hz] at mapped
  exact mapped.symm

def transposeRole (roles : Nat → GraphNode) (input : Nat) (axes : List Nat) : GraphNode :=
  ⟨transposeShape (roles input).shape axes,(roles input).dtype,some (.transpose axes,[input])⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def transposeNode (input : Nat) (axes : List Nat) (node : Node) : Node :=
  ⟨.transpose axes,[input],axes.map (nthD (.lit 0) node.shape),node.dtype⟩

theorem call_transpose_null (s : St) (out stream : Arg) (b off handle input axisBuffer count : Nat)
    (axisBytes : List Byte) (axes : List Nat) (node : Node)
    (slot : slotOf out = some (b,off,0)) (producer : arrIns s [.big (Int.ofNat handle)] = some [input])
    (decode : (dimsArg (.jsPtr axisBuffer 0 axisBytes) (.big (Int.ofNat count))).bind natsOfDims = some axes)
    (metadata : shapesOf s [input] = some [(node.shape,node.dtype)])
    (guard : (Nat.beq (len axes) (len node.shape) && (List.range (len node.shape)).all (fun a => axes.any (Nat.beq a))) = true) :
    Ffi.call s chars!"mlx_transpose_axes" [out,.big (Int.ofNat handle),.jsPtr axisBuffer 0 axisBytes,.big (Int.ofNat count),stream] =
      okW (createZero s (transposeNode input axes node)) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_transpose_axes" = some .transpose := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  simp only [producer,decode]
  exact opOut_node_zero s out b off (.transpose axes) [input] _ _ node.dtype slot metadata
    (by simp only [infer,guard]; rfl)

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

theorem transpose_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {input fresh : Nat} {node node' : Node}
    (axes : List Nat) (h : NodeRel roles ν₀ ν C₀ C R boundary input node node') :
    NodeRel (nodeWrite roles fresh (transposeRole roles input axes)) ν₀ ν C₀ C R boundary fresh
      (transposeNode input axes node) (transposeNode (R.node input) axes node') := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (transposeRole roles input axes).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨transposeShape_holds h.source.shape axes,h.source.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.transpose axes,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (transposeRole roles input axes).Holds ν C R _
    refine ⟨transposeShape_holds h.target.shape axes,h.target.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.transpose axes,rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem transpose_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off handle input axisBuffer count : Nat)
    (axisBytes : List Byte) (axes : List Nat) (node : Node) (handleLive : H handle)
    (producer : Ffi.nodesOf s [handle] = some [input]) (sourceNode : s.nodes.get input = some node)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (decode : (dimsArg (.jsPtr axisBuffer 0 axisBytes) (.big (Int.ofNat count))).bind natsOfDims = some axes)
    (guard : (Nat.beq (len axes) (len (roles input).shape) &&
      (List.range (len (roles input).shape)).all (fun a => axes.any (Nat.beq a))) = true)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ node',
      Ffi.call s chars!"mlx_transpose_axes" [out,.big (Int.ofNat handle),.jsPtr axisBuffer 0 axisBytes,.big (Int.ofNat count),stream] =
        okW (NativeRoles.createZero s (transposeNode input axes node)) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_transpose_axes" [out',.big (Int.ofNat (R.handle handle)),.jsPtr (R.a axisBuffer) 0 axisBytes,
        .big (Int.ofNat count),stream'] =
        okW (NativeRoles.createZero s' (transposeNode (R.node input) axes node')) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (transposeRole roles input axes)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (transposeNode input axes node))
        (NativeRoles.createZero s' (transposeNode (R.node input) axes node')) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [handle] [input] ⟨handleLive,True.intro⟩ producer
  obtain ⟨node',hn',hr⟩ := h.node_view support.1 sourceNode
  have metadata : Ffi.shapesOf s [input] = some [(node.shape,node.dtype)] := by
    simp only [Ffi.shapesOf,sourceNode,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node input] = some [(node'.shape,node'.dtype)] := by
    simp only [Ffi.shapesOf,hn',Option.bind_some,Option.map_some]
  have decode' : (dimsArg (.jsPtr (R.a axisBuffer) 0 axisBytes) (.big (Int.ofNat count))).bind natsOfDims = some axes := by
    cases count <;> simpa only [dimsArg,argNat_big_nat] using decode
  exact ⟨node',call_transpose_null s out stream b off handle input axisBuffer count axisBytes axes node sourceSlot ha decode metadata
      (by simpa only [← hr.source.shape.len_eq] using guard),
    call_transpose_null s' out' stream' (R.a b) off (R.handle handle) (R.node input) (R.a axisBuffer) count axisBytes axes node'
      targetSlot ha' decode' metadata' (by simpa only [← hr.target.shape.len_eq] using guard),
    h.createZeroRoles _ _ (transpose_created axes hr)
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
