import host.mlx.NativeProducerInputs
import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def ropeNode (input dims : Nat) (traditional : Bool) (base : Arg) (scale offset : NumV) (node : Node) : Node :=
  ⟨.rope dims traditional base scale offset,[input],node.shape,node.dtype⟩

theorem call_rope_null (s : St) (out stream : Arg) (b off handle input dims : Nat)
    (dimValue : F64) (traditional : Bool) (base : Arg) (scale offset : NumV) (node : Node)
    (slot : slotOf out = some (b,off,0)) (producer : arrIns s [.big (Int.ofNat handle)] = some [input])
    (dimension : F64.toInt? dimValue = some (Int.ofNat dims)) (positive : 0 < dims)
    (metadata : shapesOf s [input] = some [(node.shape,node.dtype)])
    (rank : Nat.ble 3 (len node.shape) = true) :
    Ffi.call s chars!"mlx_fast_rope"
      [out,.big (Int.ofNat handle),.num (.lit dimValue),.bool traditional,base,.num scale,.num offset,.big 0,stream] =
      okW (createZero s (ropeNode input dims traditional base scale offset node)) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_fast_rope" = some .rope := by decide +kernel
  have pos : decide (0 < Int.ofNat dims) = true := by simp only [Int.ofNat_eq_natCast,Int.natCast_pos]; exact decide_eq_true positive
  have frequencies : argNat (.big 0) = some 0 := rfl
  unfold Ffi.call
  rw [symbol]
  simp only [producer,frequencies,dimension,pos,Bool.cond_true]
  exact opOut_node_zero s out b off (.rope dims traditional base scale offset) [input] _ node.shape node.dtype slot metadata
    (by simp only [infer,rank]; rfl)

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def ropeRole (roles : Nat → GraphNode) (input dims : Nat) (traditional : Bool)
    (base : Owned.Annotated.Tree) (scale offset : Number) : GraphNode :=
  ⟨(roles input).shape,(roles input).dtype,some (.rope dims traditional base scale offset,[input])⟩

theorem rope_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {input fresh : Nat} {node node' : Node}
    (dims : Nat) (traditional : Bool) {base : Owned.Annotated.Tree} {base₀ base' : Arg}
    {scale offset : Number} {scale₀ scale' offset₀ offset' : NumV}
    (h : NodeRel roles ν₀ ν C₀ C R boundary input node node')
    (hb : base.Holds ν₀ C₀ Owned.Annotated.identity (Parametric.arg base₀))
    (hb' : base.Holds ν C R (Parametric.arg base'))
    (hs : scale.Holds ν₀ C₀ scale₀) (hs' : scale.Holds ν C scale')
    (ho : offset.Holds ν₀ C₀ offset₀) (ho' : offset.Holds ν C offset') :
    NodeRel (nodeWrite roles fresh (ropeRole roles input dims traditional base scale offset)) ν₀ ν C₀ C R boundary fresh
      (ropeNode input dims traditional base₀ scale₀ offset₀ node)
      (ropeNode (R.node input) dims traditional base' scale' offset' node') := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (ropeRole roles input dims traditional base scale offset).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨h.source.shape,h.source.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.rope dims traditional hb hs ho,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (ropeRole roles input dims traditional base scale offset).Holds ν C R _
    refine ⟨h.target.shape,h.target.dtype,?_⟩
    intro p ins eq; cases eq; exact ⟨.rope dims traditional hb' hs' ho',rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- RoPE retains fixed meanings for the varying scale and offset, including
their real NumV representation, and for the base argument's ordinary data. -/
theorem rope_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off handle input dims : Nat) (dimValue : F64) (traditional : Bool)
    (base : Owned.Annotated.Tree) (base₀ base' : Arg) (scale offset : Number) (scale₀ scale' offset₀ offset' : NumV) (node : Node)
    (hb : base.Holds ν₀ C₀ Owned.Annotated.identity (Parametric.arg base₀)) (hb' : base.Holds ν C R (Parametric.arg base'))
    (hs : scale.Holds ν₀ C₀ scale₀) (hs' : scale.Holds ν C scale')
    (ho : offset.Holds ν₀ C₀ offset₀) (ho' : offset.Holds ν C offset')
    (handleLive : H handle) (producer : Ffi.nodesOf s [handle] = some [input])
    (sourceNode : s.nodes.get input = some node)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (dimension : F64.toInt? dimValue = some (Int.ofNat dims)) (positive : 0 < dims)
    (rank : Nat.ble 3 (len (roles input).shape) = true)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ node',
      s'.nodes.get (R.node input) = some node' ∧
      Ffi.call s chars!"mlx_fast_rope"
        [out,.big (Int.ofNat handle),.num (.lit dimValue),.bool traditional,base₀,.num scale₀,.num offset₀,.big 0,stream] =
        okW (NativeRoles.createZero s (ropeNode input dims traditional base₀ scale₀ offset₀ node)) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_fast_rope"
        [out',.big (Int.ofNat (R.handle handle)),.num (.lit dimValue),.bool traditional,base',.num scale',.num offset',.big 0,stream'] =
        okW (NativeRoles.createZero s' (ropeNode (R.node input) dims traditional base' scale' offset' node')) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (ropeRole roles input dims traditional base scale offset)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (ropeNode input dims traditional base₀ scale₀ offset₀ node))
        (NativeRoles.createZero s' (ropeNode (R.node input) dims traditional base' scale' offset' node')) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [handle] [input] ⟨handleLive,True.intro⟩ producer
  obtain ⟨node',hn',hr⟩ := h.node_view support.1 sourceNode
  have metadata : Ffi.shapesOf s [input] = some [(node.shape,node.dtype)] := by
    simp only [Ffi.shapesOf,sourceNode,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node input] = some [(node'.shape,node'.dtype)] := by
    simp only [Ffi.shapesOf,hn',Option.bind_some,Option.map_some]
  exact ⟨node',hn',call_rope_null s out stream b off handle input dims dimValue traditional base₀ scale₀ offset₀ node
      sourceSlot ha dimension positive metadata (by simpa only [← hr.source.shape.len_eq] using rank),
    call_rope_null s' out' stream' (R.a b) off (R.handle handle) (R.node input) dims dimValue traditional base' scale' offset' node'
      targetSlot ha' dimension positive metadata' (by simpa only [← hr.target.shape.len_eq] using rank),
    h.createZeroRoles _ _ (rope_created dims traditional hr hb hb' hs hs' ho ho')
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
