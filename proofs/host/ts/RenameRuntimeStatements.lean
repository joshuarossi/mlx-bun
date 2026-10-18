import host.ts.RenameRuntimeBinding
import host.ts.RenameParametricStatements
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def statementNote (stmt : Stmt) (env : Env) : Tree :=
  .node "Ctl.ex" [.atom Stmt stmt,environmentNote env]
def blockFrameNote (rest : List Stmt) (env : Env) : Tree :=
  .node "Frame.s" [.node "StmtF.block" [.atom (List Stmt) rest,environmentNote env]]
def statementFrameNotes (env : Env) : StatementAction → List Tree
  | .returnExpression _ => [.node "Frame.s" [.node "StmtF.ret" []]]
  | .ifTest _ yes no => [.node "Frame.s" [.node "StmtF.if_" [.atom Stmt yes,.atom (Option Stmt) no,environmentNote env]]]
  | .throwExpression _ => [.node "Frame.s" [.node "StmtF.throw" []]]
  | .declarationInit kind p _ rest => [.node "Frame.s" [.node "StmtF.decl" [.atom DeclKind kind,.atom Pat p,.atom (List (Pat × Option Expr)) rest,environmentNote env]]]
  | .declarationUndef kind _ rest => [declarationNextNote kind rest env]
  | .whileTest test body => [.node "Frame.lp" [.node "LoopF.whileTest" [.atom Expr test,.atom Stmt body,environmentNote env,.atom (List Name) []]]]
  | .doBody body test => [.node "Frame.lp" [.node "LoopF.doBody" [.atom Stmt body,.atom Expr test,environmentNote env,.atom (List Name) []]]]
  | .forOfSource await kind p _ body => [.node "Frame.lp" [.node "LoopF.forOfSrc" [.atom Bool await,.atom (Option DeclKind) kind,.atom Pat p,.atom Stmt body,environmentNote env,.atom (List Name) []]]]
  | _ => []
def statementControlNote (env : Env) : StatementAction → Tree
  | .expression e | .returnExpression e | .throwExpression e => expressionNote e env
  | .ifTest test _ _ => expressionNote test env
  | .returnVoid => .node "Ctl.abr" [.node "Abrupt.ret" [.value .undef]]
  | .breakLabel label => .node "Ctl.abr" [.node "Abrupt.brk" [.atom (Option Name) label]]
  | .continueLabel label => .node "Ctl.abr" [.node "Abrupt.cont" [.atom (Option Name) label]]
  | .declarationInit _ _ e _ => expressionNote e env
  | .declarationUndef kind p _ => bindingNote p .undef env .init kind
  | .whileTest test _ => expressionNote test env
  | .doBody body _ => statementNote body env
  | .forOfSource _ _ _ source _ => expressionNote source env
  | _ => returnNote .undef
def RuntimeNotes.statement (notes : RuntimeNotes) (a : StatementAction) (env : Env) : RuntimeNotes :=
  {notes with control := statementControlNote env a,stack := statementFrameNotes env a ++ notes.stack}
def RuntimeNotes.blockNext (notes : RuntimeNotes) (stmt : Stmt) (rest : List Stmt) (env : Env)
    (tail : List Tree) : RuntimeNotes :=
  {notes with control := statementNote stmt env,stack := blockFrameNote rest env::tail}

theorem statementNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (stmt : Stmt) (env : Env) :
    (statementNote stmt env).Holds ν C R (Encode.ctl (.ex stmt (R.env env))) :=
  .node _ (.cons (.atom Stmt stmt) (.cons (environmentNote_holds ν C R env) .nil))
