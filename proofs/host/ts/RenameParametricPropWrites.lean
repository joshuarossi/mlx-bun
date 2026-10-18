import host.ts.RenameParametricLookup
namespace Host.Ts.Owned.Parametric

theorem PropsR.prepend {NR : NumV → NumV → Prop} {R : Ren} {ps ps' : Props}
    (h : PropsR NR R ps ps') {k k' : PKey} {p p' : PropV} (hk : KeyR NR R k k') (hp : PropR NR R p p') :
    PropsR NR R ((k,p)::ps) ((k',p')::ps') := by
  cases h with | node tag hs => exact .node _ (.cons (.node _ (.cons hk (.cons hp .nil))) hs)

theorem PropsR.set_string {NR : NumV → NumV → Prop} {R : Ren} {ps ps' : Props}
    (h : PropsR NR R ps ps') (name : Name) (p p' : PropV) (hp : PropR NR R p p') :
    PropsR NR R (setPropL (.str name) p ps) (setPropL (.str name) p' ps') := by
  induction ps generalizing ps' with
  | nil =>
    have ht := h.nil_left
    subst ps'
    exact PropsR.prepend (.node _ .nil) (.node _ (.cons (.atom _ _) .nil)) hp
  | cons q rest ih =>
    obtain ⟨k,old⟩ := q
    obtain ⟨k',old',rest',rfl,hk,hold,hr⟩ := h.cons
    have he : keyEq (.str name) k' = keyEq (.str name) k := by rw [hk.eq_map]; exact keyEq_string_map R name k
    change PropsR NR R
      (brec (keyEq (.str name) k) ((k,p)::rest) ((k,old)::setPropL (.str name) p rest))
      (brec (keyEq (.str name) k') ((k',p')::rest') ((k',old')::setPropL (.str name) p' rest'))
    rw [he]
    cases keyEq (.str name) k
    · exact PropsR.prepend (ih hr) hk hold
    · exact PropsR.prepend hr hk hp

theorem ObjectR.with_props {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') (ps ps' : Props) (hp : PropsR NR R ps ps') :
    ObjectR NR R {o with props := ps} {o' with props := ps'} := by
  cases h with | node tag hs =>
    cases hs with | cons hk hs =>
      cases hs with | cons hproto hs =>
        cases hs with | cons hprops hs =>
          exact .node _ (.cons hk (.cons hproto (.cons hp hs)))

theorem props_support_set {live : Nat → Prop} {ps : Props}
    (hs : treeSupport live (Encode.props ps)) (name : Name) (p : PropV)
    (hp : treeSupport live (Encode.prop p)) : treeSupport live (Encode.props (setPropL (.str name) p ps)) := by
  induction ps with
  | nil => exact ⟨⟨⟨True.intro,True.intro⟩,hp,True.intro⟩,True.intro⟩
  | cons q rest ih =>
    obtain ⟨k,old⟩ := q
    change (treeSupport live (Encode.key k) ∧ treeSupport live (Encode.prop old) ∧ True) ∧
      forestSupport live (rest.map fun (k,p) => .node "prop" [Encode.key k,Encode.prop p]) at hs
    change treeSupport live (Encode.props
      (brec (keyEq (.str name) k) ((k,p)::rest) ((k,old)::setPropL (.str name) p rest)))
    cases keyEq (.str name) k
    · exact ⟨hs.1,ih hs.2⟩
    · exact ⟨⟨hs.1.1,hp,True.intro⟩,hs.2⟩

theorem HeapR.setObject {S : Type} {NR : NumV → NumV → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s s' : St S}
    (h : HeapR NR R live framed before after s s') (a : Nat) (o o' : Obj)
    (ha : live a) (hf : ¬ framed a) (hr : ObjectR NR R o o')
    (hl : treeSupport live (Encode.obj o)) (hs : a < 2^64) (ht : R.a a < 2^64) :
    HeapR NR R live framed before after (s.setObj a o) (s'.setObj (R.a a) o') := by
  constructor
  · intro b hb
    by_cases he : b = a
    · subst b
      simp only [St.setObj,PTrie.get_set_u64 _ _ _ hs,PTrie.get_set_u64 _ _ _ ht]
      exact .regular hf (.obj hr) ⟨hl,True.intro⟩
    · have hne : R.a b ≠ R.a a := fun heq => he (h.inj b a hb ha heq)
      simpa only [St.setObj,PTrie.get_set_u64 _ _ _ hs,PTrie.get_set_u64 _ _ _ ht,
        ite_eq_right he,ite_eq_right hne] using h.lookup b hb
  · exact h.sourceBound
  · exact h.targetBound
  · exact h.prefixLive
  · exact h.inj
  · exact h.fresh

theorem StateR.setObject {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s s' : St S}
    (h : StateR NR FR R live framed before after old old' s s') (a : Nat) (o o' : Obj)
    (ha : live a) (hf : ¬ framed a) (hr : ObjectR NR R o o')
    (hl : treeSupport live (Encode.obj o)) (hs : a < 2^64) (ht : R.a a < 2^64) :
    StateR NR FR R live framed before after old old' (s.setObj a o) (s'.setObj (R.a a) o') :=
  ⟨h.heap.setObject a o o' ha hf hr hl hs ht,h.control,h.controlLive,h.stack,h.stackLive,
    h.jobs,h.jobsLive,h.stores,h.storesLive,h.native,h.trace⟩

theorem HeapR.ordinary_notFramed {S : Type} {NR : NumV → NumV → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {s s' : St S}
    (h : HeapR NR R live framed before after s s') (a : Nat) (o : Obj)
    (ha : live a) (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .ordinary) : ¬ framed a := by
  have hr := h.lookup a ha
  rw [ho] at hr
  generalize hh : s'.heap.get (R.a a) = target at hr
  cases hr with
  | regular hf => exact hf
  | framed hf hk₀ => rw [hk] at hk₀; cases hk₀

private theorem step_property_store_eq (F : Ffi) (s : St F.S) (a : Nat) (name : Name)
    (v old prior : Val) (e : Bool) (o : Obj) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .a (.put none (.prop (.obj a) (.str name)) prior)::fs)
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary)
    (hp : findProp (.str name) o.props = some (.data old true e)) :
    step F s = M.pure (({s with stack := fs}.setObj a
      {o with props := setPropL (.str name) (.data v true e) o.props}).ret v) := by
  simp only [St.obj?] at ho
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retA,storeTarget,putV,St.obj?,ho,hk,
    putV.putOrd,hp,Bool.cond_true,retS,M.pure]

/-- The actual writable own-data assignment, including ordered property update
and the frame law for every other selected live heap object. -/
theorem step_property_store_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (oldTrace oldTrace' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after oldTrace oldTrace' s₀ s)
    (a : Nat) (name : Name) (v₀ v prior₀ prior old : Val) (e : Bool) (o₀ : Obj) (fs₀ fs : List Frame)
    (hv : ValueR NR R v₀ v)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .a (.put none (.prop (.obj a) (.str name)) prior₀)::fs₀)
    (hf : s.stack = .a (.put none (.prop (.obj (R.a a)) (.str name)) prior)::fs)
    (ha : live a) (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .ordinary)
    (hp : findProp (.str name) o₀.props = some (.data old true e))
    (hs : a < 2^64) (ht : R.a a < 2^64) :
    ∃ (o : Obj), let t₀ := ({s₀ with stack := fs₀}.setObj a
          {o₀ with props := setPropL (.str name) (.data v₀ true e) o₀.props}).ret v₀
      let t := ({s with stack := fs}.setObj (R.a a)
          {o with props := setPropL (.str name) (.data v true e) o.props}).ret v
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      StateR NR FR R live framed before after oldTrace oldTrace' t₀ t := by
  obtain ⟨o,ho',hr,hol⟩ := h.heap.readOrdinary a o₀ ha ho hk
  obtain ⟨old',hp',hOld⟩ := hr.properties.find_data name old true e hp
  have hfs : ListR (FrameR NR R) fs₀ fs := by
    have hh := h.stack
    rw [hf₀,hf] at hh
    cases hh with | cons ht hs => exact hs
  have hfl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
    have hh := h.stackLive
    rw [hf₀] at hh
    exact hh.2
  have hvl : valueSupport live v₀ := by
    have hh := h.controlLive
    rw [hc₀] at hh
    exact hh.1
  have hpNew : PropR NR R (.data v₀ true e) (.data v true e) :=
    .node _ (.cons (.value hv) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))
  have hprops := hr.properties.set_string name (.data v₀ true e) (.data v true e) hpNew
  have hpSupport := props_support_set hol.2.2.1 name (.data v₀ true e) ⟨hvl,True.intro,True.intro,True.intro⟩
  have hnewSupport : treeSupport live (Encode.obj {o₀ with props := setPropL (.str name) (.data v₀ true e) o₀.props}) :=
    ⟨hol.1,hol.2.1,hpSupport,hol.2.2.2⟩
  have hh := (h.restack hfs hfl).setObject a _ _ ha (h.heap.ordinary_notFramed a o₀ ha ho hk)
    (hr.with_props _ _ hprops) hnewSupport hs ht
  have ho₀ : s₀.obj? a = some o₀ := by simp only [St.obj?,ho]
  have hot : s.obj? (R.a a) = some o := by simp only [St.obj?,ho']
  refine ⟨o,?_,?_,hh.go (.node _ (.cons (.value hv) .nil)) ⟨hvl,True.intro⟩⟩
  · rw [step_property_store_eq F s₀ a name v₀ old prior₀ e o₀ fs₀ hc₀ hf₀ ho₀ hk hp]; rfl
  · rw [step_property_store_eq F s (R.a a) name v old' prior e o fs hc hf hot (hr.ordinary hk) hp']; rfl

end Host.Ts.Owned.Parametric
