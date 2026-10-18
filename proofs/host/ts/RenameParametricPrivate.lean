import host.ts.RenameParametricPropWrites
namespace Host.Ts.Owned.Parametric

abbrev Privs := List ((Nat × Name) × PropV)
def encodePrivs (ps : Privs) : Tree := Encode.seq (ps.map fun ((b,n),p) => .node "private" [.address b,Encode.atom n,Encode.prop p])
abbrev PrivsR (NR : NumV → NumV → Prop) (R : Ren) (ps ps' : Privs) := TreeR NR R (encodePrivs ps) (encodePrivs ps')

theorem ObjectR.privateFields {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') : PrivsR NR R o.priv o'.priv := by
  cases h with | node tag hs =>
    cases hs with | cons hk hs =>
      cases hs with | cons hproto hs =>
        cases hs with | cons hprops hs =>
          cases hs with | cons hpriv hs => exact hpriv

private theorem PrivsR.nil_left {NR : NumV → NumV → Prop} {R : Ren} {ps : Privs}
    (h : PrivsR NR R [] ps) : ps = [] := by
  cases ps with
  | nil => rfl
  | cons p ps => cases h with | node tag hs => cases hs

private theorem PrivsR.cons {NR : NumV → NumV → Prop} {R : Ren}
    {b : Nat} {n : Name} {p : PropV} {ps ps' : Privs} (h : PrivsR NR R (((b,n),p)::ps) ps') :
    ∃ p' rest, ps' = ((R.a b,n),p')::rest ∧ PropR NR R p p' ∧ PrivsR NR R ps rest := by
  cases ps' with
  | nil => cases h with | node tag hs => cases hs
  | cons q rest =>
    obtain ⟨⟨b',n'⟩,p'⟩ := q
    cases h with | node tag hs =>
      cases hs with | cons hh hs =>
        cases hh with | node tag fields =>
          cases fields with | cons hb fields =>
            cases fields with | cons hn fields =>
              cases fields with | cons hp ht =>
                cases hb
                cases hn
                exact ⟨p',rest,rfl,hp,.node _ hs⟩

/-- Brand equality is transported only on selected live JS addresses. -/
theorem privEq_map (R : Ren) (live : Nat → Prop)
    (inj : ∀ a b, live a → live b → R.a a = R.a b → a = b)
    (b c : Nat) (n m : Name) (hb : live b) (hc : live c) :
    privEq (R.a b) n (R.a c,m) = privEq b n (c,m) := by
  have he : Nat.beq (R.a b) (R.a c) = Nat.beq b c := by
    cases hbc : Nat.beq b c with
    | true => have he := Nat.eq_of_beq_eq_true hbc; subst c; simp
    | false => cases hmap : Nat.beq (R.a b) (R.a c) with
      | false => rfl
      | true => have he := inj b c hb hc (Nat.eq_of_beq_eq_true hmap); subst c; simp at hbc
  simp only [privEq,he]

theorem PrivsR.find {NR : NumV → NumV → Prop} {R : Ren} {live : Nat → Prop} {ps ps' : Privs}
    (h : PrivsR NR R ps ps') (hs : treeSupport live (encodePrivs ps))
    (inj : ∀ a b, live a → live b → R.a a = R.a b → a = b)
    (brand : Nat) (name : Name) (hb : live brand) :
    OptionRel (PropR NR R) (findPriv brand name ps) (findPriv (R.a brand) name ps') := by
  induction ps generalizing ps' with
  | nil => have := h.nil_left; subst ps'; exact .none
  | cons q rest ih =>
    obtain ⟨⟨b,n⟩,p⟩ := q
    obtain ⟨p',rest',rfl,hp,hr⟩ := h.cons
    change (live b ∧ True ∧ treeSupport live (Encode.prop p) ∧ True) ∧
      forestSupport live (rest.map fun ((b,n),p) => .node "private" [.address b,Encode.atom n,Encode.prop p]) at hs
    simp only [findPriv]
    rw [privEq_map R live inj brand b name n hb hs.1.1]
    cases privEq brand name (b,n)
    · exact ih hr hs.2
    · exact .some hp

private theorem private_support {live : Nat → Prop} {ps : Privs} {p : PropV}
    (hs : treeSupport live (encodePrivs ps)) (brand : Nat) (name : Name)
    (hp : findPriv brand name ps = some p) : treeSupport live (Encode.prop p) := by
  induction ps with
  | nil => cases hp
  | cons q rest ih =>
    obtain ⟨⟨b,n⟩,v⟩ := q
    change (live b ∧ True ∧ treeSupport live (Encode.prop v) ∧ True) ∧
      forestSupport live (rest.map fun ((b,n),p) => .node "private" [.address b,Encode.atom n,Encode.prop p]) at hs
    change (bif privEq brand name (b,n) then some v else findPriv brand name rest) = some p at hp
    cases hc : privEq brand name (b,n) <;> rw [hc] at hp
    · exact ih hs.2 hp
    · obtain rfl := Option.some.inj hp
      exact hs.1.2.2.1

private theorem step_private_read_eq (F : Ffi) (s : St F.S) (a brand : Nat) (name : Name)
    (o : Obj) (p : PropV) (fs : List Frame)
    (hc : s.ctl = .ret (.obj a)) (hf : s.stack = .e (.priv brand name false)::fs)
    (ho : s.heap.get a = some (.obj o)) (hp : findPriv brand name o.priv = some p) :
    step F s = M.pure (Host.Ts.readProp F {s with stack := fs} (.obj a) (some p)) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,Bool.false_and,Bool.cond_false,
    privGetV,St.obj?,ho,hp,M.pure]

/-- Private reads use live brand injectivity and derive the target descriptor
from the source object's private fields, including owned native handle roles. -/
theorem step_private_read_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a brand : Nat) (name : Name) (o₀ : Obj) (p₀ : PropV) (fs₀ fs : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hc : s.ctl = .ret (.obj (R.a a)))
    (hf₀ : s₀.stack = .e (.priv brand name false)::fs₀)
    (hf : s.stack = .e (.priv (R.a brand) name false)::fs)
    (ha : live a) (hb : live brand) (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .ordinary)
    (hp : findPriv brand name o₀.priv = some p₀) :
    ∃ p, interpC (step F s₀).run C₀ =
        some (Host.Ts.readProp F {s₀ with stack := fs₀} (.obj a) (some p₀),C₀) ∧
      interpC (step F s).run C =
        some (Host.Ts.readProp F {s with stack := fs} (.obj (R.a a)) (some p),C) ∧
      StateR NR FR R live framed before after old old'
        (Host.Ts.readProp F {s₀ with stack := fs₀} (.obj a) (some p₀))
        (Host.Ts.readProp F {s with stack := fs} (.obj (R.a a)) (some p)) ∧ PropR NR R p₀ p := by
  obtain ⟨o,ho',hr,hol⟩ := h.heap.readOrdinary a o₀ ha ho hk
  have hpriv := hr.privateFields.find hol.2.2.2.1 h.heap.inj brand name hb
  rw [hp] at hpriv
  generalize hh : findPriv (R.a brand) name o.priv = found at hpriv
  cases hpriv with
  | some hpRel =>
    have hfs : ListR (FrameR NR R) fs₀ fs := by
      have ht := h.stack
      rw [hf₀,hf] at ht
      cases ht with | cons ht hs => exact hs
    have hfl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
      have ht := h.stackLive
      rw [hf₀] at ht
      exact ht.2
    have hpl := private_support hol.2.2.2.1 brand name hp
    refine ⟨_,?_,?_,(h.restack hfs hfl).readProp F (.obj a) (.obj (R.a a)) (.obj a) ha _ _ hpRel hpl,hpRel⟩
    · rw [step_private_read_eq F s₀ a brand name o₀ p₀ fs₀ hc₀ hf₀ ho hp]; rfl
    · rw [step_private_read_eq F s (R.a a) (R.a brand) name o _ fs hc hf ho' hh]; rfl

private theorem PrivsR.prepend {NR : NumV → NumV → Prop} {R : Ren} {ps ps' : Privs}
    (h : PrivsR NR R ps ps') (brand : Nat) (name : Name) (p p' : PropV) (hp : PropR NR R p p') :
    PrivsR NR R (((brand,name),p)::ps) (((R.a brand,name),p')::ps') := by
  cases h with | node tag hs =>
    exact .node _ (.cons (.node _ (.cons (.address brand) (.cons (.atom _ _) (.cons hp .nil)))) hs)

theorem PrivsR.set {NR : NumV → NumV → Prop} {R : Ren} {live : Nat → Prop} {ps ps' : Privs}
    (h : PrivsR NR R ps ps') (hs : treeSupport live (encodePrivs ps))
    (inj : ∀ a b, live a → live b → R.a a = R.a b → a = b)
    (brand : Nat) (name : Name) (hb : live brand) (p p' : PropV) (hp : PropR NR R p p') :
    PrivsR NR R (setPrivL brand name p ps) (setPrivL (R.a brand) name p' ps') := by
  induction ps generalizing ps' with
  | nil =>
    have := h.nil_left
    subst ps'
    exact PrivsR.prepend (.node _ .nil) brand name p p' hp
  | cons q rest ih =>
    obtain ⟨⟨b,n⟩,old⟩ := q
    obtain ⟨old',rest',rfl,hold,hr⟩ := h.cons
    change (live b ∧ True ∧ treeSupport live (Encode.prop old) ∧ True) ∧
      forestSupport live (rest.map fun ((b,n),p) => .node "private" [.address b,Encode.atom n,Encode.prop p]) at hs
    change PrivsR NR R
      (bif privEq brand name (b,n) then ((b,n),p)::rest else ((b,n),old)::setPrivL brand name p rest)
      (bif privEq (R.a brand) name (R.a b,n) then ((R.a b,n),p')::rest' else ((R.a b,n),old')::setPrivL (R.a brand) name p' rest')
    rw [privEq_map R live inj brand b name n hb hs.1.1]
    cases privEq brand name (b,n)
    · exact PrivsR.prepend (ih hr hs.2) b n old old' hold
    · exact PrivsR.prepend hr b n p p' hp

private theorem private_support_set {live : Nat → Prop} {ps : Privs}
    (hs : treeSupport live (encodePrivs ps)) (brand : Nat) (name : Name) (hb : live brand)
    (p : PropV) (hp : treeSupport live (Encode.prop p)) :
    treeSupport live (encodePrivs (setPrivL brand name p ps)) := by
  induction ps with
  | nil => exact ⟨⟨hb,True.intro,hp,True.intro⟩,True.intro⟩
  | cons q rest ih =>
    obtain ⟨⟨b,n⟩,old⟩ := q
    change (live b ∧ True ∧ treeSupport live (Encode.prop old) ∧ True) ∧
      forestSupport live (rest.map fun ((b,n),p) => .node "private" [.address b,Encode.atom n,Encode.prop p]) at hs
    change treeSupport live (encodePrivs
      (bif privEq brand name (b,n) then ((b,n),p)::rest else ((b,n),old)::setPrivL brand name p rest))
    cases privEq brand name (b,n)
    · exact ⟨hs.1,ih hs.2⟩
    · exact ⟨⟨hs.1.1,True.intro,hp,True.intro⟩,hs.2⟩

theorem ObjectR.with_private {NR : NumV → NumV → Prop} {R : Ren} {o o' : Obj}
    (h : ObjectR NR R o o') (ps ps' : Privs) (hp : PrivsR NR R ps ps') :
    ObjectR NR R {o with priv := ps} {o' with priv := ps'} := by
  cases h with | node tag hs =>
    cases hs with | cons hk hs =>
      cases hs with | cons hproto hs =>
        cases hs with | cons hprops hs =>
          cases hs with | cons hpriv hs =>
            exact .node _ (.cons hk (.cons hproto (.cons hprops (.cons hp hs))))

private theorem step_private_store_eq (F : Ffi) (s : St F.S) (a brand : Nat) (name : Name)
    (v old prior : Val) (e : Bool) (o : Obj) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .a (.put none (.priv (.obj a) brand name) prior)::fs)
    (ho : s.heap.get a = some (.obj o)) (hp : findPriv brand name o.priv = some (.data old true e)) :
    step F s = M.pure (({s with stack := fs}.setObj a
      {o with priv := setPrivL brand name (.data v true e) o.priv}).ret v) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retA,storeTarget,privPutV,St.obj?,ho,hp,retS,M.pure]

/-- Actual private writable field assignment, including native handle roles and
fixed brand/name identity. Every other live heap slot is preserved. -/
theorem step_private_store_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (oldTrace oldTrace' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after oldTrace oldTrace' s₀ s)
    (a brand : Nat) (name : Name) (v₀ v prior₀ prior old : Val) (e : Bool) (o₀ : Obj) (fs₀ fs : List Frame)
    (hv : ValueR NR R v₀ v)
    (hc₀ : s₀.ctl = .ret v₀) (hc : s.ctl = .ret v)
    (hf₀ : s₀.stack = .a (.put none (.priv (.obj a) brand name) prior₀)::fs₀)
    (hf : s.stack = .a (.put none (.priv (.obj (R.a a)) (R.a brand) name) prior)::fs)
    (ha : live a) (hb : live brand) (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .ordinary)
    (hp : findPriv brand name o₀.priv = some (.data old true e))
    (hs : a < 2^64) (ht : R.a a < 2^64) :
    ∃ (o : Obj), let t₀ := ({s₀ with stack := fs₀}.setObj a
          {o₀ with priv := setPrivL brand name (.data v₀ true e) o₀.priv}).ret v₀
      let t := ({s with stack := fs}.setObj (R.a a)
          {o with priv := setPrivL (R.a brand) name (.data v true e) o.priv}).ret v
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      StateR NR FR R live framed before after oldTrace oldTrace' t₀ t := by
  obtain ⟨o,ho',hr,hol⟩ := h.heap.readOrdinary a o₀ ha ho hk
  have hpriv := hr.privateFields.find hol.2.2.2.1 h.heap.inj brand name hb
  rw [hp] at hpriv
  generalize hh : findPriv (R.a brand) name o.priv = found at hpriv
  cases hpriv with
  | some hpRel =>
    obtain ⟨old',rfl,hOld⟩ := hpRel.data
    have hfs : ListR (FrameR NR R) fs₀ fs := by
      have hst := h.stack
      rw [hf₀,hf] at hst
      cases hst with | cons ht hs => exact hs
    have hfl : listSupport (fun f => treeSupport live (Encode.frame f)) fs₀ := by
      have hst := h.stackLive
      rw [hf₀] at hst
      exact hst.2
    have hvl : valueSupport live v₀ := by
      have hc := h.controlLive
      rw [hc₀] at hc
      exact hc.1
    have hpNew : PropR NR R (.data v₀ true e) (.data v true e) :=
      .node _ (.cons (.value hv) (.cons (.atom _ _) (.cons (.atom _ _) .nil)))
    have hprivNew := hr.privateFields.set hol.2.2.2.1 h.heap.inj brand name hb _ _ hpNew
    have hprivSupport := private_support_set hol.2.2.2.1 brand name hb (.data v₀ true e)
      ⟨hvl,True.intro,True.intro,True.intro⟩
    have hnewSupport : treeSupport live (Encode.obj {o₀ with priv := setPrivL brand name (.data v₀ true e) o₀.priv}) :=
      ⟨hol.1,hol.2.1,hol.2.2.1,hprivSupport,hol.2.2.2.2⟩
    have hsrel := (h.restack hfs hfl).setObject a _ _ ha (h.heap.ordinary_notFramed a o₀ ha ho hk)
      (hr.with_private _ _ hprivNew) hnewSupport hs ht
    refine ⟨o,?_,?_,hsrel.go (.node _ (.cons (.value hv) .nil)) ⟨hvl,True.intro⟩⟩
    · rw [step_private_store_eq F s₀ a brand name v₀ old prior₀ e o₀ fs₀ hc₀ hf₀ ho hp]; rfl
    · rw [step_private_store_eq F s (R.a a) (R.a brand) name v old' prior e o fs hc hf ho' hh]; rfl

end Host.Ts.Owned.Parametric
