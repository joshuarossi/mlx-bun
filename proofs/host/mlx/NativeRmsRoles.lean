import host.mlx.NativeQuantizedRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- The single weight dimension and the input feature dimension share one
exact literal meaning; arbitrary leading dimensions remain unrestricted. -/
def RmsGeometry (input weight : Shape) : Prop :=
  ∃ e : SymE, nthD (constantDimension 0) input (len input-1) = .literal e ∧ weight = [.literal e]

theorem RmsGeometry.subst {input weight : Shape} (h : RmsGeometry input weight) (θ : Nat → SymE) :
    RmsGeometry (Shape.subst θ input) (Shape.subst θ weight) := by
  obtain ⟨e,hi,hw⟩ := h
  refine ⟨e.subst θ,?_,?_⟩
  · have hz : (constantDimension 0).subst θ = constantDimension 0 := rfl
    have mapped := Host.Ts.nthD_map (Dimension.subst θ) (constantDimension 0) input (len input-1)
    rw [hz,hi] at mapped
    simpa only [Shape.subst,Host.Ts.len_map,Dimension.subst] using mapped
  · rw [hw]; rfl

theorem RmsGeometry.infer {ν : Nat → F64} {C : CSrv} {input weight : Shape}
    (h : RmsGeometry input weight) (epsilon : NumV) (dx dw : Nat) {x w : List Dim}
    (hx : Shape.Holds ν C input x) (hw : Shape.Holds ν C weight w)
    (float : isFloat (promote dx dw) = true) :
    infer (.rmsNorm epsilon) [(x,dx),(w,dw)] = M.pure (some (.node x (promote dx dw))) := by
  obtain ⟨e,feature,weight⟩ := h
  have zero := constantDimension_holds ν C 0 (by decide +kernel)
  have last := InferenceRoles.nthD_roles hx zero (len input-1)
  rw [feature] at last
  rw [weight] at hw
  cases hw with
  | cons hn ht =>
    cases ht
    have equal := Dimension.literal_unique hn last
    rw [hx.len_eq] at equal
    rw [equal]
    simp only [Host.Mlx.Ffi.infer,InferenceRoles.dEq_self]
    change (bif true && isFloat (promote dx dw) then M.pure (some (Out.node x (promote dx dw))) else M.pure none) = _
    rw [float]; rfl

def rmsRole (roles : Nat → GraphNode) (x w : Nat) (epsilon : Number) : GraphNode :=
  ⟨(roles x).shape,promote (roles x).dtype (roles w).dtype,some (.rmsNorm epsilon,[x,w])⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def rmsNode (x w : Nat) (epsilon : NumV) (shape : List Dim) (dtype : Nat) : Node :=
  ⟨.rmsNorm epsilon,[x,w],shape,dtype⟩

theorem call_rms_null (s : St) (out stream : Arg) (b off hx hw x w : Nat) (epsilon : NumV)
    (xshape wshape : List Dim) (dx dw : Nat) (nonzero : hw ≠ 0)
    (slot : slotOf out = some (b,off,0))
    (producers : arrIns s [.big (Int.ofNat hx),.big (Int.ofNat hw)] = some [x,w])
    (shapes : shapesOf s [x,w] = some [(xshape,dx),(wshape,dw)])
    (inference : infer (.rmsNorm epsilon) [(xshape,dx),(wshape,dw)] = M.pure (some (.node xshape (promote dx dw)))) :
    Ffi.call s chars!"mlx_fast_rms_norm" [out,.big (Int.ofNat hx),.big (Int.ofNat hw),.num epsilon,stream] =
      okW (createZero s (rmsNode x w epsilon xshape (promote dx dw))) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_fast_rms_norm" = some .rmsNorm := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  cases hw with
  | zero => exact False.elim (nonzero rfl)
  | succ hw =>
    simp only [argNat_big_nat,producers]
    exact opOut_node_zero s out b off (.rmsNorm epsilon) [x,w] _ xshape (promote dx dw) slot shapes inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

