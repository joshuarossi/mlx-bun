import host.ts.RenameParametricTryEntry
import host.ts.RenameParametricReturnStep
import host.ts.RenameParameterEffects
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem FrameR.try_view {NR : NumV → NumV → Prop} {R : Ren}
    {handler : Option (Option Pat × List Stmt)} {fin : Option (List Stmt)} {env : Env} {f : Frame}
    (h : FrameR NR R (.s (.try_ handler fin env)) f) :
    f = .s (.try_ handler fin (R.env env)) := by
  obtain ⟨st,rfl,hh⟩ := h.s_view
  have ht := hh.tag_eq
  cases st <;> simp only [Encode.stmtF,treeTag] at ht
  all_goals try contradiction
  case try_ handler' fin' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hh hs =>
        cases hs with | cons hfin hs =>
          cases hs with | cons he hs =>
            cases hh; cases hfin
            obtain rfl := env_eq_map he
            rfl

theorem step_return_finally_eq (F : Ffi) (s : St F.S) (v : Val)
    (handler : Option (Option Pat × List Stmt)) (fin : List Stmt) (env : Env) (fs : List Frame)
    (hc : s.ctl = .abr (.ret v)) (hf : s.stack = .s (.try_ handler (some fin) env)::fs) :
    step F s = M.pure (enterBlock ({s with stack := fs}.push (.s (.finally_ (.abrupt (.ret v))))) fin env) := by
  simp only [step,hc,stepAbr,hf,abrStep,abrSt,finOrResume]

/-- Returning through a try executes the actual finalizer, preserving the
pending return completion under the real block/lexical allocation. -/
theorem step_return_finally_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (handler : Option (Option Pat × List Stmt)) (fin : List Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .abr (.ret v₀)) (hf₀ : s₀.stack = .s (.try_ handler (some fin) env)::fs₀)
    (inert : noInitFunctions fin = true)
    (sourceBound : s₀.next+(blockNames fin).length ≤ 2^64)
    (targetBound : s.next+(blockNames fin).length ≤ 2^64) :
    ∃ v fs, interpC (step F s₀).run C₀ =
        some (enterBlock ({s₀ with stack := fs₀}.push (.s (.finally_ (.abrupt (.ret v₀))))) fin env,C₀) ∧
      interpC (step F s).run C =
        some (enterBlock ({s with stack := fs}.push (.s (.finally_ (.abrupt (.ret v))))) fin (R.env env),C) ∧
      StateR NR FR R (CellsLive live s₀.next (blockNames fin)) framed before after old old'
        (enterBlock ({s₀ with stack := fs₀}.push (.s (.finally_ (.abrupt (.ret v₀))))) fin env)
        (enterBlock ({s with stack := fs}.push (.s (.finally_ (.abrupt (.ret v))))) fin (R.env env)) := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).returnAbrupt_view
  obtain ⟨f,fs,hf,hfr,htail⟩ := h.stack_view hf₀
  rw [hfr.try_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have he := hl.1.1.2.2.1
  have vLive := (h.return_abrupt_values v₀ v hc₀ hc).2
  have saved : FrameR NR R (.s (.finally_ (.abrupt (.ret v₀)))) (.s (.finally_ (.abrupt (.ret v)))) := by
    repeat first | exact hv | constructor
  have savedLive : treeSupport live (Encode.frame (.s (.finally_ (.abrupt (.ret v₀))))) :=
    ⟨⟨⟨⟨vLive,True.intro⟩,True.intro⟩,True.intro⟩,True.intro⟩
  have related := enterBlock_roles (h.restack (.cons saved htail) ⟨savedLive,hl.2⟩) fin env inert he sourceBound targetBound
  exact ⟨v,fs,by rw [step_return_finally_eq F s₀ v₀ handler fin env fs₀ hc₀ hf₀]; rfl,
    by rw [step_return_finally_eq F s v handler fin (R.env env) fs hc hf]; rfl,related⟩

/-- A finalizer with no lexical cells and no initialized functions preserves
all heap slots while saving the pending return. -/
theorem step_return_finally_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (_C₀ C D : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (handler : Option (Option Pat × List Stmt)) (fin : List Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .abr (.ret v₀)) (hf₀ : s₀.stack = .s (.try_ handler (some fin) env)::fs₀)
    (inert : noInitFunctions fin = true) (names : blockNames fin = [])
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).returnAbrupt_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.try_view] at hf
  rw [step_return_finally_eq F s v handler fin (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [← he]
  change (hoist _ fin (R.env env)).2.heap = s.heap
  rw [hoist_inert_eq _ _ _ inert,names]
  rfl
end Host.Ts.Owned.Parametric
