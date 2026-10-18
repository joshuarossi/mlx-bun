import host.ts.RenameParametricIteration

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem FrameR.lp_view {NR : NumV → NumV → Prop} {R : Ren}
    {lf : LoopF} {f : Frame} (h : FrameR NR R (.lp lf) f) :
    ∃ lf', f = .lp lf' ∧ TreeR NR R (Encode.loopF lf) (Encode.loopF lf') := by
  have ht := h.tag_eq
  cases f <;> simp only [Encode.frame,treeTag] at ht
  all_goals try contradiction
  case lp lf' => cases h with | node tag hs =>
    cases hs with | cons hh hs => exact ⟨lf',rfl,hh⟩

theorem FrameR.forTest_view {NR : NumV → NumV → Prop} {R : Ren}
    {copy : Bool} {test update : Option Expr} {body : Stmt} {env : Env} {names labels : List Name} {f : Frame}
    (h : FrameR NR R (.lp (.forTest copy test update body env names labels)) f) : f = .lp (.forTest copy test update body (R.env env) names labels) := by
  obtain ⟨lf,rfl,hh⟩ := h.lp_view
  have ht := hh.tag_eq
  cases lf <;> simp only [Encode.loopF,treeTag] at ht
  all_goals try contradiction
  case forTest copy' test' update' body' env' names' labels' =>
    cases hh with | node tag hs =>
      cases hs with | cons hcopy hs =>
        cases hs with | cons htest hs =>
          cases hs with | cons hupdate hs =>
            cases hs with | cons hbody hs =>
              cases hs with | cons henv hs =>
                cases hs with | cons hnames hs =>
                  cases hs with | cons hlabels hs =>
                    cases hcopy; cases htest; cases hupdate; cases hbody; cases hnames; cases hlabels
                    obtain rfl := env_eq_map henv
                    rfl

theorem FrameR.forBody_view {NR : NumV → NumV → Prop} {R : Ren}
    {test update : Option Expr} {body : Stmt} {env : Env} {names labels : List Name} {f : Frame}
    (h : FrameR NR R (.lp (.forBody test update body env names labels)) f) : f = .lp (.forBody test update body (R.env env) names labels) := by
  obtain ⟨lf,rfl,hh⟩ := h.lp_view
  have ht := hh.tag_eq
  cases lf <;> simp only [Encode.loopF,treeTag] at ht
  all_goals try contradiction
  case forBody test' update' body' env' names' labels' =>
    cases hh with | node tag hs =>
      cases hs with | cons htest hs =>
        cases hs with | cons hupdate hs =>
          cases hs with | cons hbody hs =>
            cases hs with | cons henv hs =>
              cases hs with | cons hnames hs =>
                cases hs with | cons hlabels hs =>
                  cases htest; cases hupdate; cases hbody; cases hnames; cases hlabels
                  obtain rfl := env_eq_map henv
                  rfl

theorem FrameR.forUpd_view {NR : NumV → NumV → Prop} {R : Ren}
    {test update : Option Expr} {body : Stmt} {env : Env} {names labels : List Name} {f : Frame}
    (h : FrameR NR R (.lp (.forUpd test update body env names labels)) f) : f = .lp (.forUpd test update body (R.env env) names labels) := by
  obtain ⟨lf,rfl,hh⟩ := h.lp_view
  have ht := hh.tag_eq
  cases lf <;> simp only [Encode.loopF,treeTag] at ht
  all_goals try contradiction
  case forUpd test' update' body' env' names' labels' =>
    cases hh with | node tag hs =>
      cases hs with | cons htest hs =>
        cases hs with | cons hupdate hs =>
          cases hs with | cons hbody hs =>
            cases hs with | cons henv hs =>
              cases hs with | cons hnames hs =>
                cases hs with | cons hlabels hs =>
                  cases htest; cases hupdate; cases hbody; cases hnames; cases hlabels
                  obtain rfl := env_eq_map henv
                  rfl

def forTestState {S : Type} (s : St S) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) : St S :=
  match test with
  | some t => (s.push (.lp (.forBody test update body env names labels))).go (.ev t env)
  | none => (s.push (.lp (.forUpd test update body env names labels))).go (.ex body env)

theorem forTestStep_eq (F : Ffi) (s : St F.S) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) :
    forTestStep F s test update body env names labels = M.pure (forTestState s test update body env names labels) := by
  cases test <;> rfl

def forUpdateState {S : Type} (s : St S) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) : St S :=
  match update with
  | some u => (s.push (.lp (.forTest false test update body env names labels))).go (.ev u env)
  | none => forTestState s test update body env names labels

