import host.mlx.NativeQuantizedRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def attentionShape (query value : Shape) : Shape := setAt query 3 (nthD (constantDimension 0) value 3)

theorem attentionShape_holds {ν : Nat → F64} {C : CSrv} {query value : Shape} {q v : List Dim}
    (hq : Shape.Holds ν C query q) (hv : Shape.Holds ν C value v) :
    Shape.Holds ν C (attentionShape query value) (setAt q 3 (nthD (.lit 0) v 3)) :=
  InferenceRoles.setAt_roles hq (InferenceRoles.nthD_roles hv (constantDimension_holds ν C 0 (by decide +kernel)) 3) 3

theorem attentionShape_subst (θ : Nat → SymE) (query value : Shape) :
    Shape.subst θ (attentionShape query value) = attentionShape (Shape.subst θ query) (Shape.subst θ value) := by
  have hz : (constantDimension 0).subst θ = constantDimension 0 := rfl
  have nth := Host.Ts.nthD_map (Dimension.subst θ) (constantDimension 0) value 3
  rw [hz] at nth
  unfold attentionShape Shape.subst
  rw [← Host.Mlx.Ffi.setAt_map,nth]

def attentionRole (roles : Nat → GraphNode) (q k v : Nat) (scale : Number) (mask : Name) : GraphNode :=
  ⟨attentionShape (roles q).shape (roles v).shape,promote (roles q).dtype (promote (roles k).dtype (roles v).dtype),
    some (.sdpa scale mask,[q,k,v])⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def attentionNode (q k v : Nat) (scale : NumV) (mask : Name) (qn kn vn : Node) : Node :=
  ⟨.sdpa scale mask,[q,k,v],setAt qn.shape 3 (nthD (.lit 0) vn.shape 3),promote qn.dtype (promote kn.dtype vn.dtype)⟩

theorem call_attention_null (s : St) (out stream : Arg) (b off hq hk hv q k v maskBuffer : Nat)
    (scale : NumV) (maskBytes : List Byte) (mask : Name) (force : Bool) (qn kn vn : Node)
    (slot : slotOf out = some (b,off,0))
    (producers : arrIns s [.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv)] = some [q,k,v])
    (decode : cstrArg (.jsPtr maskBuffer 0 maskBytes) = some mask)
    (metadata : shapesOf s [q,k,v] = some [(qn.shape,qn.dtype),(kn.shape,kn.dtype),(vn.shape,vn.dtype)])
    (qrank : len qn.shape = 4) (krank : len kn.shape = 4) (vrank : len vn.shape = 4) :
    Ffi.call s chars!"mlx_fast_scaled_dot_product_attention"
      [out,.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv),.num scale,.jsPtr maskBuffer 0 maskBytes,
        .big 0,.big 0,.bool force,stream] =
      okW (createZero s (attentionNode q k v scale mask qn kn vn)) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_fast_scaled_dot_product_attention" = some .sdpa := by decide +kernel
  have zero : argNat (.big 0) = some 0 := rfl
  unfold Ffi.call
  rw [symbol]
  simp only [producers,decode,zero]
  exact opOut_node_zero s out b off (.sdpa scale mask) [q,k,v] _ _ _ slot metadata
    (by simp only [infer,qrank,krank,vrank]; rfl)

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

