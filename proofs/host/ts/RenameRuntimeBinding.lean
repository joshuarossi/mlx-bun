import host.ts.RenameRuntimeDispatch
import host.ts.RenameHeapInventory
import host.ts.RenameParametricDeclarations
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def bindingNote (pattern : Pat) (role : Value) (env : Env) (mode : BindMode) (kind : DeclKind) : Tree :=
  .node "Ctl.bind" [.atom Pat pattern,.value role,environmentNote env,.atom BindMode mode,.atom DeclKind kind]
def declarationNextNote (kind : DeclKind) (rest : List (Pat × Option Expr)) (env : Env) : Tree :=
  .node "Frame.s" [.node "StmtF.declNext" [.atom DeclKind kind,.atom (List (Pat × Option Expr)) rest,environmentNote env]]
def RuntimeNotes.bindValue (notes : RuntimeNotes) (role : Value) (pattern : Pat) (kind : DeclKind)
    (rest : List (Pat × Option Expr)) (env : Env) (tail : List Tree) : RuntimeNotes :=
  {notes with control := bindingNote pattern role env .init kind,stack := declarationNextNote kind rest env::tail}
def RuntimeNotes.initialized (notes : RuntimeNotes) (address : Nat) (role : Value) : RuntimeNotes :=
  {notes with control := returnNote .undef,cells := notes.cells.write address role}

theorem bindingNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (pattern : Pat) (env : Env) (mode : BindMode) (kind : DeclKind) (h : role.Holds ν C R value) :
    (bindingNote pattern role env mode kind).Holds ν C R (Encode.ctl (.bind pattern value (R.env env) mode kind)) :=
  .node _ (.cons (.atom Pat pattern) (.cons (.value h) (.cons (environmentNote_holds ν C R env)
    (.cons (.atom BindMode mode) (.cons (.atom DeclKind kind) .nil)))))

theorem bindingNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    {pattern : Pat} {env₀ env : Env} {mode : BindMode} {kind : DeclKind}
    (h : (bindingNote pattern role env₀ mode kind).Holds ν C R (Encode.ctl (.bind pattern value env mode kind))) :
    role.Holds ν C R value := by
  cases h with | node _ fields =>
    cases fields with | cons _ fields =>
      cases fields with | cons hv _ => cases hv with | value hv => exact hv

theorem declarationNextNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren)
    (kind : DeclKind) (rest : List (Pat × Option Expr)) (env : Env) :
    (declarationNextNote kind rest env).Holds ν C R (Encode.frame (.s (.declNext kind rest (R.env env)))) :=
  .node _ (.cons (.node _ (.cons (.atom DeclKind kind) (.cons (.atom (List (Pat × Option Expr)) rest)
    (.cons (environmentNote_holds ν C R env) .nil)))) .nil)

