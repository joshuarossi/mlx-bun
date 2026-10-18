import host.ts.RenameParametricPrivate
namespace Host.Ts.Owned.Parametric

/-- Expression dispatches that only install a continuation and evaluate a
syntactic child. The source expression itself remains the real program AST. -/
inductive Descent where
  | binary (op : BinOp) (a b : Expr)
  | logical (op : LogOp) (a b : Expr)
  | conditional (test yes no : Expr)
  | sequence (a b : Expr)
  | member (obj : Expr) (name : Name) (optional : Bool)
  | index (obj key : Expr) (optional : Bool)
  | construct (callee : Expr) (args : List Elem)
  | chain (expr : Expr)
  | await (expr : Expr)
  | yield (expr : Expr) (delegate : Bool)

def Descent.whole : Descent → Expr
  | .binary op a b => .bin op a b | .logical op a b => .log op a b
  | .conditional t a b => .cond t a b | .sequence a b => .seq a b
  | .member o n opt => .member o n opt | .index o k opt => .index o k opt
  | .construct f args => .new f args | .chain e => .chain e | .await e => .await e
  | .yield e d => .yield (some e) d

def Descent.focus : Descent → Expr
  | .binary _ a _ | .logical _ a _ | .conditional a _ _ | .sequence a _ => a
  | .member o _ _ | .index o _ _ => o
  | .construct f _ => f | .chain e | .await e | .yield e _ => e

def Descent.frame (env : Env) : Descent → Frame
  | .binary op _ b => .e (.binL op b env) | .logical op _ b => .e (.logL op b env)
  | .conditional _ a b => .e (.cond a b env) | .sequence _ b => .e (.seq b env)
  | .member _ n opt => .e (.member (.str n) opt) | .index _ k opt => .e (.indexL k env opt)
  | .construct _ args => .c (.newCallee args env) | .chain _ => .e .chain
  | .await _ => .k .await | .yield _ d => .k (.yield d)

theorem Descent.frame_roles {NR : NumV → NumV → Prop} {R : Ren} (d : Descent) {env₀ env : Env}
    (he : TreeR NR R (Encode.env env₀) (Encode.env env)) :
    FrameR NR R (d.frame env₀) (d.frame env) := by
  cases d <;> dsimp only [Descent.frame,Encode.frame,Encode.exprF,Encode.callF,Encode.fnF,Encode.key,Encode.atom]
  all_goals repeat first | exact he | constructor

theorem Descent.frame_live {live : Nat → Prop} (d : Descent) {env : Env}
    (he : treeSupport live (Encode.env env)) : treeSupport live (Encode.frame (d.frame env)) := by
  cases d <;> dsimp only [Descent.frame,Encode.frame,Encode.exprF,Encode.callF,Encode.fnF,Encode.key,Encode.atom,treeSupport,forestSupport]
  all_goals repeat first | exact he | constructor

/-- Exact interpreter dispatch for all these source syntax constructors. -/
theorem step_descent_eq (F : Ffi) (s : St F.S) (d : Descent) (env : Env)
    (hc : s.ctl = .ev d.whole env) :
    step F s = M.pure ((s.push (d.frame env)).go (.ev d.focus env)) := by
  cases d <;> simp only [step,hc,Descent.whole,Descent.focus,Descent.frame,evStep]

/-- Structural source evaluation preserves the full runtime relation, including
all live heap/native resources and the existing stack, jobs and output frames. -/
theorem step_descent_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (d : Descent) (env₀ env : Env)
    (hc₀ : s₀.ctl = .ev d.whole env₀) (hc : s.ctl = .ev d.whole env) :
    interpC (step F s₀).run C₀ = some ((s₀.push (d.frame env₀)).go (.ev d.focus env₀),C₀) ∧
    interpC (step F s).run C = some ((s.push (d.frame env)).go (.ev d.focus env),C) ∧
    StateR NR FR R live framed before after old old'
      ((s₀.push (d.frame env₀)).go (.ev d.focus env₀)) ((s.push (d.frame env)).go (.ev d.focus env)) := by
  have he : TreeR NR R (Encode.env env₀) (Encode.env env) := by
    have hr := h.control
    rw [hc₀,hc] at hr
    cases hr with | node tag hs =>
      cases hs with | cons he hs =>
        cases hs with | cons henv hs => exact henv
  have hel : treeSupport live (Encode.env env₀) := by
    have hl := h.controlLive
    rw [hc₀] at hl
    exact hl.2.1
  have hs := h.restack (.cons (d.frame_roles he) h.stack) ⟨d.frame_live hel,h.stackLive⟩
  refine ⟨?_,?_,hs.go (.node _ (.cons (.atom _ _) (.cons he .nil))) ⟨True.intro,hel,True.intro⟩⟩
  · rw [step_descent_eq F s₀ d env₀ hc₀]; rfl
  · rw [step_descent_eq F s d env hc]; rfl

end Host.Ts.Owned.Parametric
