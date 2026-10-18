import host.ts.RenameParametricDeclarations
import host.ts.RenameParametricCalls

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

def forLetState {S : Type} (s : St S) (name : Name) (init : Expr)
    (test update : Option Expr) (body : Stmt) (env : Env) : St S :=
  let (env,s) := allocCells s [name] env
  (.declarationInit .let_ (.id name) init [] : StatementAction).advance
    (s.push (.lp (.forTest true test update body env [name] []))) env

theorem step_for_let_eq (F : Ffi) (s : St F.S) (name : Name) (init : Expr)
    (test update : Option Expr) (body : Stmt) (env : Env)
    (hc : s.ctl = .ex (.for_ (some (.decl .let_ [(.id name,some init)])) test update body) env) :
    step F s = M.pure (forLetState s name init test update body env) := by
  simp only [step,hc,exStep,exLoop,exLoopF,forStart,declsNames,patNames,patNamesF,
    List.nil_append,List.cons_append,forLetState,declNext,StatementAction.advance,
    StatementAction.frames,StatementAction.control,St.push,St.go]

/-- The actual single-let for header allocates its lexical cell before
evaluating the initializer. The returned environment and fresh address are
derived from the original allocator. -/
theorem step_for_let_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (init : Expr) (test update : Option Expr) (body : Stmt) (env : Env)
    (hc₀ : s₀.ctl = .ex (.for_ (some (.decl .let_ [(.id name,some init)])) test update body) env)
    (hs : s₀.next+1 ≤ 2^64) (ht : s.next+1 ≤ 2^64) :
    interpC (step F s₀).run C₀ = some (forLetState s₀ name init test update body env,C₀) ∧
      interpC (step F s).run C = some (forLetState s name init test update body (R.env env),C) ∧
      StateR NR FR R (CellsLive live s₀.next [name]) framed before after old old'
        (forLetState s₀ name init test update body env)
        (forLetState s name init test update body (R.env env)) := by
  have hc := (h.control_view hc₀).ex_view
  have hl := h.controlLive
  rw [hc₀] at hl
  obtain ⟨hh,he,hel⟩ := allocCells_roles h [name] env hl.2.1 hs ht
  let env₀ := (allocCells s₀ [name] env).1
  have hframe : FrameR NR R (.lp (.forTest true test update body env₀ [name] []))
      (.lp (.forTest true test update body (R.env env₀) [name] [])) := by
    repeat first | exact env_roles NR R env₀ | constructor
  have hfl : treeSupport (CellsLive live s₀.next [name])
      (Encode.frame (.lp (.forTest true test update body env₀ [name] []))) := by
    dsimp only [Encode.frame,Encode.loopF,Encode.atom,treeSupport,forestSupport]
    repeat first | exact hel | constructor
  have hr := (.declarationInit .let_ (.id name) init [] : StatementAction).advance_roles
    (hh.restack (.cons hframe hh.stack) ⟨hfl,hh.stackLive⟩) env₀ hel
  refine ⟨?_,?_,?_⟩
  · rw [step_for_let_eq F s₀ name init test update body env hc₀]; rfl
  · rw [step_for_let_eq F s name init test update body (R.env env) hc]; rfl
  · simpa only [forLetState,he,env₀,St.push] using hr

end Host.Ts.Owned.Parametric
