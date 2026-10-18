import host.ts.RenameParametricProps
namespace Host.Ts.Owned.Parametric

/-- A source prototype path records heap observations, not a target computation
or a machine-step simulation. Every object traversed here is ordinary. -/
inductive OrdinaryLookup {S : Type} (s : St S) (name : Name) : Nat → Nat → Option PropV → Prop where
  | hit (fuel a : Nat) (o : Obj) (p : PropV) :
      s.heap.get a = some (.obj o) → o.kind = .ordinary → findProp (.str name) o.props = some p →
      OrdinaryLookup s name (fuel+1) a (some p)
  | next (fuel a b : Nat) (o : Obj) {p : Option PropV} :
      s.heap.get a = some (.obj o) → o.kind = .ordinary → findProp (.str name) o.props = none →
      o.proto = .obj b → OrdinaryLookup s name fuel b p → OrdinaryLookup s name (fuel+1) a p
  | stop (fuel a : Nat) (o : Obj) :
      s.heap.get a = some (.obj o) → o.kind = .ordinary → findProp (.str name) o.props = none →
      o.proto = .null → OrdinaryLookup s name (fuel+1) a none

private theorem ValueR.obj_target {NR : NumV → NumV → Prop} {R : Ren} {a : Nat} {v : Val}
    (h : ValueR NR R (.obj a) v) : v = .obj (R.a a) := by cases h; rfl
private theorem ValueR.null_target {NR : NumV → NumV → Prop} {R : Ren} {v : Val}
    (h : ValueR NR R .null v) : v = .null := by cases h; rfl

