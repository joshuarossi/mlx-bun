import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeArguments
import host.ts.RenameRuntimeBinding
import host.ts.RenameRuntimeStatements
import host.ts.RenameParametricArrayBinding

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def arrayBindingFrameNote (patterns : List (Option Pat)) (roles : List Value) (env : Env)
    (mode : BindMode) (kind : DeclKind) : Tree :=
  .node "Frame.b" [.node "BindF.arr" [.atom (List (Option Pat)) patterns,.atom (Option Pat) none,
    valuesNote roles,environmentNote env,.atom BindMode mode,.atom DeclKind kind]]

def RuntimeNotes.arrayBinding (notes : RuntimeNotes) : List (Option Pat) → List Value → Env → BindMode → DeclKind → RuntimeNotes
  | [], _, _, _, _ => notes.returning .undef
  | none::patterns, roles, env, mode, kind => notes.arrayBinding patterns roles.tail env mode kind
  | some pattern::patterns, roles, env, mode, kind =>
      {notes with control := bindingNote pattern (nthD .undef roles 0) env mode kind,stack := arrayBindingFrameNote patterns roles.tail env mode kind::notes.stack}

theorem RuntimeNotes.arrayBinding_cells (notes : RuntimeNotes) (patterns : List (Option Pat))
    (roles : List Value) (env : Env) (mode : BindMode) (kind : DeclKind) :
    (notes.arrayBinding patterns roles env mode kind).cells = notes.cells := by
  induction patterns generalizing roles with
  | nil => rfl
  | cons pattern patterns ih => cases pattern with
    | none => exact ih roles.tail
    | some pattern => rfl

theorem arrayBindingFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    (patterns : List (Option Pat)) (roles : List Value) (env : Env) (mode : BindMode) (kind : DeclKind)
    {values : List Val} (held : ListR (fun role value => role.Holds ν C R value) roles values) :
    (arrayBindingFrameNote patterns roles env mode kind).Holds ν C R
      (Encode.frame (.b (.arr patterns none values (R.env env) mode kind))) :=
  .node _ (.cons (.node _ (.cons (.atom (List (Option Pat)) patterns) (.cons (.atom (Option Pat) none)
    (.cons (valuesNote_holds held) (.cons (environmentNote_holds ν C R env)
      (.cons (.atom BindMode mode) (.cons (.atom DeclKind kind) .nil))))))) .nil)

theorem arrayBindingFrameNote_view {ν : Nat → F64} {C : CSrv} {R : Ren}
    (patterns : List (Option Pat)) (roles : List Value) (env : Env) (mode : BindMode) (kind : DeclKind)
    {values : List Val}
    (held : (arrayBindingFrameNote patterns roles env mode kind).Holds ν C R
      (Encode.frame (.b (.arr patterns none values (R.env env) mode kind)))) :
    ListR (fun role value => role.Holds ν C R value) roles values := by
  cases held with | node _ outer => cases outer with | cons inner _ =>
    cases inner with | node _ fields => cases fields with | cons _ fields =>
      cases fields with | cons _ fields => cases fields with | cons values _ => exact valuesNote_view values

private theorem binding_roles_split {ν : Nat → F64} {C : CSrv} {R : Ren}
    {roles : List Value} {values : List Val}
    (held : ListR (fun role value => role.Holds ν C R value) roles values) :
    (nthD .undef roles 0).Holds ν C R (nthD .undef values 0) ∧
      ListR (fun role value => role.Holds ν C R value) roles.tail values.tail := by
  cases held with
  | nil => exact ⟨.undef,.nil⟩
  | cons head tail => exact ⟨head,tail⟩

theorem RuntimeNotes.Holds.arrayBinding {S : Type} {notes : RuntimeNotes} {ν : Nat → F64}
    {C : CSrv} {R : Ren} {s : St S} (inventory : notes.Holds ν C R s)
    (patterns : List (Option Pat)) (roles : List Value) (values : List Val) (env : Env) (mode : BindMode) (kind : DeclKind)
    (held : ListR (fun role value => role.Holds ν C R value) roles values) :
    (notes.arrayBinding patterns roles env mode kind).Holds ν C R
      (Parametric.arrayBinding s patterns values (R.env env) mode kind) := by
  induction patterns generalizing roles values with
  | nil => exact ⟨returnNote_holds .undef,inventory.stack,inventory.cells⟩
  | cons pattern patterns ih =>
    have split := binding_roles_split held
    cases pattern with
    | none => exact ih roles.tail values.tail split.2
    | some pattern => exact ⟨bindingNote_holds pattern env mode kind split.1,
        .cons (arrayBindingFrameNote_holds patterns roles.tail env mode kind split.2) inventory.stack,inventory.cells⟩