theorem blockFrameNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (rest : List Stmt) (env : Env) :
    (blockFrameNote rest env).Holds ν C R (Encode.frame (.s (.block rest (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (.atom (List Stmt) rest) (.cons (environmentNote_holds ν C R env) .nil))) .nil)

theorem statementFrameNotes_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (a : StatementAction) (env : Env) :
    ForestHolds ν C R (statementFrameNotes env a) ((a.frames (R.env env)).map Encode.frame) := by
  cases a <;> dsimp only [statementFrameNotes,StatementAction.frames,Encode.frame,Encode.stmtF,Encode.loopF,
    Encode.atom,declarationNextNote,List.map_cons,List.map_nil]
  all_goals repeat first | exact environmentNote_holds ν C R env | constructor

theorem statementControlNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (a : StatementAction) (env : Env) :
    (statementControlNote env a).Holds ν C R (Encode.ctl (a.control (R.env env))) := by
  cases a <;> dsimp only [statementControlNote,StatementAction.control,Encode.ctl,Encode.abr,Encode.val,
    Encode.atom,expressionNote,statementNote,returnNote,bindingNote]
  all_goals repeat first | exact environmentNote_holds ν C R env | constructor

theorem ForestHolds.append {ν : Nat → F64} {C : CSrv} {R : Ren} {leftNotes rightNotes : List Tree}
    {xs ys : List Owned.Tree} (h : ForestHolds ν C R leftNotes xs) (g : ForestHolds ν C R rightNotes ys) :
    ForestHolds ν C R (leftNotes ++ rightNotes) (xs ++ ys) := by
  induction leftNotes generalizing xs with
  | nil => cases h; exact g
  | cons head tail ih => cases h with
    | cons hh ht => exact .cons hh (ih ht)

/-- Statement entry retains all previous fixed operand and cell notes and
adds only the structural continuations selected by the original interpreter. -/
theorem RuntimeInventory.statement_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : StatementAction) (env : Env) (control : s₀.ctl = .ex a.statement env) :
    interpC (step F s₀).run C₀ = some (a.advance s₀ env,C₀) ∧
    interpC (step F s).run C = some (a.advance s (R.env env),C) ∧
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      (a.advance s₀ env) (a.advance s (R.env env)) ∧
    RuntimeInventory (notes.statement a env) ν₀ ν C₀ C R live (a.advance s₀ env) (a.advance s (R.env env)) := by
  obtain ⟨left,right,related⟩ := step_statement_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h a env control
  refine ⟨left,right,related,inventory.keyLive,?_,?_⟩
  · refine ⟨?_,?_,inventory.source.cells⟩
    · simpa only [identity_environment,RuntimeNotes.statement,StatementAction.advance,St.go] using statementControlNote_holds ν₀ C₀ identity a env
    · simpa only [List.map_append,identity_environment,RuntimeNotes.statement,StatementAction.advance,St.go] using
        (statementFrameNotes_holds ν₀ C₀ identity a env).append inventory.source.stack
  · exact ⟨statementControlNote_holds ν C R a env,
      by simpa only [List.map_append,RuntimeNotes.statement,StatementAction.advance,St.go] using (statementFrameNotes_holds ν C R a env).append inventory.target.stack,
      inventory.target.cells⟩

/-- A nonempty block discards the preceding expression's result while keeping
the rest of the caller's fixed stack annotations intact. -/
theorem RuntimeInventory.block_next_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (stmt : Stmt) (rest : List Stmt) (env : Env) (frames : List Frame)
    (headNote : Tree) (tailNotes : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .s (.block (stmt::rest) env)::frames) (stackNotes : notes.stack = headNote::tailNotes) :
    ∃ result, interpC (step F s₀).run C₀ =
        some (({s₀ with stack := frames}.push (.s (.block rest env))).go (.ex stmt env),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (({s₀ with stack := frames}.push (.s (.block rest env))).go (.ex stmt env)) result ∧
      RuntimeInventory (notes.blockNext stmt rest env tailNotes) ν₀ ν C₀ C R live
        (({s₀ with stack := frames}.push (.s (.block rest env))).go (.ex stmt env)) result := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.block_view] at targetStack
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  obtain ⟨resultFrames,left,right,related⟩ := step_block_next_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h value stmt rest env frames control stack
  have actual : interpC (step F s).run C =
      some (({s with stack := targetFrames}.push (.s (.block rest (R.env env)))).go (.ex stmt (R.env env)),C) := by
    rw [step_block_next_eq F s targetValue stmt rest (R.env env) targetFrames targetControl targetStack]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actual))
  dsimp only at same
  rw [same] at related
  refine ⟨_,left,actual,related,inventory.keyLive,?_,?_⟩
  · exact ⟨by simpa only [identity_environment,RuntimeNotes.blockNext,St.go] using statementNote_holds ν₀ C₀ identity stmt env,
      .cons (by simpa only [identity_environment] using blockFrameNote_holds ν₀ C₀ identity rest env)
        sourceStack.tail,inventory.source.cells⟩
  · exact ⟨statementNote_holds ν C R stmt env,
      .cons (blockFrameNote_holds ν C R rest env) targetStackRole.tail,inventory.target.cells⟩

end Host.Ts.Owned.Annotated
