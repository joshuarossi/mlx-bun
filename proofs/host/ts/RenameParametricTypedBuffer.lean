import host.ts.RenameParametricArrayBuffer

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem kind_externalBuffer {NR : NumV → NumV → Prop} {R : Ren}
    {r off count : Nat} {k : Kind}
    (h : TreeR NR R (Encode.kind (.extBuf r off count)) (Encode.kind k)) :
    k = .extBuf (R.region r) off count := by
  have ht := h.tag_eq
  cases k <;> simp only [Encode.kind,treeTag] at ht
  all_goals try contradiction
  case extBuf r' off' count' =>
    cases h with | node tag hs =>
      cases hs with | cons hr hs =>
        cases hs with | cons ho hs =>
          cases hs with | cons hc hs =>
            cases hr; cases ho; cases hc; rfl

theorem HeapR.read_externalBuffer {S : Type} {NR : NumV → NumV → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {s₀ s : St S}
    (h : HeapR NR R live framed before after s₀ s)
    (b : Nat) (bo : Obj) (r off count : Nat) (hb : live b)
    (ho : s₀.heap.get b = some (.obj bo)) (hk : bo.kind = .extBuf r off count) :
    ∃ bo', s.heap.get (R.a b) = some (.obj bo') ∧ bo'.kind = .extBuf (R.region r) off count := by
  have hr := h.lookup b hb
  rw [ho] at hr
  generalize he : s.heap.get (R.a b) = target at hr
  cases hr with
  | regular hf hr hl =>
    cases hr with | obj hr =>
      have hkind := hr.kind
      rw [hk] at hkind
      exact ⟨_,rfl,kind_externalBuffer hkind⟩
  | framed hf hkind => rw [hk] at hkind; cases hkind

theorem StateR.native_construct_view {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (n : Native) (data₀ : List Val) (nt₀ : Val) (args₀ : List Val)
    (hc₀ : s₀.ctl = .construct (.obj a) args₀ nt₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .fn (.native n data₀)) :
    ∃ (o : Obj) (data : List Val) (nt : Val) (args : List Val),
      s.ctl = .construct (.obj (R.a a)) args nt ∧
      s.heap.get (R.a a) = some (.obj o) ∧ o.kind = .fn (.native n data) ∧
      ListR (ValueR NR R) data₀ data ∧ ValueR NR R nt₀ nt ∧
      ListR (ValueR NR R) args₀ args := by
  obtain ⟨callee,args,nt,hc,hcallee,hargs,hnt⟩ := (h.control_view hc₀).construct_view
  have hcallee : callee = .obj (R.a a) := by cases hcallee; rfl
  rw [hcallee] at hc
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have hnf := h.heap.function_notFramed a o₀ _ ha ho₀ hk₀
  obtain ⟨o,ho,hr,_⟩ := h.heap.readObject a o₀ ha hnf ho₀
  have hk := hr.kind
  rw [hk₀] at hk
  obtain ⟨data,hk,hdata⟩ := kind_native hk
  exact ⟨o,data,nt,args,hc,ho,hk,hdata,hnt,hargs⟩

/-- Select one builtin metadata occurrence from the real heap. Its annotation
is retained from initialization; it is not inferred from numeric-role existence. -/
def nativeDataArgument {S : Type} (s : St S) (a i : Nat) : Val :=
  match s.obj? a with
  | some o => match o.kind with
    | .fn (.native _ data) => Host.Ts.arg data i
    | _ => .undef
  | none => .undef

def typedBuffer (k : EltK) (b off count proto : Nat) : HObj :=
  .obj ⟨.typed k b off count,.obj proto,[],[],true⟩

theorem StateR.alloc_typedBuffer {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (k : EltK) (b off count proto : Nat) (hb : live b) (hp : live proto) (hpr : R.a proto = proto)
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc (typedBuffer k b off count proto)).2.ret (.obj s₀.next))
      ((s.alloc (typedBuffer k (R.a b) off count proto)).2.ret (.obj s.next)) := by
  have hproto : ValueR NR R (.obj proto) (.obj proto) := by
    simpa only [hpr] using (ValueR.obj (NR := NR) (R := R) proto)
  have ho : HeapObjectR NR R (typedBuffer k b off count proto) (typedBuffer k (R.a b) off count proto) :=
    .obj (.node _ (.cons (.node _ (.cons (.atom _ _) (.cons (.address b) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))))
      (.cons (.value hproto) (.cons (.node _ .nil) (.cons (.node _ .nil) (.cons (.atom _ _) .nil))))))
  have hol : treeSupport (LiveAfter live s₀.next) (Encode.hobj (typedBuffer k b off count proto)) :=
    ⟨⟨⟨True.intro,Or.inl hb,True.intro,True.intro,True.intro⟩,
      Or.inl hp,True.intro,True.intro,True.intro,True.intro⟩,True.intro⟩
  have hh := h.alloc _ _ ho hol hs ht
  have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  have hv : ValueR NR R (.obj s₀.next) (.obj s.next) := by
    simpa only [hn] using (ValueR.obj (NR := NR) (R := R) s₀.next)
  exact hh.go (.node _ (.cons (.value hv) .nil)) ⟨Or.inr rfl,True.intro⟩

