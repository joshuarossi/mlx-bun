import host.ts.RenameParametricViews

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

/-- Statement entries that install structural continuations without allocating.
Declaration cells have already been allocated by the actual block hoister. -/
inductive StatementAction where
  | expression (e : Expr)
  | function (fn : Func)
  | returnExpression (e : Expr)
  | returnVoid
  | ifTest (test : Expr) (yes : Stmt) (no : Option Stmt)
  | throwExpression (e : Expr)
  | breakLabel (label : Option Name)
  | continueLabel (label : Option Name)
  | empty
  | declarationEmpty (kind : DeclKind)
  | declarationInit (kind : DeclKind) (p : Pat) (e : Expr) (rest : List (Pat × Option Expr))
  | declarationUndef (kind : DeclKind) (p : Pat) (rest : List (Pat × Option Expr))
  | whileTest (test : Expr) (body : Stmt)
  | doBody (body : Stmt) (test : Expr)
  | forOfSource (await : Bool) (kind : Option DeclKind) (p : Pat) (source : Expr) (body : Stmt)

def StatementAction.statement : StatementAction → Stmt
  | .expression e => .expr e | .function fn => .func fn
  | .returnExpression e => .ret (some e) | .returnVoid => .ret none
  | .ifTest t y n => .if_ t y n | .throwExpression e => .throw e
  | .breakLabel l => .break l | .continueLabel l => .continue l | .empty => .empty
  | .declarationEmpty k => .decl k []
  | .declarationInit k p e r => .decl k ((p,some e)::r)
  | .declarationUndef k p r => .decl k ((p,none)::r)
  | .whileTest t b => .while_ t b | .doBody b t => .doWhile b t
  | .forOfSource aw k p src b => .forOf aw k p src b

def StatementAction.frames (env : Env) : StatementAction → List Frame
  | .returnExpression _ => [.s .ret]
  | .ifTest _ y n => [.s (.if_ y n env)]
  | .throwExpression _ => [.s .throw]
  | .declarationInit k p _ r => [.s (.decl k p r env)]
  | .declarationUndef k _ r => [.s (.declNext k r env)]
  | .whileTest t b => [.lp (.whileTest t b env [])]
  | .doBody b t => [.lp (.doBody b t env [])]
  | .forOfSource aw k p _ b => [.lp (.forOfSrc aw k p b env [])]
  | _ => []

def StatementAction.control (env : Env) : StatementAction → Ctl
  | .expression e | .returnExpression e | .throwExpression e => .ev e env
  | .ifTest t _ _ => .ev t env
  | .returnVoid => .abr (.ret .undef)
  | .breakLabel l => .abr (.brk l) | .continueLabel l => .abr (.cont l)
  | .declarationInit _ _ e _ => .ev e env
  | .declarationUndef k p _ => .bind p .undef env .init k
  | .whileTest t _ => .ev t env | .doBody b _ => .ex b env
  | .forOfSource _ _ _ src _ => .ev src env
  | _ => .ret .undef

def StatementAction.advance {S : Type} (a : StatementAction) (s : St S) (env : Env) : St S :=
  {s with stack := a.frames env ++ s.stack}.go (a.control env)

theorem StatementAction.frames_roles (a : StatementAction) (NR : NumV → NumV → Prop) (R : Ren) (env : Env) :
    ListR (FrameR NR R) (a.frames env) (a.frames (R.env env)) := by
  cases a <;> dsimp only [StatementAction.frames,Encode.frame,Encode.stmtF,Encode.loopF,Encode.atom]
  all_goals repeat first | exact env_roles NR R env | constructor

theorem StatementAction.frames_live (a : StatementAction) (live : Nat → Prop) (env : Env)
    (he : treeSupport live (Encode.env env)) :
    listSupport (fun f => treeSupport live (Encode.frame f)) (a.frames env) := by
  cases a <;> dsimp only [StatementAction.frames,Encode.frame,Encode.stmtF,Encode.loopF,Encode.atom,
    listSupport,treeSupport,forestSupport]
  all_goals repeat first | exact he | constructor

theorem StatementAction.control_roles (a : StatementAction) (NR : NumV → NumV → Prop) (R : Ren) (env : Env) :
    ControlR NR R (a.control env) (a.control (R.env env)) := by
  cases a <;> dsimp only [StatementAction.control,Encode.ctl,Encode.abr,Encode.atom,Encode.val]
  all_goals repeat first | exact env_roles NR R env | constructor

