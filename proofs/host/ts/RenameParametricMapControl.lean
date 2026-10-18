import host.ts.RenameParametricArithmeticStep
import host.ts.RenameParametricStatements

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem ClosureLive.grow (live : Nat → Prop) (start : Nat) (arrow : Bool) (home : Val) (f : Func) :
    ∀ a, live a → ClosureLive live start arrow home f a := by
  intro a ha
  unfold ClosureLive
  split
  · exact CellsLive.grow live start (paramNames f) a ha
  · cases home
    all_goals first
      | exact CellsLive.grow _ _ _ a (Or.inl ha)
      | exact CellsLive.grow _ _ _ a (Or.inl (Or.inl ha))

theorem StateR.target_next_add {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live live' framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s t₀ t : St S} (h : StateR NR FR R live framed before after old old' s₀ s)
    (ht : StateR NR FR R live' framed before after old old' t₀ t) (k : Nat) (hn : t₀.next = s₀.next+k) :
    t.next = s.next+k := by
  have hs := h.heap.fresh k
  have ht := ht.heap.fresh 0
  simp only [Nat.add_zero,hn] at ht
  exact ht.symm.trans hs

theorem FrameR.if_view {NR : NumV → NumV → Prop} {R : Ren}
    {yes : Stmt} {no : Option Stmt} {env : Env} {f : Frame}
    (h : FrameR NR R (.s (.if_ yes no env)) f) : f = .s (.if_ yes no (R.env env)) := by
  obtain ⟨sf,rfl,hh⟩ := h.s_view
  have ht := hh.tag_eq
  cases sf <;> simp only [Encode.stmtF,treeTag] at ht
  all_goals try contradiction
  case if_ yes' no' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hy hs =>
        cases hs with | cons hn hs =>
          cases hs with | cons he hs =>
            cases hy; cases hn
            obtain rfl := env_eq_map he
            rfl

theorem step_if_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (b : Bool) (yes : Stmt) (no : Option Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.bool b)) (hf₀ : s₀.stack = .s (.if_ yes no env)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with ctl := branchCtl b yes no env,stack := fs₀},C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        {s₀ with ctl := branchCtl b yes no env,stack := fs₀} result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.if_view] at hf
  exact ⟨_,step_if_bool_roles F NR FR R C₀ C live framed before after old old' s₀ s h
    b yes no env fs₀ fs hc₀ hc hf₀ hf⟩

theorem step_undefined_sne_eq (F : Ffi) (s : St F.S) (fs : List Frame)
    (hc : s.ctl = .ret .undef) (hf : s.stack = .e (.binR .sne .undef)::fs) :
    step F s = M.pure ({s with stack := fs}.ret (.bool false)) := by
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,binOp,strictEq,M.bind,M.pure,retS]
  rfl

/-- The actual map prelude's absent-thisArg guard is decided from related
undefined operands. It does not require a numeric or target-branch premise. -/
theorem step_undefined_sne_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret .undef) (hf₀ : s₀.stack = .e (.binR .sne .undef)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with stack := fs₀}.ret (.bool false),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' ({s₀ with stack := fs₀}.ret (.bool false)) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  obtain ⟨left,hfe,hl⟩ := hfr.binR_view
  cases hl
  rw [hfe] at hf
  have hfl := h.stackLive
  rw [hf₀] at hfl
  refine ⟨({s with stack := fs}.ret (.bool false)),?_,?_,?_⟩
  · rw [step_undefined_sne_eq F s₀ fs₀ hc₀ hf₀]; rfl
  · rw [step_undefined_sne_eq F s fs hc hf]; rfl
  · simpa only [St.ret,St.go] using
      (h.restack hfs hfl.2).go (c := .ret (.bool false)) (c' := .ret (.bool false))
        (.node _ (.cons (.value (.bool false)) .nil)) ⟨True.intro,True.intro⟩

theorem step_this_eq (F : Ffi) (s : St F.S) (env : Env) (a : Nat) (v : Val)
    (hc : s.ctl = .ev .this env) (he : lookupEnv nThis env = some a)
    (hv : s.heap.get a = some (.cell (some v))) : step F s = M.pure (s.ret v) := by
  have hcell : s.cell? a = some (some v) := by simp only [St.cell?,hv]
  simp only [step,hc,evStep,readVar,he,hcell,retS]

theorem step_this_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (env : Env) (a : Nat) (v₀ : Val)
    (hc₀ : s₀.ctl = .ev .this env) (he₀ : lookupEnv nThis env = some a)
    (hv₀ : s₀.heap.get a = some (.cell (some v₀))) :
    ∃ v, interpC (step F s₀).run C₀ = some (s₀.ret v₀,C₀) ∧
      interpC (step F s).run C = some (s.ret v,C) ∧
      StateR NR FR R live framed before after old old' (s₀.ret v₀) (s.ret v) ∧ ValueR NR R v₀ v := by
  have hc := (h.control_view hc₀).ev_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have ha := env_lookup_live nThis env a hl.2.1 he₀
  obtain ⟨v,hv,hr,hs⟩ := h.heap.readCell a v₀ ha hv₀
  have he : lookupEnv nThis (R.env env) = some (R.a a) := by rw [lookupEnv_map,he₀]; rfl
  refine ⟨v,?_,?_,h.go (.node _ (.cons (.value hr) .nil)) ⟨hs,True.intro⟩,hr⟩
  · rw [step_this_eq F s₀ env a v₀ hc₀ he₀ hv₀]; rfl
  · rw [step_this_eq F s (R.env env) (R.a a) v hc he hv]; rfl

end Host.Ts.Owned.Parametric