theorem attention_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {q k v fresh : Nat} {qn qn' kn kn' vn vn' : Node}
    {scale : Number} {scale₀ scale' : NumV} (mask : Name)
    (hq : NodeRel roles ν₀ ν C₀ C R boundary q qn qn') (hk : NodeRel roles ν₀ ν C₀ C R boundary k kn kn')
    (hv : NodeRel roles ν₀ ν C₀ C R boundary v vn vn')
    (hs : scale.Holds ν₀ C₀ scale₀) (hs' : scale.Holds ν C scale') :
    NodeRel (nodeWrite roles fresh (attentionRole roles q k v scale mask)) ν₀ ν C₀ C R boundary fresh
      (attentionNode q k v scale₀ mask qn kn vn) (attentionNode (R.node q) (R.node k) (R.node v) scale' mask qn' kn' vn') := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (attentionRole roles q k v scale mask).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨attentionShape_holds hq.source.shape hv.source.shape,?_,?_⟩
    · simp only [attentionRole,attentionNode,hq.source.dtype,hk.source.dtype,hv.source.dtype]
    · intro p ins eq; cases eq; exact ⟨.sdpa mask hs,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (attentionRole roles q k v scale mask).Holds ν C R _
    refine ⟨attentionShape_holds hq.target.shape hv.target.shape,?_,?_⟩
    · simp only [attentionRole,attentionNode,hq.target.dtype,hk.target.dtype,hv.target.dtype]
    · intro p ins eq; cases eq; exact ⟨.sdpa mask hs',rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem attention_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off hq hk hv q k v maskBuffer : Nat)
    (maskBytes maskBytes' : List Byte) (mask : Name) (force : Bool) (qn kn vn : Node)
    (scale : Number) (scale₀ scale' : NumV) (hs : scale.Holds ν₀ C₀ scale₀) (hs' : scale.Holds ν C scale')
    (handlesLive : listSupport H [hq,hk,hv]) (producers : Ffi.nodesOf s [hq,hk,hv] = some [q,k,v])
    (sourceQ : s.nodes.get q = some qn) (sourceK : s.nodes.get k = some kn) (sourceV : s.nodes.get v = some vn)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (decode : cstrArg (.jsPtr maskBuffer 0 maskBytes) = some mask)
    (maskRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) maskBytes maskBytes')
    (qrank : len (roles q).shape = 4) (krank : len (roles k).shape = 4) (vrank : len (roles v).shape = 4)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (qn' kn' vn' : Node),
      Ffi.call s chars!"mlx_fast_scaled_dot_product_attention"
        [out,.big (Int.ofNat hq),.big (Int.ofNat hk),.big (Int.ofNat hv),.num scale₀,.jsPtr maskBuffer 0 maskBytes,
          .big 0,.big 0,.bool force,stream] =
        okW (NativeRoles.createZero s (attentionNode q k v scale₀ mask qn kn vn)) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_fast_scaled_dot_product_attention"
        [out',.big (Int.ofNat (R.handle hq)),.big (Int.ofNat (R.handle hk)),.big (Int.ofNat (R.handle hv)),.num scale',
          .jsPtr (R.a maskBuffer) 0 maskBytes',.big 0,.big 0,.bool force,stream'] =
        okW (NativeRoles.createZero s' (attentionNode (R.node q) (R.node k) (R.node v) scale' mask qn' kn' vn'))
          status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (attentionRole roles q k v scale mask)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (attentionNode q k v scale₀ mask qn kn vn))
        (NativeRoles.createZero s' (attentionNode (R.node q) (R.node k) (R.node v) scale' mask qn' kn' vn')) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [hq,hk,hv] [q,k,v] handlesLive producers
  obtain ⟨qn',hq',hrq⟩ := h.node_view support.1 sourceQ
  obtain ⟨kn',hk',hrk⟩ := h.node_view support.2.1 sourceK
  obtain ⟨vn',hv',hrv⟩ := h.node_view support.2.2.1 sourceV
  have metadata : Ffi.shapesOf s [q,k,v] = some [(qn.shape,qn.dtype),(kn.shape,kn.dtype),(vn.shape,vn.dtype)] := by
    simp only [Ffi.shapesOf,sourceQ,sourceK,sourceV,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node q,R.node k,R.node v] = some [(qn'.shape,qn'.dtype),(kn'.shape,kn'.dtype),(vn'.shape,vn'.dtype)] := by
    simp only [Ffi.shapesOf,hq',hk',hv',Option.bind_some,Option.map_some]
  have decode' := (Arguments.cstrArg_roles maskBuffer 0 maskRelated).symm.trans decode
  exact ⟨qn',kn',vn',call_attention_null s out stream b off hq hk hv q k v maskBuffer scale₀ maskBytes mask force qn kn vn sourceSlot ha decode metadata
      (hrq.source.shape.len_eq.symm.trans qrank) (hrk.source.shape.len_eq.symm.trans krank) (hrv.source.shape.len_eq.symm.trans vrank),
    call_attention_null s' out' stream' (R.a b) off (R.handle hq) (R.handle hk) (R.handle hv) (R.node q) (R.node k) (R.node v)
      (R.a maskBuffer) scale' maskBytes' mask force qn' kn' vn' targetSlot ha' decode' metadata'
      (hrq.target.shape.len_eq.symm.trans qrank) (hrk.target.shape.len_eq.symm.trans krank) (hrv.target.shape.len_eq.symm.trans vrank),
    h.createZeroRoles _ _ (attention_created mask hrq hrk hrv hs hs')
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
