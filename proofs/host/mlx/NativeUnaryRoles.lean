import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def unaryNode (name : Name) (input : Nat) (node : Node) : Node :=
  ⟨.unary (strip name),[input],node.shape,unaryDtype (strip name) node.dtype⟩

theorem call_unary_null (s : St) (name : Name) (out stream : Arg) (b off handle input : Nat) (node : Node)
    (hs : symOf name = some .unary) (ha : s.nodeId? handle = some input)
    (hn : s.nodes.get input = some node) (ho : slotOf out = some (b,off,0)) :
    Ffi.call s name [out,.big (Int.ofNat handle),stream] =
      okW (createZero s (unaryNode name input node)) status0 [u64Write b off s.next] := by
  have hi : arrIns s [.big (Int.ofNat handle)] = some [input] := by
    simp only [arrIns,List.mapM_cons,List.mapM_nil,argNat_big_nat,Option.bind_some,ha]
    rfl
  have hm : shapesOf s [input] = some [(node.shape,node.dtype)] := by
    simp only [shapesOf,hn,Option.bind_some,Option.map_some]
  unfold Ffi.call
  rw [hs]
  simp only [hi]
  exact opOut_node_zero s out b off (.unary (strip name)) [input] _ node.shape
    (unaryDtype (strip name) node.dtype) ho hm rfl

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def unaryRole (roles : Nat → GraphNode) (name : Name) (input : Nat) : GraphNode :=
  ⟨(roles input).shape,unaryDtype (strip name) (roles input).dtype,some (.unary (strip name),[input])⟩

theorem unary_created {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {boundary : Nat → Prop} {input : Nat} {node node' : Node}
    (name : Name) (fresh : Nat) (h : NodeRel roles ν₀ ν C₀ C R boundary input node node') :
    NodeRel (nodeWrite roles fresh (unaryRole roles name input)) ν₀ ν C₀ C R boundary fresh
      (unaryNode name input node) (unaryNode name (R.node input) node') := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (unaryRole roles name input).Holds ν₀ C₀ Owned.Annotated.identity (unaryNode name input node)
    refine ⟨h.source.shape,congrArg (unaryDtype (strip name)) h.source.dtype,?_⟩
    intro p ins he
    cases he
    exact ⟨.unary _,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (unaryRole roles name input).Holds ν C R (unaryNode name (R.node input) node')
    refine ⟨h.target.shape,congrArg (unaryDtype (strip name)) h.target.dtype,?_⟩
    intro p ins he
    cases he
    exact ⟨.unary _,rfl⟩
  · intro he
    simp only [nodeWrite,ite_true] at he
    change (unaryRole roles name input).graph = none at he
    cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.Annotated
open Host.Ts.Owned.Parametric

/-- Unary graph output keeps the fixed input dimension meanings, including
symbolic dimensions. Only its fresh node and array handle extend support. -/
theorem unary_null {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (name : Name) (out out' stream stream' : Arg) (b off handle input : Nat) (node : Node)
    (hs : symOf name = some .unary) (handleLive : H handle)
    (ha : s.nodeId? handle = some input) (hn : s.nodes.get input = some node)
    (ho : slotOf out = some (b,off,0)) (ho' : slotOf out' = some (R.a b,off,0))
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ node', s'.nodes.get (R.node input) = some node' ∧
      Ffi.call s name [out,.big (Int.ofNat handle),stream] =
        okW (NativeRoles.createZero s (unaryNode name input node)) status0 [u64Write b off s.next] ∧
      Ffi.call s' name [out',.big (Int.ofNat (R.handle handle)),stream'] =
        okW (NativeRoles.createZero s' (unaryNode name (R.node input) node')) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (unaryRole roles name input)) ν₀ ν C₀ C R boundary) ObjRel
        (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (unaryNode name input node)) (NativeRoles.createZero s' (unaryNode name (R.node input) node')) := by
  have nonzero : handle ≠ 0 := by
    intro he
    subst handle
    simp only [St.nodeId?,Nat.beq_refl,Bool.cond_true] at ha
    cases ha
  have hb : Nat.beq handle 0 = false := by
    cases he : Nat.beq handle 0
    · rfl
    · exact False.elim (nonzero (Nat.eq_of_beq_eq_true he))
  have sourceArray : s.arrs.get handle = some input := by
    simpa only [St.nodeId?,hb,Bool.cond_false] using ha
  have inputLive : N input := h.arrLive handle input handleLive sourceArray
  obtain ⟨node',hn',hr⟩ := h.node_view inputLive hn
  have ha' : s'.nodeId? (R.handle handle) = some (R.node input) := by
    have hv := h.arrs handle handleLive
    have ht : Nat.beq (R.handle handle) 0 = false := by
      cases he : Nat.beq (R.handle handle) 0
      · rfl
      · exact False.elim (h.handle_ne_zero handleLive nonzero (Nat.eq_of_beq_eq_true he))
    simpa only [St.nodeId?,ht,Bool.cond_false,sourceArray,Option.map_some] using hv
  exact ⟨node',hn',call_unary_null s name out stream b off handle input node hs ha hn ho,
    call_unary_null s' name out' stream' (R.a b) off (R.handle handle) (R.node input) node' hs ha' hn' ho',
    h.createZeroRoles _ _ (unary_created name s.nnext hr)
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
