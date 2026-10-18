import host.ts.RenameRuntimePureEffects
import host.ts.RenameParametricArithmeticStep
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Both effect facts are derived from the source case and the initial state
relation. The certificate quantifies over all successful original steps. -/
structure PureRuntimeCase (F : Ffi) (source target : St F.S) : Prop where
  source : PureRuntimeStep F source
  target : PureRuntimeStep F target

section
variable {F : Ffi} {NR : NumV → NumV → Prop} {FR : Ren → F.S → F.S → Prop} {R : Ren}
  {live framed : Nat → Prop} {before after : List Val} {old old' : List Event} {s₀ s : St F.S}

theorem PureRuntimeCase.literal (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (literal : Lit) (value : Val) (env : Env) (parsed : LiteralValue literal value)
    (control : s₀.ctl = .ev (.lit literal) env) : PureRuntimeCase F s₀ s :=
  ⟨.literal F s₀ literal value env parsed control,
    .literal F s literal value (R.env env) parsed (h.control_view control).ev_view⟩
theorem PureRuntimeCase.variable (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (value : Val) (control : s₀.ctl = .ev (.id name) env)
    (lookup : lookupEnv name env = some a) (cell : s₀.heap.get a = some (.cell (some value))) : PureRuntimeCase F s₀ s := by
  have support := h.controlLive
  rw [control] at support
  obtain ⟨targetValue,targetCell,_,_⟩ := h.heap.readCell a value (env_lookup_live name env a support.2.1 lookup) cell
  have targetLookup : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,lookup]; rfl
  exact ⟨.variable F s₀ name env a value control lookup cell,
    .variable F s name (R.env env) (R.a a) targetValue (h.control_view control).ev_view targetLookup targetCell⟩
theorem PureRuntimeCase.this (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (env : Env) (a : Nat) (value : Val) (control : s₀.ctl = .ev .this env)
    (lookup : lookupEnv nThis env = some a) (cell : s₀.heap.get a = some (.cell (some value))) : PureRuntimeCase F s₀ s := by
  have support := h.controlLive
  rw [control] at support
  obtain ⟨targetValue,targetCell,_,_⟩ := h.heap.readCell a value (env_lookup_live nThis env a support.2.1 lookup) cell
  have targetLookup : lookupEnv nThis (R.env env) = some (R.a a) := by rw [lookupEnv_map,lookup]; rfl
  exact ⟨.this F s₀ env a value control lookup cell,
    .this F s (R.env env) (R.a a) targetValue (h.control_view control).ev_view targetLookup targetCell⟩
theorem PureRuntimeCase.descent (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (d : Descent) (env : Env) (control : s₀.ctl = .ev d.whole env) : PureRuntimeCase F s₀ s :=
  ⟨.descent F s₀ d env control,.descent F s d (R.env env) (h.control_view control).ev_view⟩
theorem PureRuntimeCase.statement (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (a : StatementAction) (env : Env) (control : s₀.ctl = .ex a.statement env) : PureRuntimeCase F s₀ s :=
  ⟨.statement F s₀ a env control,.statement F s a (R.env env) (h.control_view control).ex_view⟩
theorem PureRuntimeCase.binaryLeft (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (op : BinOp) (right : Expr) (env : Env) (frames : List Frame) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .e (.binL op right env)::frames) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.binL_view] at targetStack
  exact ⟨.binaryLeft F s₀ value op right env frames control stack,
    .binaryLeft F s targetValue op right (R.env env) targetFrames targetControl targetStack⟩
theorem PureRuntimeCase.arguments (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (kind : Nat) (fn this : Val) (acc : List Val) (rest : List Elem) (env : Env)
    (frames : List Frame) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .c (.args kind fn this acc rest env)::frames) (ordinary : kind ≤ 1) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetFn,targetThis,targetAcc,frameEq,_,_,_⟩ := frameRelation.args_view
  rw [frameEq] at targetStack
  exact ⟨.arguments F s₀ value kind fn this acc rest env frames control stack ordinary,
    .arguments F s targetValue kind targetFn targetThis targetAcc rest (R.env env) targetFrames targetControl targetStack ordinary⟩
theorem PureRuntimeCase.callStart (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (mode : CallStart) (a : Nat) (this : Val) (args : List Elem) (env : Env) (frames : List Frame)
    (control : s₀.ctl = .ret (.obj a)) (stack : s₀.stack = mode.frame this args env::frames) : PureRuntimeCase F s₀ s := by
  obtain ⟨value,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetThis,frameEq,_⟩ := frameRelation.callStart_view mode
  rw [frameEq] at targetStack
  exact ⟨.callStart F s₀ mode a this args env frames control stack,
    .callStart F s mode (R.a a) targetThis args (R.env env) targetFrames targetControl targetStack⟩
theorem PureRuntimeCase.blockNext (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (stmt : Stmt) (rest : List Stmt) (env : Env) (frames : List Frame)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .s (.block (stmt::rest) env)::frames) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.block_view] at targetStack
  exact ⟨.blockNext F s₀ value stmt rest env frames control stack,
    .blockNext F s targetValue stmt rest (R.env env) targetFrames targetControl targetStack⟩
theorem PureRuntimeCase.declaration (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (kind : DeclKind) (p : Pat) (rest : List (Pat × Option Expr)) (env : Env) (frames : List Frame)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .s (.decl kind p rest env)::frames)
    (ordinary : isUsing kind = false) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.decl_view] at targetStack
  exact ⟨.declaration F s₀ value kind p rest env frames control stack ordinary,
    .declaration F s targetValue kind p rest (R.env env) targetFrames targetControl targetStack ordinary⟩
theorem PureRuntimeCase.returnExit (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (env : Env) (exit : ReturnExit) (frames : List Frame) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = exit.frame env::frames) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.returnExit_view] at targetStack
  exact ⟨.returnExit F s₀ value env exit frames control stack,
    .returnExit F s targetValue (R.env env) exit targetFrames targetControl targetStack⟩
theorem PureRuntimeCase.returnUnwind (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (value : Val) (env : Env) (unwind : ReturnUnwind) (frames : List Frame)
    (control : s₀.ctl = .abr (.ret value)) (stack : s₀.stack = unwind.frame env::frames) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).returnAbrupt_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.returnUnwind_view] at targetStack
  exact ⟨.returnUnwind F s₀ value env unwind frames control stack,
    .returnUnwind F s targetValue (R.env env) unwind targetFrames targetControl targetStack⟩
theorem PureRuntimeCase.methodDescent (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (obj : Expr) (name : Name) (args : List Elem) (env : Env) (optionalObj optionalCall : Bool)
    (control : s₀.ctl = .ev (.call (.member obj name optionalObj) args optionalCall) env) : PureRuntimeCase F s₀ s :=
  ⟨.methodDescent F s₀ obj name args env optionalObj optionalCall control,
    .methodDescent F s obj name args (R.env env) optionalObj optionalCall (h.control_view control).ev_view⟩
theorem PureRuntimeCase.methodData (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (name : Name) (args : List Elem) (env : Env) (optionalObj optionalCall : Bool)
    (value : Val) (w e : Bool) (frames : List Frame) (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.member (.str name) args env optionalObj optionalCall)::frames)
    (object : s₀.heap.get a = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (field : findProp (.str name) o₀.props = some (.data value w e)) : PureRuntimeCase F s₀ s := by
  obtain ⟨v,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.callMember_view] at targetStack
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  obtain ⟨o,targetObject,objectRelation,_⟩ := h.heap.readOrdinary a o₀ alive object ordinary
  obtain ⟨targetValue,targetField,_⟩ := objectRelation.properties.find_data name value w e field
  exact ⟨.methodData F s₀ a o₀ name args env optionalObj optionalCall value w e frames control stack object ordinary field,
    .methodData F s (R.a a) o name args (R.env env) optionalObj optionalCall targetValue w e targetFrames
      targetControl targetStack targetObject (objectRelation.ordinary ordinary) targetField⟩
theorem PureRuntimeCase.arithmetic (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (op : ArithmeticKind) (a b : NumV) (frames : List Frame) (control : s₀.ctl = .ret (.num b))
    (stack : s₀.stack = .e (.binR op.jsOp (.num a))::frames) : PureRuntimeCase F s₀ s := by
  obtain ⟨targetValue,targetControl,rightRelation⟩ := (h.control_view control).ret_view
  obtain ⟨targetB,rfl,_⟩ := rightRelation.num_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetLeft,frameEq,leftRelation⟩ := frameRelation.binR_view
  obtain ⟨targetA,rfl,_⟩ := leftRelation.num_view
  rw [frameEq] at targetStack
  exact ⟨.arithmetic F s₀ op a b frames control stack,
    .arithmetic F s op targetA targetB targetFrames targetControl targetStack⟩
end

theorem PureRuntimeCase.effects {F : Ffi} {s₀ s result₀ result : St F.S} {C₀ C D₀ D : CSrv}
    (cases : PureRuntimeCase F s₀ s)
    (sourceRun : interpC (step F s₀).run C₀ = some (result₀,D₀))
    (targetRun : interpC (step F s).run C = some (result,D)) :
    RuntimePureEffects s₀ result₀ ∧ RuntimePureEffects s result :=
  ⟨cases.source C₀ result₀ D₀ sourceRun,cases.target C result D targetRun⟩
end Host.Ts.Owned.Annotated
