import host.mlx.NativeProducerInputs
import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- Fixed, source-independent broadcast layouts. Equal dimensions must be
literal occurrences, so equal-valued symbolic references are not conflated. -/
inductive BinaryLayout : Shape → Shape → Shape → Prop where
  | same (shape : Shape) : shape.Literal → BinaryLayout shape shape shape
  | scalarRight (shape : Shape) : BinaryLayout shape [] shape
  | scalarLeft (shape : Shape) : BinaryLayout [] shape shape
  | suffixLeft (suffix leading : Shape) : suffix.Literal → BinaryLayout suffix (leading++suffix) (leading++suffix)
  | suffixRight (suffix leading : Shape) : suffix.Literal → BinaryLayout (leading++suffix) suffix (leading++suffix)

theorem Shape.Literal.subst {roles : Shape} (h : roles.Literal) (θ : Nat → SymE) :
    (Shape.subst θ roles).Literal := by
  induction roles with
  | nil => trivial
  | cons r rs ih =>
    obtain ⟨e,hr⟩ := h.1
    subst hr
    exact ⟨⟨e.subst θ,rfl⟩,ih h.2⟩

theorem BinaryLayout.subst {x y output : Shape} (h : BinaryLayout x y output) (θ : Nat → SymE) :
    BinaryLayout (Shape.subst θ x) (Shape.subst θ y) (Shape.subst θ output) := by
  cases h with
  | same shape literal => exact .same _ (literal.subst θ)
  | scalarRight shape => exact .scalarRight _
  | scalarLeft shape => exact .scalarLeft _
  | @suffixLeft _ leading literal =>
    simpa only [Shape.subst,List.map_append] using BinaryLayout.suffixLeft (Shape.subst θ x) (Shape.subst θ leading) (literal.subst θ)
  | @suffixRight _ leading literal =>
    simpa only [Shape.subst,List.map_append] using BinaryLayout.suffixRight (Shape.subst θ y) (Shape.subst θ leading) (literal.subst θ)

theorem BinaryLayout.infer {ν : Nat → F64} {C : CSrv} {xr yr output : Shape}
    (h : BinaryLayout xr yr output) (op : Name) (dx dy : Nat) {x y : List Dim}
    (hx : Shape.Holds ν C xr x) (hy : Shape.Holds ν C yr y) :
    ∃ shape, infer (.binary op) [(x,dx),(y,dy)] = M.pure (some (.node shape (binaryDtype op dx dy))) ∧
      Shape.Holds ν C output shape := by
  cases h with
  | same _ literal =>
    have equal := Shape.literal_unique literal hx hy
    rw [← equal]
    exact ⟨x,by simp only [Host.Mlx.Ffi.infer,InferenceRoles.broadcast_same]; rfl,hx⟩
  | scalarRight _ =>
    cases hy
    exact ⟨x,by simp only [Host.Mlx.Ffi.infer,InferenceRoles.broadcast_scalar]; rfl,hx⟩
  | scalarLeft _ =>
    cases hx
    have bc : broadcast [] y = M.pure (some y) := by
      change M.pure (some y.reverse.reverse) = _
      rw [List.reverse_reverse]
    exact ⟨y,by simp only [Host.Mlx.Ffi.infer,bc]; rfl,hy⟩
  | @suffixLeft _ leading literal =>
    obtain ⟨a,b,eq,ha,hb⟩ := Shape.split leading xr y hy
    have equal := Shape.literal_unique literal hx hb
    rw [eq,← equal]
    exact ⟨a++x,by simp only [Host.Mlx.Ffi.infer,InferenceRoles.broadcast_suffix]; rfl,ha.append hx⟩
  | @suffixRight _ leading literal =>
    obtain ⟨a,b,eq,ha,hb⟩ := Shape.split leading yr x hx
    have equal := Shape.literal_unique literal hy hb
    rw [eq,← equal]
    exact ⟨a++y,by simp only [Host.Mlx.Ffi.infer,InferenceRoles.broadcast_leading]; rfl,ha.append hy⟩

def binaryRole (roles : Nat → GraphNode) (name : Name) (x y : Nat) (shape : Shape) : GraphNode :=
  ⟨shape,binaryDtype (strip name) (roles x).dtype (roles y).dtype,some (.binary (strip name),[x,y])⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def binaryNode (name : Name) (x y : Nat) (shape : List Dim) (dtype : Nat) : Node :=
  ⟨.binary (strip name),[x,y],shape,dtype⟩