theorem step_construct_typedBuffer_eq (F : Ffi) (s : St F.S) (a b : Nat) (o bo : Obj)
    (nt : Val) (r origin count code proto : Nat) (x y : F64)
    (hc : s.ctl = .construct (.obj a) [.obj b] nt)
    (ho : s.heap.get a = some (.obj o))
    (hk : o.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (hbo : s.heap.get b = some (.obj bo)) (hbk : bo.kind = .extBuf r origin count)
    (hx : F64.toIndex? x = some code) (hy : F64.toIndex? y = some proto) :
    step F s = M.pure
      ((s.alloc (typedBuffer (eltOfCode code) b 0 (count / (eltOfCode code).size) proto)).2.ret (.obj s.next)) := by
  simp only [step,hc,constructStep,St.obj?,ho,hk,constructNative,bufN]
  obtain ⟨kind,pr,props,priv,ext⟩ := bo
  dsimp only at hbk
  subst kind
  simp only [hx,hy,bufN.typedCtor,Host.Ts.arg,nthD,St.obj?,hbo,offsetArg]
  rfl

/-- Native typed-array construction derives the target callee, backing region,
length and fresh view. The two immutable builtin metadata occurrences carry
fixed literal annotations inherited from initialization. -/
theorem step_construct_typedBuffer_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (ν : Nat → F64)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
    (s₀ s : St F.S) (h : StateR NR FR R live framed before after old old' s₀ s)
    (a b : Nat) (o₀ bo₀ : Obj) (nt₀ : Val) (r origin count code proto : Nat) (x y : F64)
    (hc₀ : s₀.ctl = .construct (.obj a) [.obj b] nt₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀))
    (hk₀ : o₀.kind = .fn (.native (.buf .typedCtor) [.num (.lit x),.num (.lit y)]))
    (hbo₀ : s₀.heap.get b = some (.obj bo₀)) (hbk₀ : bo₀.kind = .extBuf r origin count)
    (hx : F64.toIndex? x = some code) (hy : F64.toIndex? y = some proto)
    (codeRole : (Annotated.Value.literal (.lit x)).Holds ν C R (nativeDataArgument s (R.a a) 0))
    (protoRole : (Annotated.Value.literal (.lit y)).Holds ν C R (nativeDataArgument s (R.a a) 1))
    (hp : live proto) (hpr : R.a proto = proto) (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    interpC (step F s₀).run C₀ = some
      ((s₀.alloc (typedBuffer (eltOfCode code) b 0 (count / (eltOfCode code).size) proto)).2.ret (.obj s₀.next),C₀) ∧
    interpC (step F s).run C = some
      ((s.alloc (typedBuffer (eltOfCode code) (R.a b) 0 (count / (eltOfCode code).size) proto)).2.ret (.obj s.next),C) ∧
    StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
      ((s₀.alloc (typedBuffer (eltOfCode code) b 0 (count / (eltOfCode code).size) proto)).2.ret (.obj s₀.next))
      ((s.alloc (typedBuffer (eltOfCode code) (R.a b) 0 (count / (eltOfCode code).size) proto)).2.ret (.obj s.next)) := by
  obtain ⟨o,data,nt,args,hc,ho,hk,hdata,_,hargs⟩ := h.native_construct_view a o₀
    (.buf .typedCtor) [.num (.lit x),.num (.lit y)] nt₀ _ hc₀ ho₀ hk₀
  have hb : live b := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.1.1
  obtain ⟨bo,hbo,hbk⟩ := h.heap.read_externalBuffer b bo₀ r origin count hb hbo₀ hbk₀
  cases hargs with | cons hbuffer hargs =>
    cases hargs
    cases hbuffer
    cases hdata with | cons hcode hdata =>
      cases hdata with | cons hproto hdata =>
        cases hdata
        have hecode := fixed_literal_value codeRole
        have heproto := fixed_literal_value protoRole
        simp only [nativeDataArgument,St.obj?,ho,hk,Host.Ts.arg,nthD] at hecode heproto
        rw [hecode,heproto] at hk
        refine ⟨?_,?_,h.alloc_typedBuffer (eltOfCode code) b 0 (count / (eltOfCode code).size)
          proto hb hp hpr hs ht⟩
        · rw [step_construct_typedBuffer_eq F s₀ a b o₀ bo₀ nt₀ r origin count code proto x y
            hc₀ ho₀ hk₀ hbo₀ hbk₀ hx hy]; rfl
        · rw [step_construct_typedBuffer_eq F s (R.a a) (R.a b) o bo nt (R.region r) origin count
            code proto x y hc ho hk hbo hbk hx hy]; rfl

end Host.Ts.Owned.Parametric