theorem forTestState_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name)
    (he : treeSupport live (Encode.env env)) :
    StateR NR FR R live framed before after old old'
      (forTestState s₀ test update body env names labels)
      (forTestState s test update body (R.env env) names labels) := by
  cases test with
  | none =>
    have hf : FrameR NR R (.lp (.forUpd none update body env names labels))
        (.lp (.forUpd none update body (R.env env) names labels)) := by
      repeat first | exact env_roles NR R env | constructor
    have hfl : treeSupport live (Encode.frame (.lp (.forUpd none update body env names labels))) := by
      dsimp only [Encode.frame,Encode.loopF,Encode.atom,treeSupport,forestSupport]
      repeat first | exact he | constructor
    exact (h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
      (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩
  | some t =>
    have hf : FrameR NR R (.lp (.forBody (some t) update body env names labels))
        (.lp (.forBody (some t) update body (R.env env) names labels)) := by
      repeat first | exact env_roles NR R env | constructor
    have hfl : treeSupport live (Encode.frame (.lp (.forBody (some t) update body env names labels))) := by
      dsimp only [Encode.frame,Encode.loopF,Encode.atom,treeSupport,forestSupport]
      repeat first | exact he | constructor
    exact (h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
      (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩

theorem forUpdateState_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop}
    {R : Ren} {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name)
    (he : treeSupport live (Encode.env env)) :
    StateR NR FR R live framed before after old old'
      (forUpdateState s₀ test update body env names labels)
      (forUpdateState s test update body (R.env env) names labels) := by
  cases update with
  | none => exact forTestState_roles h test none body env names labels he
  | some u =>
    have hf : FrameR NR R (.lp (.forTest false test (some u) body env names labels))
        (.lp (.forTest false test (some u) body (R.env env) names labels)) := by
      repeat first | exact env_roles NR R env | constructor
    have hfl : treeSupport live (Encode.frame (.lp (.forTest false test (some u) body env names labels))) := by
      dsimp only [Encode.frame,Encode.loopF,Encode.atom,treeSupport,forestSupport]
      repeat first | exact he | constructor
    exact (h.restack (.cons hf h.stack) ⟨hfl,h.stackLive⟩).go
      (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,he,True.intro⟩

theorem step_for_copy_eq (F : Ffi) (s : St F.S) (v : Val) (test update : Option Expr)
    (body : Stmt) (env : Env) (name : Name) (labels : List Name) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .lp (.forTest true test update body env [name] labels)::fs) :
    step F s = M.pure (forTestState (nextIter F {s with stack := fs} [name] env).2 test update body
      (nextIter F {s with stack := fs} [name] env).1 [name] labels) := by
  simp only [step,hc,stepRet,hf,retStep,retLp,Bool.cond_true,forTestStep_eq]

/-- The actual for continuation creates its per-iteration lexical binding
from the source cell and then resumes the original test or update expression. -/
theorem step_for_copy_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (test update : Option Expr) (body : Stmt) (env : Env) (name : Name)
    (labels : List Name) (fs₀ : List Frame) (a : Nat) (value₀ : Val)
    (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .lp (.forTest true test update body env [name] labels)::fs₀)
    (he₀ : lookupEnv name env = some a) (hv₀ : s₀.heap.get a = some (.cell (some value₀)))
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some (forTestState
        (nextIter F {s₀ with stack := fs₀} [name] env).2 test update body
        (nextIter F {s₀ with stack := fs₀} [name] env).1 [name] labels,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
        (forTestState (nextIter F {s₀ with stack := fs₀} [name] env).2 test update body
          (nextIter F {s₀ with stack := fs₀} [name] env).1 [name] labels) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.forTest_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.2.1
  obtain ⟨hh,he,henv⟩ := nextIter_one_roles F NR FR R live framed before after old old'
    {s₀ with stack := fs₀} {s with stack := fs} (h.restack hfs hl.2) name env a value₀ hel he₀ hv₀ hs ht
  have hr := forTestState_roles hh test update body _ [name] labels henv
  refine ⟨forTestState (nextIter F {s with stack := fs} [name] (R.env env)).2 test update body
    (nextIter F {s with stack := fs} [name] (R.env env)).1 [name] labels,?_,?_,?_⟩
  · rw [step_for_copy_eq F s₀ v₀ test update body env name labels fs₀ hc₀ hf₀]; rfl
  · rw [step_for_copy_eq F s v test update body (R.env env) name labels fs hc hf]; rfl
  · rw [he]
    exact hr

theorem step_for_update_eq (F : Ffi) (s : St F.S) (v : Val) (test update : Option Expr)
    (body : Stmt) (env : Env) (name : Name) (labels : List Name) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .lp (.forUpd test update body env [name] labels)::fs) :
    step F s = M.pure (forUpdateState (nextIter F {s with stack := fs} [name] env).2 test update body
      (nextIter F {s with stack := fs} [name] env).1 [name] labels) := by
  cases update <;> simp only [step,hc,stepRet,hf,retStep,retLp,Bool.cond_true,forUpdateState,forTestStep_eq]

/-- The actual for continuation creates its per-iteration lexical binding
from the source cell and then resumes the original test or update expression. -/
theorem step_for_update_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (test update : Option Expr) (body : Stmt) (env : Env) (name : Name)
    (labels : List Name) (fs₀ : List Frame) (a : Nat) (value₀ : Val)
    (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .lp (.forUpd test update body env [name] labels)::fs₀)
    (he₀ : lookupEnv name env = some a) (hv₀ : s₀.heap.get a = some (.cell (some value₀)))
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    ∃ result, interpC (step F s₀).run C₀ = some (forUpdateState
        (nextIter F {s₀ with stack := fs₀} [name] env).2 test update body
        (nextIter F {s₀ with stack := fs₀} [name] env).1 [name] labels,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
        (forUpdateState (nextIter F {s₀ with stack := fs₀} [name] env).2 test update body
          (nextIter F {s₀ with stack := fs₀} [name] env).1 [name] labels) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.forUpd_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.1
  obtain ⟨hh,he,henv⟩ := nextIter_one_roles F NR FR R live framed before after old old'
    {s₀ with stack := fs₀} {s with stack := fs} (h.restack hfs hl.2) name env a value₀ hel he₀ hv₀ hs ht
  have hr := forUpdateState_roles hh test update body _ [name] labels henv
  refine ⟨forUpdateState (nextIter F {s with stack := fs} [name] (R.env env)).2 test update body
    (nextIter F {s with stack := fs} [name] (R.env env)).1 [name] labels,?_,?_,?_⟩
  · rw [step_for_update_eq F s₀ v₀ test update body env name labels fs₀ hc₀ hf₀]; rfl
  · rw [step_for_update_eq F s v test update body (R.env env) name labels fs hc hf]; rfl
  · rw [he]
    exact hr

theorem step_for_test_eq (F : Ffi) (s : St F.S) (v : Val) (test update : Option Expr)
    (body : Stmt) (env : Env) (names labels : List Name) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .lp (.forTest false test update body env names labels)::fs) :
    step F s = M.pure (forTestState {s with stack := fs} test update body env names labels) := by
  simp only [step,hc,stepRet,hf,retStep,retLp,Bool.cond_false,forTestStep_eq]

theorem step_for_test_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name)
    (fs₀ : List Frame) (hc₀ : s₀.ctl = .ret v₀)
    (hf₀ : s₀.stack = .lp (.forTest false test update body env names labels)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ = some (forTestState {s₀ with stack := fs₀} test update body env names labels,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (forTestState {s₀ with stack := fs₀} test update body env names labels) result := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.forTest_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.2.1
  refine ⟨forTestState {s with stack := fs} test update body (R.env env) names labels,?_,?_,
    forTestState_roles (h.restack hfs hl.2) test update body env names labels hel⟩
  · rw [step_for_test_eq F s₀ v₀ test update body env names labels fs₀ hc₀ hf₀]; rfl
  · rw [step_for_test_eq F s v test update body (R.env env) names labels fs hc hf]; rfl

def forBodyState {S : Type} (s : St S) (b : Bool) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) : St S :=
  if b then (s.push (.lp (.forUpd test update body env names labels))).go (.ex body env) else s.ret .undef

theorem step_for_body_eq (F : Ffi) (s : St F.S) (b : Bool) (test update : Option Expr)
    (body : Stmt) (env : Env) (names labels : List Name) (fs : List Frame)
    (hc : s.ctl = .ret (.bool b)) (hf : s.stack = .lp (.forBody test update body env names labels)::fs) :
    step F s = M.pure (forBodyState {s with stack := fs} b test update body env names labels) := by
  cases b <;> funext β k <;>
    simp only [step,hc,stepRet,hf,retStep,retLp,truthy,M.bind,M.pure,Bool.cond_true,Bool.cond_false,
      retS,forBodyState,Bool.false_eq_true,↓reduceIte]

theorem step_for_body_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (b : Bool) (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name)
    (fs₀ : List Frame) (hc₀ : s₀.ctl = .ret (.bool b))
    (hf₀ : s₀.stack = .lp (.forBody test update body env names labels)::fs₀) :
    ∃ result, interpC (step F s₀).run C₀ = some (forBodyState {s₀ with stack := fs₀} b test update body env names labels,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old'
        (forBodyState {s₀ with stack := fs₀} b test update body env names labels) result := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  rw [hfr.forBody_view] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.2.2.1
  refine ⟨forBodyState {s with stack := fs} b test update body (R.env env) names labels,?_,?_,?_⟩
  · rw [step_for_body_eq F s₀ b test update body env names labels fs₀ hc₀ hf₀]; rfl
  · rw [step_for_body_eq F s b test update body (R.env env) names labels fs hc hf]; rfl
  · cases b
    · exact (h.restack hfs hl.2).go (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩
    · have hnew : FrameR NR R (.lp (.forUpd test update body env names labels))
          (.lp (.forUpd test update body (R.env env) names labels)) := by
        repeat first | exact env_roles NR R env | constructor
      have hnewl : treeSupport live (Encode.frame (.lp (.forUpd test update body env names labels))) := by
        dsimp only [Encode.frame,Encode.loopF,Encode.atom,treeSupport,forestSupport]
        repeat first | exact hel | constructor
      exact (h.restack (.cons hnew hfs) ⟨hnewl,hl.2⟩).go
        (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,hel,True.intro⟩

end Host.Ts.Owned.Parametric