theorem call_binary_null (s : St) (name : Name) (out stream : Arg) (b off hx hy x y : Nat)
    (metadata : List (List Dim × Nat)) (shape : List Dim) (dtype : Nat)
    (symbol : symOf name = some .binary) (slot : slotOf out = some (b,off,0))
    (producers : arrIns s [.big (Int.ofNat hx),.big (Int.ofNat hy)] = some [x,y])
    (shapes : shapesOf s [x,y] = some metadata)
    (inference : infer (.binary (strip name)) metadata = M.pure (some (.node shape dtype))) :
    Ffi.call s name [out,.big (Int.ofNat hx),.big (Int.ofNat hy),stream] =
      okW (createZero s (binaryNode name x y shape dtype)) status0 [u64Write b off s.next] := by
  unfold Ffi.call
  rw [symbol]
  simp only [producers]
  exact opOut_node_zero s out b off (.binary (strip name)) [x,y] _ shape dtype slot shapes inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

theorem binary_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {x y fresh : Nat}
    {xn xn' yn yn' : Node} {shapeRoles : Shape} {shape shape' : List Dim} (name : Name)
    (hx : NodeRel roles ν₀ ν C₀ C R boundary x xn xn') (hy : NodeRel roles ν₀ ν C₀ C R boundary y yn yn')
    (hs : Shape.Holds ν₀ C₀ shapeRoles shape) (ht : Shape.Holds ν C shapeRoles shape') :
    NodeRel (nodeWrite roles fresh (binaryRole roles name x y shapeRoles)) ν₀ ν C₀ C R boundary fresh
      (binaryNode name x y shape (binaryDtype (strip name) xn.dtype yn.dtype))
      (binaryNode name (R.node x) (R.node y) shape' (binaryDtype (strip name) xn'.dtype yn'.dtype)) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (binaryRole roles name x y shapeRoles).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨hs,?_,?_⟩
    · simp only [binaryRole,binaryNode,hx.source.dtype,hy.source.dtype]
    · intro p ins eq; cases eq; exact ⟨.binary (strip name),rfl⟩
  · simp only [nodeWrite,ite_true]
    change (binaryRole roles name x y shapeRoles).Holds ν C R _
    refine ⟨ht,?_,?_⟩
    · simp only [binaryRole,binaryNode,hx.target.dtype,hy.target.dtype]
    · intro p ins eq; cases eq; exact ⟨.binary (strip name),rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem binary_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (name : Name) (out out' stream stream' : Arg) (b off hx hy x y : Nat) (xn yn : Node) (output : Shape)
    (symbol : symOf name = some .binary) (handlesLive : listSupport H [hx,hy])
    (producers : Ffi.nodesOf s [hx,hy] = some [x,y])
    (sourceX : s.nodes.get x = some xn) (sourceY : s.nodes.get y = some yn)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (layout : BinaryLayout (roles x).shape (roles y).shape output)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (shape shape' : List Dim) (xn' yn' : Node),
      Ffi.call s name [out,.big (Int.ofNat hx),.big (Int.ofNat hy),stream] =
        okW (NativeRoles.createZero s (binaryNode name x y shape (binaryDtype (strip name) xn.dtype yn.dtype)))
          status0 [u64Write b off s.next] ∧
      Ffi.call s' name [out',.big (Int.ofNat (R.handle hx)),.big (Int.ofNat (R.handle hy)),stream'] =
        okW (NativeRoles.createZero s' (binaryNode name (R.node x) (R.node y) shape'
          (binaryDtype (strip name) xn'.dtype yn'.dtype))) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (binaryRole roles name x y output)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (binaryNode name x y shape (binaryDtype (strip name) xn.dtype yn.dtype)))
        (NativeRoles.createZero s' (binaryNode name (R.node x) (R.node y) shape'
          (binaryDtype (strip name) xn'.dtype yn'.dtype))) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [hx,hy] [x,y] handlesLive producers
  obtain ⟨xn',hx',hrx⟩ := h.node_view support.1 sourceX
  obtain ⟨yn',hy',hry⟩ := h.node_view support.2.1 sourceY
  obtain ⟨shape,inference,hs⟩ := layout.infer (strip name) xn.dtype yn.dtype hrx.source.shape hry.source.shape
  obtain ⟨shape',inference',hs'⟩ := layout.infer (strip name) xn'.dtype yn'.dtype hrx.target.shape hry.target.shape
  have metadata : Ffi.shapesOf s [x,y] = some [(xn.shape,xn.dtype),(yn.shape,yn.dtype)] := by
    simp only [Ffi.shapesOf,sourceX,sourceY,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node x,R.node y] = some [(xn'.shape,xn'.dtype),(yn'.shape,yn'.dtype)] := by
    simp only [Ffi.shapesOf,hx',hy',Option.bind_some,Option.map_some]
  exact ⟨shape,shape',xn',yn',call_binary_null s name out stream b off hx hy x y _ shape _ symbol sourceSlot ha metadata inference,
    call_binary_null s' name out' stream' (R.a b) off (R.handle hx) (R.handle hy) (R.node x) (R.node y) _ shape' _
      symbol targetSlot ha' metadata' inference',
    h.createZeroRoles _ _ (binary_created name hrx hry hs hs')
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
