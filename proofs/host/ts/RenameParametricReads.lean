import host.ts.RenameParametricViews
import host.ts.RenameParametricExpressionReturns
import host.ts.RenameParametricPrivate
namespace Host.Ts.Owned.Parametric

theorem FrameR.member_view {NR : NumV → NumV → Prop} {R : Ren} {name : Name}
    {opt : Bool} {f : Frame} (h : FrameR NR R (.e (.member (.str name) opt)) f) :
    f = .e (.member (.str name) opt) := by
  obtain ⟨ef,rfl,he⟩ := h.e_view
  have ht := he.tag_eq
  cases ef <;> simp only [Encode.exprF,treeTag] at ht
  all_goals try contradiction
  case member key optional =>
    cases he with | node tag hs =>
      cases hs with | cons hk hs =>
        cases hs with | cons ho hs =>
          cases ho
          have hk' := KeyR.eq_map hk
          change key = .str name at hk'
          subst key
          rfl

theorem FrameR.private_view {NR : NumV → NumV → Prop} {R : Ren} {brand : Nat} {name : Name}
    {opt : Bool} {f : Frame} (h : FrameR NR R (.e (.priv brand name opt)) f) :
    f = .e (.priv (R.a brand) name opt) := by
  obtain ⟨ef,rfl,he⟩ := h.e_view
  have ht := he.tag_eq
  cases ef <;> simp only [Encode.exprF,treeTag] at ht
  all_goals try contradiction
  case priv b n optional =>
    cases he with | node tag hs =>
      cases hs with | cons hb hs =>
        cases hs with | cons hn hs =>
          cases hs with | cons ho hs =>
            cases hb; cases hn; cases ho
            rfl

/-- The source prototype path determines the target descriptor and original
getter/data dispatch. No target lookup, callee or step is supplied. -/
theorem step_member_lookup_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (name : Name) (p₀ : Option PropV) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .e (.member (.str name) false)::fs₀)
    (path : OrdinaryLookup s₀ name 16 a p₀) :
    ∃ p fs, interpC (step F s₀).run C₀ =
        some (Host.Ts.readProp F {s₀ with stack := fs₀} (.obj a) p₀,C₀) ∧
      interpC (step F s).run C = some (Host.Ts.readProp F {s with stack := fs} (.obj (R.a a)) p,C) ∧
      StateR NR FR R live framed before after old old'
        (Host.Ts.readProp F {s₀ with stack := fs₀} (.obj a) p₀)
        (Host.Ts.readProp F {s with stack := fs} (.obj (R.a a)) p) ∧ OptionRel (PropR NR R) p₀ p := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.member_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨p,hr₀,hr,hs,hp⟩ := step_member_lookup_roles F NR FR R C₀ C live framed before after old old'
    s₀ s h a name p₀ fs₀ fs hc₀ hc hf₀ hf ha path
  exact ⟨p,fs,hr₀,hr,hs,hp⟩

/-- Source private-field ownership derives the mapped receiver/brand and the
actual target property read. Fixed booleans retain their value; handle fields
can carry an additional occurrence annotation in the caller. -/
theorem step_private_read_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a brand : Nat) (name : Name) (o₀ : Obj) (p₀ : PropV) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .e (.priv brand name false)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .ordinary)
    (hp₀ : findPriv brand name o₀.priv = some p₀) :
    ∃ p fs, interpC (step F s₀).run C₀ =
        some (Host.Ts.readProp F {s₀ with stack := fs₀} (.obj a) (some p₀),C₀) ∧
      interpC (step F s).run C = some (Host.Ts.readProp F {s with stack := fs} (.obj (R.a a)) (some p),C) ∧
      StateR NR FR R live framed before after old old'
        (Host.Ts.readProp F {s₀ with stack := fs₀} (.obj a) (some p₀))
        (Host.Ts.readProp F {s with stack := fs} (.obj (R.a a)) (some p)) ∧ PropR NR R p₀ p := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.private_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  have hb : live brand := by
    have hl := h.stackLive
    change listSupport (fun f => treeSupport live (Encode.frame f)) s₀.stack at hl
    rw [hf₀] at hl
    exact hl.1.1.1
  obtain ⟨p,hr₀,hr,hs,hp⟩ := step_private_read_roles F NR FR R C₀ C live framed before after old old'
    s₀ s h a brand name o₀ p₀ fs₀ fs hc₀ hc hf₀ hf ha hb ho₀ hk₀ hp₀
  exact ⟨p,fs,hr₀,hr,hs,hp⟩
end Host.Ts.Owned.Parametric