theorem ObjectR.prototype {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') : ValueR NR R o.proto o'.proto := by
  cases h with | node tag hs =>
    cases hs with | cons hk hs =>
      cases hs with | cons hp hs =>
        cases hp with | value hp => exact hp

private theorem lookup_hit_eq (F : Ffi) (s : St F.S) (name : Name) (fuel a : Nat) (o : Obj) (p : PropV)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (hp : findProp (.str name) o.props = some p) :
    getChain F s (.str name) (fuel+1) a = M.pure (some p) := by
  have ho' : s.obj? a = some o := by simp only [St.obj?,ho]
  rw [getChain,ho']
  simp only [ownGet,hk,hp]
  rfl

private theorem lookup_next_eq (F : Ffi) (s : St F.S) (name : Name) (fuel a b : Nat) (o : Obj)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (hp : findProp (.str name) o.props = none) (hproto : o.proto = .obj b) :
    getChain F s (.str name) (fuel+1) a = getChain F s (.str name) fuel b := by
  have ho' : s.obj? a = some o := by simp only [St.obj?,ho]
  rw [getChain,ho']
  simp only [ownGet,hk,hp,hproto]
  rfl

private theorem lookup_stop_eq (F : Ffi) (s : St F.S) (name : Name) (fuel a : Nat) (o : Obj)
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary)
    (hp : findProp (.str name) o.props = none) (hproto : o.proto = .null) :
    getChain F s (.str name) (fuel+1) a = M.pure none := by
  have ho' : s.obj? a = some o := by simp only [St.obj?,ho]
  rw [getChain,ho']
  simp only [ownGet,hk,hp,hproto]
  rfl

/-- Transport the real prototype traversal. Live support proves each next
prototype address is in the heap relation; ordered properties determine the
related descriptor, including an accessor getter. -/
theorem OrdinaryLookup.transport (F : Ffi) {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s₀ s : St F.S}
    (heap : HeapR NR R live framed before after s₀ s)
    (name : Name)
    {fuel a : Nat} {p₀ : Option PropV} (path : OrdinaryLookup s₀ name fuel a p₀) (ha : live a) :
    ∃ p, getChain F s₀ (.str name) fuel a = M.pure p₀ ∧
      getChain F s (.str name) fuel (R.a a) = M.pure p ∧
      OptionRel (PropR NR R) p₀ p ∧
      (∀ q, p₀ = some q → treeSupport live (Encode.prop q)) := by
  induction path with
  | hit fuel a o₀ p₀ ho hk hp =>
    obtain ⟨o,ho',hr,hl⟩ := heap.readOrdinary a o₀ ha ho hk
    have hprops := hr.properties.find_string name
    rw [hp] at hprops
    generalize hh : findProp (.str name) o.props = p at hprops
    cases hprops with
    | some hprop =>
      refine ⟨_,lookup_hit_eq F s₀ name fuel a o₀ p₀ ho hk hp,
        lookup_hit_eq F s name fuel (R.a a) o _ ho' (hr.ordinary hk) hh,.some hprop,?_⟩
      intro q hq
      obtain rfl := Option.some.inj hq
      exact PropsR.support_find hl.2.2.1 name hp
  | next fuel a b o₀ ho hk hp hproto path ih =>
    obtain ⟨o,ho',hr,hl⟩ := heap.readOrdinary a o₀ ha ho hk
    have hb : live b := by have hv := hl.2.1; rw [hproto] at hv; exact hv
    obtain ⟨p,hs₀,hs,hrel,hsupport⟩ := ih hb
    have hprops := hr.properties.find_string name
    rw [hp] at hprops
    generalize hh : findProp (.str name) o.props = found at hprops
    cases hprops with
    | none =>
      have hproto' := hr.prototype
      rw [hproto] at hproto'
      have hb' : o.proto = .obj (R.a b) := hproto'.obj_target
      refine ⟨p,?_,?_,hrel,hsupport⟩
      · rw [lookup_next_eq F s₀ name fuel a b o₀ ho hk hp hproto]; exact hs₀
      · rw [lookup_next_eq F s name fuel (R.a a) (R.a b) o ho' (hr.ordinary hk) hh hb']; exact hs
  | stop fuel a o₀ ho hk hp hproto =>
    obtain ⟨o,ho',hr,hl⟩ := heap.readOrdinary a o₀ ha ho hk
    have hprops := hr.properties.find_string name
    rw [hp] at hprops
    generalize hh : findProp (.str name) o.props = found at hprops
    cases hprops with
    | none =>
      have hproto' := hr.prototype
      rw [hproto] at hproto'
      have hn : o.proto = .null := hproto'.null_target
      refine ⟨none,lookup_stop_eq F s₀ name fuel a o₀ ho hk hp hproto,
        lookup_stop_eq F s name fuel (R.a a) o ho' (hr.ordinary hk) hh hn,.none,?_⟩
      intro q hq
      cases hq

theorem OrdinaryLookup.withStack {S : Type} {s : St S} {name : Name} {fuel a : Nat} {p : Option PropV}
    (h : OrdinaryLookup s name fuel a p) (fs : List Frame) :
    OrdinaryLookup {s with stack := fs} name fuel a p := by
  induction h with
  | hit fuel a o p ho hk hp => exact .hit fuel a o p ho hk hp
  | next fuel a b o ho hk hp ht path ih => exact .next fuel a b o ho hk hp ht ih
  | stop fuel a o ho hk hp ht => exact .stop fuel a o ho hk hp ht

private theorem step_member_lookup_eq (F : Ffi) (s : St F.S) (a : Nat) (name : Name)
    (fs : List Frame) (p : Option PropV)
    (hc : s.ctl = .ret (.obj a)) (hf : s.stack = .e (.member (.str name) false)::fs)
    (hl : getChain F {s with stack := fs} (.str name) 16 a = M.pure p) :
    step F s = M.pure (Host.Ts.readProp F {s with stack := fs} (.obj a) p) := by
  cases s with | mk heap next ctl stack aux =>
    change ctl = .ret (.obj a) at hc
    change stack = .e (.member (.str name) false)::fs at hf
    subst ctl
    subst stack
    funext β k
    simp only [step,stepRet,retStep,retE,Bool.false_and,Bool.cond_false,getV,lookup]
    rw [hl]
    rfl

/-- Full source member transition, including prototype traversal and either a
returned data value, an absent value, or an actual getter call. -/
theorem step_member_lookup_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (name : Name) (p₀ : Option PropV) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hc : s.ctl = .ret (.obj (R.a a)))
    (hf₀ : s₀.stack = .e (.member (.str name) false)::fs₀)
    (hf : s.stack = .e (.member (.str name) false)::fs)
    (ha : live a) (path : OrdinaryLookup s₀ name 16 a p₀) :
    ∃ p, interpC (step F s₀).run C₀ =
        some (Host.Ts.readProp F {s₀ with stack := fs₀} (.obj a) p₀,C₀) ∧
      interpC (step F s).run C =
        some (Host.Ts.readProp F {s with stack := fs} (.obj (R.a a)) p,C) ∧
      StateR NR FR R live framed before after old old'
        (Host.Ts.readProp F {s₀ with stack := fs₀} (.obj a) p₀)
        (Host.Ts.readProp F {s with stack := fs} (.obj (R.a a)) p) ∧
      OptionRel (PropR NR R) p₀ p := by
  have hfs : ListR (FrameR NR R) fs₀ fs := by
    have hh := h.stack
    rw [hf₀,hf] at hh
    cases hh with | cons ht hs => exact hs
  have hfl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
    have hh := h.stackLive
    rw [hf₀] at hh
    exact hh.2
  have hr := h.restack hfs hfl
  obtain ⟨p,hget₀,hget,hp,hpl⟩ := (path.withStack fs₀).transport F hr.heap name ha
  refine ⟨p,?_,?_,?_,hp⟩
  · rw [step_member_lookup_eq F s₀ a name fs₀ p₀ hc₀ hf₀ hget₀]; rfl
  · rw [step_member_lookup_eq F s (R.a a) name fs p hc hf hget]; rfl
  · cases hp with
    | none => exact hr.go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
    | some hp => exact hr.readProp F (.obj a) (.obj (R.a a)) (.obj a) ha _ _ hp (hpl _ rfl)

end Host.Ts.Owned.Parametric
