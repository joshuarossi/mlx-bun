import host.ts.RenameParametricTypedElements
import host.mlx.NativeShapeRead

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem kind_typedBuffer {NR : NumV → NumV → Prop} {R : Ren}
    {ek : EltK} {b off count : Nat} {k : Kind}
    (h : TreeR NR R (Encode.kind (.typed ek b off count)) (Encode.kind k)) :
    k = .typed ek (R.a b) off count := by
  have ht := h.tag_eq
  cases k <;> simp only [Encode.kind,treeTag] at ht
  all_goals try contradiction
  case typed ek' b' off' count' =>
    cases h with | node tag hs =>
      cases hs with | cons he hs =>
        cases hs with | cons hb hs =>
          cases hs with | cons ho hs =>
            cases hs with | cons hc hs =>
              cases he; cases hb; cases ho; cases hc; rfl

theorem HeapR.read_typedBuffer {S : Type} {NR : NumV → NumV → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (h : HeapR NR R live framed before after s₀ s)
    (a b off count : Nat) (o : Obj) (k : EltK) (ha : live a)
    (ho : s₀.heap.get a = some (.obj o)) (hk : o.kind = .typed k b off count) :
    ∃ o', s.heap.get (R.a a) = some (.obj o') ∧ o'.kind = .typed k (R.a b) off count ∧ live b := by
  have hr := h.lookup a ha
  rw [ho] at hr
  generalize he : s.heap.get (R.a a) = target at hr
  cases hr with
  | regular hf hr hl =>
    cases hr with | obj hr =>
      have hkind := hr.kind
      rw [hk] at hkind
      have hkl : treeSupport live (Encode.kind (.typed k b off count)) := by simpa only [hk] using hl.1.1
      exact ⟨_,rfl,kind_typedBuffer hkind,hkl.2.1⟩
  | framed hf hkind => rw [hk] at hkind; cases hkind

theorem FrameR.l_view {NR : NumV → NumV → Prop} {R : Ren}
    {lf : LitF} {f : Frame} (h : FrameR NR R (.l lf) f) :
    ∃ lf', f = .l lf' ∧ TreeR NR R (Encode.litF lf) (Encode.litF lf') := by
  have ht := h.tag_eq
  cases f <;> simp only [Encode.frame,treeTag] at ht
  all_goals try contradiction
  case l lf' =>
    cases h with | node tag hs =>
      cases hs with | cons hh hs => exact ⟨lf',rfl,hh⟩

theorem FrameR.emptySpread_view {NR : NumV → NumV → Prop} {R : Ren}
    {env : Env} {f : Frame} (h : FrameR NR R (.l (.spread [] [] env)) f) :
    f = .l (.spread [] [] (R.env env)) := by
  obtain ⟨lf',rfl,hh⟩ := h.l_view
  have ht := hh.tag_eq
  cases lf' <;> simp only [Encode.litF,treeTag] at ht
  all_goals try contradiction
  case spread acc rest env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hacc hs =>
        cases hs with | cons hrest hs =>
          cases hs with | cons henv hs =>
            have hv := vals_roles_of hacc
            cases hv
            cases hrest
            obtain rfl := env_eq_map henv
            rfl

def valueArray (vs : List Val) : HObj := .obj ⟨.array vs,.obj aArrayProto,[],[],true⟩

theorem vals_support_encode {live : Nat → Prop} (vs : List Val)
    (h : listSupport (valueSupport live) vs) : treeSupport live (Encode.vals vs) := by
  induction vs with
  | nil => exact True.intro
  | cons v vs ih => exact ⟨h.1,ih h.2⟩

theorem StateR.alloc_valueArray {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (vs₀ vs : List Val) (hvs : ListR (ValueR NR R) vs₀ vs) (hvl : listSupport (valueSupport live) vs₀)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc (valueArray vs₀)).2.ret (.obj s₀.next))
      ((s.alloc (valueArray vs)).2.ret (.obj s.next)) := by
  have hproto : ValueR NR R (.obj aArrayProto) (.obj aArrayProto) := by
    simpa only [hpr] using (ValueR.obj (NR := NR) (R := R) aArrayProto)
  have ho : HeapObjectR NR R (valueArray vs₀) (valueArray vs) :=
    .obj (.node _ (.cons (.node _ (.cons (vals_roles hvs) .nil))
      (.cons (.value hproto) (.cons (.node _ .nil) (.cons (.node _ .nil) (.cons (.atom _ _) .nil))))))
  have hol : treeSupport (LiveAfter live s₀.next) (Encode.hobj (valueArray vs₀)) :=
    ⟨⟨⟨treeSupport_mono (fun _ ha => Or.inl ha) _ (vals_support_encode vs₀ hvl),True.intro⟩,
      Or.inl hp,True.intro,True.intro,True.intro,True.intro⟩,True.intro⟩
  have hh := h.alloc _ _ ho hol hs ht
  have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have hv : ValueR NR R (.obj s₀.next) (.obj s.next) := by
    simpa only [hn] using (ValueR.obj (NR := NR) (R := R) s₀.next)
  exact hh.go (.node _ (.cons (.value hv) .nil)) ⟨Or.inr rfl,True.intro⟩