/-- A declaration transfers its computed value's role into binding control;
its fixed meaning is retained until the actual cell initialization. -/
theorem RuntimeInventory.declaration_value_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (kind : DeclKind) (pattern : Pat) (rest : List (Pat × Option Expr))
    (env : Env) (frames : List Frame) (headNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .s (.decl kind pattern rest env)::frames)
    (notUsing : isUsing kind = false) (controlNote : notes.control = returnNote role)
    (stackNotes : notes.stack = headNote::tailNotes) :
    ∃ targetValue targetFrames,
      interpC (step F s₀).run C₀ = some (declarationValue {s₀ with stack := frames} kind pattern rest env value,C₀) ∧
      interpC (step F s).run C = some (declarationValue {s with stack := targetFrames} kind pattern rest (R.env env) targetValue,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (declarationValue {s₀ with stack := frames} kind pattern rest env value)
        (declarationValue {s with stack := targetFrames} kind pattern rest (R.env env) targetValue) ∧
      RuntimeInventory (notes.bindValue role pattern kind rest env tailNotes) ν₀ ν C₀ C R live
        (declarationValue {s₀ with stack := frames} kind pattern rest env value)
        (declarationValue {s with stack := targetFrames} kind pattern rest (R.env env) targetValue) := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.decl_view] at targetStack
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceRole := returnNote_view sourceControl
  have targetRole := returnNote_view targetControlRole
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  obtain ⟨result,sourceRun,targetRun,post⟩ := step_declaration_value_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h value kind pattern rest env frames control stack notUsing
  have actual : interpC (step F s).run C = some
      (declarationValue {s with stack := targetFrames} kind pattern rest (R.env env) targetValue,C) := by
    rw [step_declaration_value_eq F s targetValue kind pattern rest (R.env env) targetFrames targetControl targetStack notUsing]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post
  refine ⟨targetValue,targetFrames,sourceRun,actual,post,inventory.keyLive,?_,?_⟩
  · exact ⟨by simpa only [RuntimeNotes.bindValue,declarationValue,St.push,St.go,identity_environment] using bindingNote_holds pattern env .init kind sourceRole,
      .cons (by simpa only [identity_environment] using declarationNextNote_holds ν₀ C₀ identity kind rest env)
        sourceStack.tail,inventory.source.cells⟩
  · exact ⟨bindingNote_holds pattern env .init kind targetRole,
      .cons (declarationNextNote_holds ν C R kind rest env) targetStackRole.tail,inventory.target.cells⟩

/-- Initializing the lexical cell consumes the retained binding role. All
cell/private/builtin-capture inventories are returned with the one cell entry
updated; no post-store annotation is supplied. -/
theorem RuntimeInventory.init_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (privates : PrivateNotes) (captures : NativeCaptureNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (heapInventory : HeapInventory ⟨notes.cells,privates,captures⟩ ν₀ ν C₀ C R live s₀ s)
    (name : Name) (env : Env) (address : Nat) (value : Val) (prior : Option Val) (kind : DeclKind) (role : Value)
    (control : s₀.ctl = .bind (.id name) value env .init kind) (lookup : lookupEnv name env = some address)
    (cell : s₀.heap.get address = some (.cell prior))
    (controlNote : notes.control = bindingNote (.id name) role env .init kind)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetValue,
      interpC (step F s₀).run C₀ = some ((s₀.setCell address value).ret .undef,C₀) ∧
      interpC (step F s).run C = some ((s.setCell (R.a address) targetValue).ret .undef,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ((s₀.setCell address value).ret .undef) ((s.setCell (R.a address) targetValue).ret .undef) ∧
      RuntimeInventory (notes.initialized address role) ν₀ ν C₀ C R live
        ((s₀.setCell address value).ret .undef) ((s.setCell (R.a address) targetValue).ret .undef) ∧
      HeapInventory ((HeapNotes.mk notes.cells privates captures).writeCell address role) ν₀ ν C₀ C R live
        ((s₀.setCell address value).ret .undef) ((s.setCell (R.a address) targetValue).ret .undef) := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).bind_view
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceRole := bindingNote_view sourceControl
  have targetRole := bindingNote_view targetControlRole
  obtain ⟨result,sourceRun,targetRun,post,heap⟩ := heapInventory.init_step F FR _ ν₀ ν C₀ C R live framed
    before after old old' s₀ s h name env address value prior kind role control lookup cell sourceRole
    (by simpa only [targetControl,initializedValue] using targetRole) sourceBound targetBound
  obtain ⟨_,actual,_⟩ := step_bind_init_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
    s₀ s h name value targetValue env kind address prior control targetControl lookup cell sourceBound targetBound
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post heap
  refine ⟨targetValue,sourceRun,actual,post,?_,heap⟩
  exact ⟨heap.cells.keyLive,⟨returnNote_holds .undef,inventory.source.stack,heap.cells.source⟩,
    ⟨returnNote_holds .undef,inventory.target.stack,heap.cells.target⟩⟩

end Host.Ts.Owned.Annotated