theorem StatementAction.control_live (a : StatementAction) (live : Nat → Prop) (env : Env)
    (he : treeSupport live (Encode.env env)) : treeSupport live (Encode.ctl (a.control env)) := by
  cases a <;> dsimp only [StatementAction.control,Encode.ctl,Encode.abr,Encode.atom,Encode.val,
    treeSupport,forestSupport,valueSupport]
  all_goals repeat first | exact he | constructor

theorem listSupport_append {α : Type} {p : α → Prop} {as bs : List α}
    (ha : listSupport p as) (hb : listSupport p bs) : listSupport p (as ++ bs) := by
  induction as with
  | nil => exact hb
  | cons a as ih => exact ⟨ha.1,ih ha.2⟩

theorem StatementAction.advance_roles {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR NR FR R live framed before after old old' s₀ s) (a : StatementAction) (env : Env)
    (he : treeSupport live (Encode.env env)) :
    StateR NR FR R live framed before after old old' (a.advance s₀ env) (a.advance s (R.env env)) :=
  (h.restack ((a.frames_roles NR R env).append h.stack)
    (listSupport_append (a.frames_live live env he) h.stackLive)).go
      (a.control_roles NR R env) (a.control_live live env he)

theorem step_statement_eq (F : Ffi) (s : St F.S) (a : StatementAction) (env : Env)
    (hc : s.ctl = .ex a.statement env) : step F s = M.pure (a.advance s env) := by
  cases a <;> simp only [step,hc,StatementAction.statement,exStep,declNext,exLoop,exLoopF,
    StatementAction.advance,StatementAction.frames,StatementAction.control,List.nil_append,
    List.cons_append,retS,St.ret,St.push,St.go]

/-- Source-only dispatch: the target control, syntax, environment, new frames
and execution are all consequences of the initial state relation. -/
theorem step_statement_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (a : StatementAction) (env : Env)
    (hc₀ : s₀.ctl = .ex a.statement env) :
    interpC (step F s₀).run C₀ = some (a.advance s₀ env,C₀) ∧
    interpC (step F s).run C = some (a.advance s (R.env env),C) ∧
    StateR NR FR R live framed before after old old' (a.advance s₀ env) (a.advance s (R.env env)) := by
  have hc := (h.control_view hc₀).ex_view
  have hl := h.controlLive
  rw [hc₀] at hl
  refine ⟨?_,?_,a.advance_roles h env hl.2.1⟩
  · rw [step_statement_eq F s₀ a env hc₀]; rfl
  · rw [step_statement_eq F s a (R.env env) hc]; rfl

theorem step_block_next_eq (F : Ffi) (s : St F.S) (v : Val) (st : Stmt)
    (rest : List Stmt) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret v) (hf : s.stack = .s (.block (st::rest) env)::fs) :
    step F s = M.pure (({s with stack := fs}.push (.s (.block rest env))).go (.ex st env)) := by
  simp only [step,hc,stepRet,hf,retStep,retSt]

theorem step_block_next_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s) (v₀ : Val)
    (st : Stmt) (rest : List Stmt) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.block (st::rest) env)::fs₀) :
    ∃ fs, interpC (step F s₀).run C₀ =
        some (({s₀ with stack := fs₀}.push (.s (.block rest env))).go (.ex st env),C₀) ∧
      interpC (step F s).run C =
        some (({s with stack := fs}.push (.s (.block rest (R.env env)))).go (.ex st (R.env env)),C) ∧
      StateR NR FR R live framed before after old old'
        (({s₀ with stack := fs₀}.push (.s (.block rest env))).go (.ex st env))
        (({s with stack := fs}.push (.s (.block rest (R.env env)))).go (.ex st (R.env env))) := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,hfs⟩ := h.stack_view hf₀
  have hfe := hfr.block_view
  rw [hfe] at hf
  have hl := h.stackLive
  rw [hf₀] at hl
  have hel : treeSupport live (Encode.env env) := hl.1.1.2.1
  have hnew : FrameR NR R (.s (.block rest env)) (.s (.block rest (R.env env))) :=
    .node _ (.cons (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) .nil)
  have hnewl : treeSupport live (Encode.frame (.s (.block rest env))) :=
    ⟨⟨True.intro,hel,True.intro⟩,True.intro⟩
  refine ⟨fs,?_,?_,(h.restack (.cons hnew hfs) ⟨hnewl,hl.2⟩).go
    (.node _ (.cons (.atom _ _) (.cons (env_roles NR R env) .nil))) ⟨True.intro,hel,True.intro⟩⟩
  · rw [step_block_next_eq F s₀ v₀ st rest env fs₀ hc₀ hf₀]; rfl
  · rw [step_block_next_eq F s v st rest (R.env env) fs hc hf]; rfl

end Host.Ts.Owned.Parametric
