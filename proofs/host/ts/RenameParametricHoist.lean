import host.ts.RenameParametricCallStep

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

/-- A checked property of the actual block AST, including anonymous function
declarations, which `initFuncs` does not initialize. -/
def noInitFunctions : List Stmt → Bool
  | [] => true
  | .func (.mk (some _) _ _ _ _ _ _) :: _ => false
  | _ :: ss => noInitFunctions ss

theorem initFuncs_inert {S : Type} (s : St S) (env : Env) (ss : List Stmt)
    (h : noInitFunctions ss = true) : initFuncs s env ss = s := by
  induction ss generalizing s with
  | nil => rfl
  | cons st ss ih =>
    cases st <;> try simp only [noInitFunctions,initFuncs] at *
    all_goals try exact ih s h
    case func f =>
      cases f with | mk name params rest body async gen props =>
        cases name <;> simp only [noInitFunctions,initFuncs] at *
        · exact ih s h
        · cases h

theorem hoist_inert_eq {S : Type} (s : St S) (env : Env) (ss : List Stmt)
    (h : noInitFunctions ss = true) : hoist s ss env = allocCells s (blockNames ss) env := by
  unfold hoist
  cases hn : blockNames ss with
  | nil => rfl
  | cons n ns => simp only [initFuncs_inert _ _ ss h]

/-- The real hoister allocates every lexical cell. The no-initializer premise
is a Boolean check on source syntax, not an assumption about execution. -/
theorem hoist_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s) (ss : List Stmt) (env : Env)
    (hf : noInitFunctions ss = true) (he : treeSupport live (Encode.env env))
    (hs : s₀.next + (blockNames ss).length ≤ 2^64) (ht : s.next + (blockNames ss).length ≤ 2^64) :
    StateR NR FR R (CellsLive live s₀.next (blockNames ss)) framed before after old old'
      (hoist s₀ ss env).2 (hoist s ss (R.env env)).2 ∧
    (hoist s ss (R.env env)).1 = R.env (hoist s₀ ss env).1 ∧
    treeSupport (CellsLive live s₀.next (blockNames ss)) (Encode.env (hoist s₀ ss env).1) := by
  rw [hoist_inert_eq _ _ _ hf,hoist_inert_eq _ _ _ hf]
  exact allocCells_roles h (blockNames ss) env he hs ht

theorem enterBlock_roles {S : Type} {NR : NumV → NumV → Prop} {FR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s) (ss : List Stmt) (env : Env)
    (hf : noInitFunctions ss = true) (he : treeSupport live (Encode.env env))
    (hs : s₀.next + (blockNames ss).length ≤ 2^64) (ht : s.next + (blockNames ss).length ≤ 2^64) :
    StateR NR FR R (CellsLive live s₀.next (blockNames ss)) framed before after old old'
      (enterBlock s₀ ss env) (enterBlock s ss (R.env env)) := by
  obtain ⟨hh,henv,hel⟩ := hoist_roles h ss env hf he hs ht
  have hr : FrameR NR R (.s (.block ss (hoist s₀ ss env).1)) (.s (.block ss (hoist s ss (R.env env)).1)) := by
    rw [henv]
    exact .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (env_roles NR R _) .nil))) .nil)
  have hrl : treeSupport (CellsLive live s₀.next (blockNames ss)) (Encode.frame (.s (.block ss (hoist s₀ ss env).1))) :=
    ⟨⟨True.intro,hel,True.intro⟩,True.intro⟩
  have hscope : FrameR NR R (.s (.scope [])) (.s (.scope [])) :=
    .node _ (.cons (.node _ (.cons (.node _ .nil) .nil)) .nil)
  have hscopel : treeSupport (CellsLive live s₀.next (blockNames ss)) (Encode.frame (.s (.scope []))) :=
    ⟨⟨True.intro,True.intro⟩,True.intro⟩
  exact (hh.restack (.cons hr (.cons hscope hh.stack)) ⟨hrl,hscopel,hh.stackLive⟩).go
    (.node _ (.cons (.value .undef) .nil)) ⟨True.intro,True.intro⟩

theorem step_block_eq (F : Ffi) (s : St F.S) (ss : List Stmt) (env : Env)
    (hc : s.ctl = .ex (.block ss) env) : step F s = M.pure (enterBlock s ss env) := by
  simp only [step,hc,exStep]

theorem step_block_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (ss : List Stmt) (env : Env)
    (hc₀ : s₀.ctl = .ex (.block ss) env) (hc : s.ctl = .ex (.block ss) (R.env env))
    (hf : noInitFunctions ss = true)
    (hs : s₀.next + (blockNames ss).length ≤ 2^64) (ht : s.next + (blockNames ss).length ≤ 2^64) :
    interpC (step F s₀).run C₀ = some (enterBlock s₀ ss env,C₀) ∧
    interpC (step F s).run C = some (enterBlock s ss (R.env env),C) ∧
    StateR NR FR R (CellsLive live s₀.next (blockNames ss)) framed before after old old'
      (enterBlock s₀ ss env) (enterBlock s ss (R.env env)) := by
  have hl := h.controlLive
  rw [hc₀] at hl
  refine ⟨?_,?_,enterBlock_roles h ss env hf hl.2.1 hs ht⟩
  · rw [step_block_eq F s₀ ss env hc₀]; rfl
  · rw [step_block_eq F s ss (R.env env) hc]; rfl

theorem startBody_block_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Option Name) (params : List Pat) (rest : Option Pat) (ss : List Stmt) (async gen : Bool) (env : Env)
    (hf : noInitFunctions ss = true) (he : treeSupport live (Encode.env env))
    (hs : s₀.next + (blockNames ss).length ≤ 2^64) (ht : s.next + (blockNames ss).length ≤ 2^64) :
    let f := Func.mk name params rest (.block ss) async gen []
    interpC (startBody F s₀ f env).run C₀ = some (enterBlock s₀ ss env,C₀) ∧
    interpC (startBody F s f (R.env env)).run C = some (enterBlock s ss (R.env env),C) ∧
    StateR NR FR R (CellsLive live s₀.next (blockNames ss)) framed before after old old'
      (enterBlock s₀ ss env) (enterBlock s ss (R.env env)) := by
  exact ⟨rfl,rfl,enterBlock_roles h ss env hf he hs ht⟩

end Host.Ts.Owned.Parametric