theorem step_spread_final_eq (F : Ffi) (s : St F.S) (v : Val) (env : Env) (fs : List Frame)
    (vs : List Val) (hc : s.ctl = .ret v) (hf : s.stack = .l (.spread [] [] env)::fs)
    (he : elemsOf F {s with stack := fs} v = M.pure (some vs)) :
    step F s = M.pure (({s with stack := fs}.alloc (valueArray vs)).2.ret (.obj s.next)) := by
  have he' : elemsOf F {s with ctl := .ret v, stack := fs} v = M.pure (some vs) := by
    simpa only [hc] using he
  simp only [step,hc,stepRet,hf,retStep,retL,spreadElems,he']
  change arrayNext F {s with ctl := .ret v, stack := fs} (vs.reverse ++ []) [] env = _
  simp only [List.append_nil,arrayNext,List.reverse_reverse]
  rfl

end Host.Ts.Owned.Parametric

namespace Host.Load.Parametric
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi
open Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The real shape-spread step is derived from the host heap and the annotated
native graph. Native ownership determines the target node and every shape
read; the original interpreter then enumerates and allocates the JS array. -/
theorem step_shape_spread_fields_frame_from_source (FR : Ren → LSt → LSt → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (roles : Nat → GraphNode) (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      ObjRel H N tail s₀.ffi.mlx s.ffi.mlx)
    (a b handle : Nat) (o bo : Host.Ts.Obj) (node : Node) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .l (.spread [] [] env)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o)) (hk₀ : o.kind = .typed .i32 b 0 (len node.shape))
    (hbo₀ : s₀.heap.get b = some (.obj bo)) (hbk₀ : bo.kind = .extBuf (4*handle) 0 (len node.shape*4))
    (hnode : s₀.ffi.mlx.node? handle = some node) (hhandle : H handle)
    (region : R.region (4*handle) = 4*R.handle handle)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    ∃ result,
      interpC (step ffi s₀).run C₀ = some
        (({s₀ with stack := fs₀}.alloc (valueArray (node.shape.map (fun d : Dim => Val.num d.num)))).2.ret (.obj s₀.next),C₀) ∧
      interpC (step ffi s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old'
        (({s₀ with stack := fs₀}.alloc (valueArray (node.shape.map (fun d : Dim => Val.num d.num)))).2.ret (.obj s₀.next)) result ∧
      ∃ i node', s₀.ffi.mlx.arrs.get handle = some i ∧
        NodeRel roles ν₀ ν C₀ C R boundary i node node' ∧
        result.heap.get (R.a s₀.next) = some (valueArray (node'.shape.map (fun d : Dim => Val.num d.num))) ∧
        ∀ a, a < s.next → result.heap.get a = s.heap.get a := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  have hv : v = .obj (R.a a) := by cases hv; rfl
  rw [hv] at hc
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  rw [hfr.emptySpread_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o',ho',hk',hb⟩ := h.heap.read_typedBuffer a b 0 (len node.shape) o .i32 ha ho₀ hk₀
  obtain ⟨bo',hbo',hbk'⟩ := h.heap.read_externalBuffer b bo (4*handle) 0 (len node.shape*4) hb hbo₀ hbk₀
  obtain ⟨i,node',_,hnode',hnodeRel,hshape,hlen⟩ := Annotated.node_shape native handle hhandle node hnode
  rw [region,←hlen] at hbk'
  rw [←hlen] at hk'
  have he₀ := elemsOf_shape {s₀ with stack := fs₀} a b handle o bo node ho₀ hk₀ hbo₀ hbk₀ hnode
  have he := elemsOf_shape {s with stack := fs} (R.a a) (R.a b) (R.handle handle) o' bo' node'
    ho' hk' hbo' hbk' hnode'
  have hvalues : ListR (Host.Ts.Owned.Parametric.ValueR (NumberRoles ν₀ ν C₀ C) R)
      (node.shape.map (fun d => Val.num d.num)) (node'.shape.map (fun d => Val.num d.num)) := by
    generalize hds : node.shape = ds at hshape ⊢
    generalize hds' : node'.shape = ds' at hshape ⊢
    clear hds hds'
    induction hshape with
    | nil => exact .nil
    | cons hd hr ih => exact .cons (.num hd) ih
  have hlive : listSupport (valueSupport live) (node.shape.map (fun d => Val.num d.num)) := by
    generalize node.shape = ds
    induction ds with
    | nil => exact True.intro
    | cons d ds ih => exact ⟨True.intro,ih⟩
  have hfsLive := h.stackLive
  rw [hf₀] at hfsLive
  have hpost := (h.restack htail hfsLive.2).alloc_valueArray _ _ hvalues hlive hp hpr hs ht
  refine ⟨_,?_,?_,hpost,i,node',by assumption,hnodeRel,?_,?_⟩
  · rw [step_spread_final_eq ffi s₀ (.obj a) env fs₀ _ hc₀ hf₀ he₀]; rfl
  · rw [step_spread_final_eq ffi s (.obj (R.a a)) (R.env env) fs _ hc hf he]; rfl

  · have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
    simp only [St.alloc,St.ret,hn,PTrie.get_set_u64 _ _ _ ht,ite_true]

  · intro a oldAddress
    exact alloc_ret_heap_below {s with stack := fs} _ _ ht a oldAddress

theorem step_shape_spread_fields_from_source (FR : Ren → LSt → LSt → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (roles : Nat → GraphNode) (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      ObjRel H N tail s₀.ffi.mlx s.ffi.mlx)
    (a b handle : Nat) (o bo : Host.Ts.Obj) (node : Node) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .l (.spread [] [] env)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o)) (hk₀ : o.kind = .typed .i32 b 0 (len node.shape))
    (hbo₀ : s₀.heap.get b = some (.obj bo)) (hbk₀ : bo.kind = .extBuf (4*handle) 0 (len node.shape*4))
    (hnode : s₀.ffi.mlx.node? handle = some node) (hhandle : H handle)
    (region : R.region (4*handle) = 4*R.handle handle)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    ∃ result,
      interpC (step ffi s₀).run C₀ = some
        (({s₀ with stack := fs₀}.alloc (valueArray (node.shape.map (fun d : Dim => Val.num d.num)))).2.ret (.obj s₀.next),C₀) ∧
      interpC (step ffi s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old'
        (({s₀ with stack := fs₀}.alloc (valueArray (node.shape.map (fun d : Dim => Val.num d.num)))).2.ret (.obj s₀.next)) result ∧
      ∃ i node', s₀.ffi.mlx.arrs.get handle = some i ∧
        NodeRel roles ν₀ ν C₀ C R boundary i node node' ∧
        result.heap.get (R.a s₀.next) = some (valueArray (node'.shape.map (fun d : Dim => Val.num d.num))) := by
  obtain ⟨result,hr₀,hr,hpost,i,node',hi,relation,heap,_⟩ := step_shape_spread_fields_frame_from_source FR R ν₀ ν C₀ C
    live framed before after old old' s₀ s h roles ObjRel boundary H N tail native
    a b handle o bo node env fs₀ hc₀ hf₀ ho₀ hk₀ hbo₀ hbk₀ hnode hhandle region hp hpr hs ht
  exact ⟨result,hr₀,hr,hpost,i,node',hi,relation,heap⟩

theorem step_shape_spread_from_source (FR : Ren → LSt → LSt → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (roles : Nat → GraphNode) (ObjRel : Nat → Host.Mlx.Ffi.Obj → Host.Mlx.Ffi.Obj → Prop)
    (boundary H N : Nat → Prop) (tail : List NumV)
    (native : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      ObjRel H N tail s₀.ffi.mlx s.ffi.mlx)
    (a b handle : Nat) (o bo : Host.Ts.Obj) (node : Node) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .l (.spread [] [] env)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o)) (hk₀ : o.kind = .typed .i32 b 0 (len node.shape))
    (hbo₀ : s₀.heap.get b = some (.obj bo)) (hbk₀ : bo.kind = .extBuf (4*handle) 0 (len node.shape*4))
    (hnode : s₀.ffi.mlx.node? handle = some node) (hhandle : H handle)
    (region : R.region (4*handle) = 4*R.handle handle)
    (hp : live aArrayProto) (hpr : R.a aArrayProto = aArrayProto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    ∃ result,
      interpC (step ffi s₀).run C₀ = some
        (({s₀ with stack := fs₀}.alloc (valueArray (node.shape.map (fun d : Dim => Val.num d.num)))).2.ret (.obj s₀.next),C₀) ∧
      interpC (step ffi s).run C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C) FR R (LiveAfter live s₀.next) framed before after old old'
        (({s₀ with stack := fs₀}.alloc (valueArray (node.shape.map (fun d : Dim => Val.num d.num)))).2.ret (.obj s₀.next)) result := by
  obtain ⟨result,hr₀,hr,hpost,_⟩ := step_shape_spread_fields_from_source FR R ν₀ ν C₀ C live framed
    before after old old' s₀ s h roles ObjRel boundary H N tail native a b handle o bo node env fs₀
    hc₀ hf₀ ho₀ hk₀ hbo₀ hbk₀ hnode hhandle region hp hpr hs ht
  exact ⟨result,hr₀,hr,hpost⟩

end Host.Load.Parametric