theorem array_binding_effects {S : Type} (s : St S) (patterns : List (Option Pat))
    (values : List Val) (env : Env) (mode : BindMode) (kind : DeclKind) :
    RuntimePureEffects s (Parametric.arrayBinding s patterns values env mode kind) := by
  induction patterns generalizing values with
  | nil => exact ⟨rfl,rfl,rfl⟩
  | cons pattern patterns ih => cases pattern with
    | none => exact ih values.tail
    | some pattern => exact ⟨rfl,rfl,rfl⟩

/-- The source-owned array's retained element meanings seed the actual
destructuring scheduler, including holes and exhausted arrays. -/
theorem RetainedInventory.array_binding_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (patterns : List (Option Pat)) (a : Nat) (o₀ : Obj) (values : List Val) (roles : List Value)
    (env : Env) (mode : BindMode) (kind : DeclKind)
    (control : s₀.ctl = .bind (.array patterns none) (.obj a) env mode kind)
    (object : s₀.heap.get a = some (.obj o₀)) (array : o₀.kind = .array values)
    (entry : notes.arrays.owners a = some roles) :
    ∃ targetValues,
      let t₀ := Parametric.arrayBinding s₀ patterns values env mode kind
      let t := Parametric.arrayBinding s patterns targetValues (R.env env) mode kind
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime (notes.runtime.arrayBinding patterns roles env mode kind)) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨sourceObject,targetObject,sourceValues,targetValues,sourceRead,sourceKind,targetRead,targetKind,sourceRoles,targetRoles,pairs,valuesLive⟩ :=
    inventory.arrays.selected a roles entry
  have same := HObj.obj.inj (Option.some.inj (sourceRead.symm.trans object))
  subst sourceObject
  have same := Kind.array.inj (sourceKind.symm.trans array)
  subst sourceValues
  obtain ⟨targetValue,targetControl,valueRelation⟩ := (h.control_view control).bind_view
  cases valueRelation
  have sourceEq := step_bind_array_eq F s₀ patterns a o₀ values env mode kind control object array
  have targetEq := step_bind_array_eq F s patterns (R.a a) targetObject targetValues (R.env env) mode kind targetControl targetRead targetKind
  have sourceRun : interpC (step F s₀).run C₀ = some (Parametric.arrayBinding s₀ patterns values env mode kind,C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some (Parametric.arrayBinding s patterns targetValues (R.env env) mode kind,C) := by rw [targetEq]; rfl
  have support := h.controlLive
  rw [control] at support
  have post := arrayBinding_roles h patterns values targetValues env mode kind pairs valuesLive support.2.2.1
  have runtime : RuntimeInventory (notes.runtime.arrayBinding patterns roles env mode kind) ν₀ ν C₀ C R live
      (Parametric.arrayBinding s₀ patterns values env mode kind) (Parametric.arrayBinding s patterns targetValues (R.env env) mode kind) := by
    refine ⟨?_,?_,inventory.runtime.target.arrayBinding patterns roles targetValues env mode kind targetRoles⟩
    · simpa only [RuntimeNotes.arrayBinding_cells] using inventory.runtime.keyLive
    · simpa only [identity_environment] using inventory.runtime.source.arrayBinding patterns roles values env mode kind sourceRoles
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq (array_binding_effects s₀ patterns values env mode kind),
      .of_pure F s _ targetEq (array_binding_effects s patterns targetValues (R.env env) mode kind)⟩
  exact ⟨targetValues,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

/-- Array binding continuations retain the remaining element meanings in the
saved frame; selected values cannot acquire a new role at the next binding. -/
theorem RetainedInventory.array_binding_next_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (patterns : List (Option Pat)) (values : List Val) (roles : List Value)
    (env : Env) (mode : BindMode) (kind : DeclKind) (frames : List Frame) (tail : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .b (.arr patterns none values env mode kind)::frames)
    (stackNotes : notes.runtime.stack = arrayBindingFrameNote patterns roles env mode kind::tail) :
    ∃ targetValues targetFrames,
      let t₀ := Parametric.arrayBinding {s₀ with stack := frames} patterns values env mode kind
      let t := Parametric.arrayBinding {s with stack := targetFrames} patterns targetValues (R.env env) mode kind
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ({notes.runtime with stack := tail}.arrayBinding patterns roles env mode kind)) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨targetValues,frameEq,_⟩ := frameRelation.arrayBinding_view
  rw [frameEq] at targetStack
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have sourceRoles := arrayBindingFrameNote_view (ν:=ν₀) (C:=C₀) (R:=identity) patterns roles env mode kind
    (by simpa only [identity_environment] using sourceNotes.head)
  have targetRoles := arrayBindingFrameNote_view patterns roles env mode kind targetNotes.head
  have support := h.stackLive
  rw [stack] at support
  have post := arrayBinding_roles (h.restack tailRelation support.2) patterns values targetValues env mode kind
    (annotated_values_paired sourceRoles targetRoles) (vals_support_of _ support.1.1.2.2.1) support.1.1.2.2.2.1
  have sourceEq := step_array_binding_next_eq F s₀ value patterns values env mode kind frames control stack
  have targetEq := step_array_binding_next_eq F s targetValue patterns targetValues (R.env env) mode kind targetFrames targetControl targetStack
  have sourceRun : interpC (step F s₀).run C₀ = some (Parametric.arrayBinding {s₀ with stack := frames} patterns values env mode kind,C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some (Parametric.arrayBinding {s with stack := targetFrames} patterns targetValues (R.env env) mode kind,C) := by rw [targetEq]; rfl
  have popped : RuntimeInventory {notes.runtime with stack := tail} ν₀ ν C₀ C R live {s₀ with stack := frames} {s with stack := targetFrames} :=
    ⟨inventory.runtime.keyLive,⟨inventory.runtime.source.control,sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨inventory.runtime.target.control,targetNotes.tail,inventory.runtime.target.cells⟩⟩
  have runtime : RuntimeInventory ({notes.runtime with stack := tail}.arrayBinding patterns roles env mode kind) ν₀ ν C₀ C R live
      (Parametric.arrayBinding {s₀ with stack := frames} patterns values env mode kind)
      (Parametric.arrayBinding {s with stack := targetFrames} patterns targetValues (R.env env) mode kind) := by
    refine ⟨?_,?_,popped.target.arrayBinding patterns roles targetValues env mode kind targetRoles⟩
    · simpa only [RuntimeNotes.arrayBinding_cells] using popped.keyLive
    · simpa only [identity_environment] using popped.source.arrayBinding patterns roles values env mode kind sourceRoles
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ((show RuntimePureEffects s₀ {s₀ with stack := frames} from ⟨rfl,rfl,rfl⟩).trans
        (array_binding_effects {s₀ with stack := frames} patterns values env mode kind)),
      .of_pure F s _ targetEq ((show RuntimePureEffects s {s with stack := targetFrames} from ⟨rfl,rfl,rfl⟩).trans
        (array_binding_effects {s with stack := targetFrames} patterns targetValues (R.env env) mode kind))⟩
  exact ⟨targetValues,targetFrames,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

private theorem statement_advance_inventory {S : Type} {notes : RuntimeNotes} {ν : Nat → F64}
    {C : CSrv} {R : Ren} {s : St S} (inventory : notes.Holds ν C R s) (action : StatementAction) (env : Env) :
    (notes.statement action env).Holds ν C R (action.advance s (R.env env)) := by
  refine ⟨statementControlNote_holds ν C R action env,?_,inventory.cells⟩
  simpa only [List.map_append,RuntimeNotes.statement,StatementAction.advance,St.go] using
    (statementFrameNotes_holds ν C R action env).append inventory.stack

/-- The original declaration scheduler either completes or schedules its next
initializer/binding. The retained caller frames and heap roles survive. -/
theorem RetainedInventory.declaration_next_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (kind : DeclKind) (rest : List (Pat × Option Expr)) (env : Env) (frames : List Frame)
    (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .s (.declNext kind rest env)::frames) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := (declarationAction kind rest).advance {s₀ with stack := frames} env
      let t := (declarationAction kind rest).advance {s with stack := targetFrames} (R.env env)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ({notes.runtime with stack := tail}.statement (declarationAction kind rest) env)) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.declNext_view] at targetStack
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have support := h.stackLive
  rw [stack] at support
  have post := (declarationAction kind rest).advance_roles (h.restack tailRelation support.2) env support.1.1.2.2.1
  have sourceEq := step_declaration_next_eq F s₀ value kind rest env frames control stack
  have targetEq := step_declaration_next_eq F s targetValue kind rest (R.env env) targetFrames targetControl targetStack
  have sourceRun : interpC (step F s₀).run C₀ = some ((declarationAction kind rest).advance {s₀ with stack := frames} env,C₀) := by rw [sourceEq]; rfl
  have targetRun : interpC (step F s).run C = some ((declarationAction kind rest).advance {s with stack := targetFrames} (R.env env),C) := by rw [targetEq]; rfl
  have popped : RuntimeInventory {notes.runtime with stack := tail} ν₀ ν C₀ C R live {s₀ with stack := frames} {s with stack := targetFrames} :=
    ⟨inventory.runtime.keyLive,⟨inventory.runtime.source.control,sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨inventory.runtime.target.control,targetNotes.tail,inventory.runtime.target.cells⟩⟩
  have runtime : RuntimeInventory ({notes.runtime with stack := tail}.statement (declarationAction kind rest) env) ν₀ ν C₀ C R live
      ((declarationAction kind rest).advance {s₀ with stack := frames} env)
      ((declarationAction kind rest).advance {s with stack := targetFrames} (R.env env)) := by
    refine ⟨popped.keyLive,?_,statement_advance_inventory popped.target (declarationAction kind rest) env⟩
    simpa only [identity_environment] using statement_advance_inventory popped.source (declarationAction kind rest) env
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ sourceEq ⟨rfl,rfl,rfl⟩,.of_pure F s _ targetEq ⟨rfl,rfl,rfl⟩⟩
  exact ⟨targetFrames,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