theorem rms_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {x w fresh : Nat}
    {xn xn' wn wn' : Node} {epsilon : Number} {eps eps' : NumV}
    (hx : NodeRel roles ν₀ ν C₀ C R boundary x xn xn') (hw : NodeRel roles ν₀ ν C₀ C R boundary w wn wn')
    (he : epsilon.Holds ν₀ C₀ eps) (he' : epsilon.Holds ν C eps') :
    NodeRel (nodeWrite roles fresh (rmsRole roles x w epsilon)) ν₀ ν C₀ C R boundary fresh
      (rmsNode x w eps xn.shape (promote xn.dtype wn.dtype))
      (rmsNode (R.node x) (R.node w) eps' xn'.shape (promote xn'.dtype wn'.dtype)) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (rmsRole roles x w epsilon).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨hx.source.shape,?_,?_⟩
    · simp only [rmsRole,rmsNode,hx.source.dtype,hw.source.dtype]
    · intro p ins eq; cases eq; exact ⟨.rmsNorm he,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (rmsRole roles x w epsilon).Holds ν C R _
    refine ⟨hx.target.shape,?_,?_⟩
    · simp only [rmsRole,rmsNode,hx.target.dtype,hw.target.dtype]
    · intro p ins eq; cases eq; exact ⟨.rmsNorm he',rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem rms_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off hx hw x w : Nat) (xn wn : Node)
    (epsilon : Number) (eps eps' : NumV) (sourceEpsilon : epsilon.Holds ν₀ C₀ eps) (targetEpsilon : epsilon.Holds ν C eps')
    (handlesLive : listSupport H [hx,hw]) (weightNonzero : hw ≠ 0)
    (producers : Ffi.nodesOf s [hx,hw] = some [x,w])
    (sourceX : s.nodes.get x = some xn) (sourceW : s.nodes.get w = some wn)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (geometry : RmsGeometry (roles x).shape (roles w).shape)
    (float : isFloat (promote (roles x).dtype (roles w).dtype) = true)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (xn' wn' : Node),
      Ffi.call s chars!"mlx_fast_rms_norm" [out,.big (Int.ofNat hx),.big (Int.ofNat hw),.num eps,stream] =
        okW (NativeRoles.createZero s (rmsNode x w eps xn.shape (promote xn.dtype wn.dtype))) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_fast_rms_norm" [out',.big (Int.ofNat (R.handle hx)),.big (Int.ofNat (R.handle hw)),.num eps',stream'] =
        okW (NativeRoles.createZero s' (rmsNode (R.node x) (R.node w) eps' xn'.shape (promote xn'.dtype wn'.dtype)))
          status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (rmsRole roles x w epsilon)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (rmsNode x w eps xn.shape (promote xn.dtype wn.dtype)))
        (NativeRoles.createZero s' (rmsNode (R.node x) (R.node w) eps' xn'.shape (promote xn'.dtype wn'.dtype))) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [hx,hw] [x,w] handlesLive producers
  obtain ⟨xn',hx',hrx⟩ := h.node_view support.1 sourceX
  obtain ⟨wn',hw',hrw⟩ := h.node_view support.2.1 sourceW
  have inference := geometry.infer eps xn.dtype wn.dtype hrx.source.shape hrw.source.shape
    (by simpa only [hrx.source.dtype,hrw.source.dtype] using float)
  have inference' := geometry.infer eps' xn'.dtype wn'.dtype hrx.target.shape hrw.target.shape
    (by simpa only [hrx.target.dtype,hrw.target.dtype] using float)
  have metadata : Ffi.shapesOf s [x,w] = some [(xn.shape,xn.dtype),(wn.shape,wn.dtype)] := by
    simp only [Ffi.shapesOf,sourceX,sourceW,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node x,R.node w] = some [(xn'.shape,xn'.dtype),(wn'.shape,wn'.dtype)] := by
    simp only [Ffi.shapesOf,hx',hw',Option.bind_some,Option.map_some]
  exact ⟨xn',wn',call_rms_null s out stream b off hx hw x w eps _ _ _ _ weightNonzero sourceSlot ha metadata inference,
    call_rms_null s' out' stream' (R.a b) off (R.handle hx) (R.handle hw) (R.node x) (R.node w) eps' _ _ _ _
      (h.handle_ne_zero handlesLive.2.1 weightNonzero) targetSlot ha' metadata' inference',
    h.createZeroRoles _ _ (rms_created hrx hrw sourceEpsilon targetEpsilon)
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
