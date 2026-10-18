import host.ts.RenameRuntimeParameterNotes
import host.ts.RenameParametricParameterStep
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def parameterRole : List Value → Value
  | [] => .undef
  | role::_ => role
def RuntimeNotes.parameterArgument (notes : RuntimeNotes) (fn : Func) (name : Name) (params : List Pat)
    (roles : List Value) (env : Env) (tail : List Tree) : RuntimeNotes :=
  {notes with control := bindingNote (.id name) (parameterRole roles) env .init .let_,stack := parameterFrameNote fn params roles.tail env::tail}
def RuntimeNotes.parameterDefault (notes : RuntimeNotes) (fn : Func) (pattern : Pat) (default : Expr)
    (params : List Pat) (roles : List Value) (env : Env) (tail : List Tree) : RuntimeNotes :=
  {notes with control := expressionNote default env,stack := parameterDefaultFrameNote fn pattern params roles.tail env::tail}
def RuntimeNotes.parameterDefaultReturn (notes : RuntimeNotes) (fn : Func) (pattern : Pat) (params : List Pat)
    (roles : List Value) (role : Value) (env : Env) (tail : List Tree) : RuntimeNotes :=
  {notes with control := bindingNote pattern role env .init .let_,stack := parameterFrameNote fn params roles env::tail}

theorem parameterRole_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : List Value} {args : List Val}
    (h : ListR (fun role value => role.Holds ν C R value) roles args) :
    (parameterRole roles).Holds ν C R (nthD .undef args 0) := by
  cases h with
  | nil => exact .undef
  | cons head _ => exact head
theorem parameterRoles_tail {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : List Value} {args : List Val}
    (h : ListR (fun role value => role.Holds ν C R value) roles args) :
    ListR (fun role value => role.Holds ν C R value) roles.tail args.tail := by
  cases h with
  | nil => exact .nil
  | cons _ tail => exact tail

theorem RuntimeInventory.parameter_stack_roles {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {FR : Ren → S → S → Prop} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn : Func) (params : List Pat) (args : List Val) (env : Env) (frames : List Frame)
    (roles : List Value) (tailNotes : List Tree)
    (stack : s₀.stack = .k (.params fn params args env)::frames)
    (stackNotes : notes.stack = parameterFrameNote fn params roles env::tailNotes) :
    ∃ targetArgs targetFrames,
      s.stack = .k (.params fn params targetArgs (R.env env))::targetFrames ∧
      ListR (fun role value => role.Holds ν₀ C₀ identity value) roles args ∧
      ListR (fun role value => role.Holds ν C R value) roles targetArgs ∧
      ForestHolds ν₀ C₀ identity tailNotes (frames.map Encode.frame) ∧
      ForestHolds ν C R tailNotes (targetFrames.map Encode.frame) := by
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetArgs,frameEq,_⟩ := frameRelation.params_view
  rw [frameEq] at targetStack
  have sourceNotes := inventory.source.stack
  have targetNotes := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  refine ⟨targetArgs,targetFrames,targetStack,?_,?_,sourceNotes.tail,targetNotes.tail⟩
  · exact parameterFrameNote_view fn params roles env args
      (by simpa only [identity_environment] using sourceNotes.head)
  · exact parameterFrameNote_view fn params roles env targetArgs targetNotes.head

/-- The next parameter takes the existing argument role (or undefined for an
absent argument), then binding initialization records that same role. -/
theorem RuntimeInventory.parameter_id_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (fn : Func) (name : Name) (params : List Pat) (args : List Val) (env : Env)
    (frames : List Frame) (roles : List Value) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value) (stack : s₀.stack = .k (.params fn (.id name::params) args env)::frames)
    (stackNotes : notes.stack = parameterFrameNote fn (.id name::params) roles env::tailNotes) :
    ∃ result, interpC (step F s₀).run C₀ = some (Parametric.parameterArgument {s₀ with stack := frames} fn name params args env,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (Parametric.parameterArgument {s₀ with stack := frames} fn name params args env) result ∧
      RuntimeInventory (notes.parameterArgument fn name params roles env tailNotes) ν₀ ν C₀ C R live
        (Parametric.parameterArgument {s₀ with stack := frames} fn name params args env) result := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨targetArgs,targetFrames,targetStack,sourceRoles,targetRoles,sourceTail,targetTail⟩ :=
    inventory.parameter_stack_roles h fn (.id name::params) args env frames roles tailNotes stack stackNotes
  obtain ⟨left,right,related⟩ := step_parameter_id_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h value targetValue fn name params args targetArgs env frames targetFrames
    control targetControl stack targetStack
  refine ⟨_,left,right,related,inventory.keyLive,?_,?_⟩
  · exact ⟨by simpa only [identity_environment,RuntimeNotes.parameterArgument,Parametric.parameterArgument,St.go] using bindingNote_holds (.id name) env .init .let_ (parameterRole_holds sourceRoles),
      .cons (by simpa only [identity_environment] using parameterFrameNote_holds fn params roles.tail env args.tail (parameterRoles_tail sourceRoles))
        sourceTail,inventory.source.cells⟩
  · exact ⟨bindingNote_holds (.id name) env .init .let_ (parameterRole_holds targetRoles),
      .cons (parameterFrameNote_holds fn params roles.tail env targetArgs.tail (parameterRoles_tail targetRoles))
        targetTail,inventory.target.cells⟩

theorem RuntimeInventory.parameter_default_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (fn : Func) (pattern : Pat) (default : Expr) (params : List Pat)
    (args : List Val) (env : Env) (frames : List Frame) (roles : List Value) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .k (.params fn (.dflt pattern default::params) args env)::frames)
    (missing : nthD .undef args 0 = .undef)
    (stackNotes : notes.stack = parameterFrameNote fn (.dflt pattern default::params) roles env::tailNotes) :
    ∃ result, interpC (step F s₀).run C₀ = some (Parametric.parameterDefault {s₀ with stack := frames} fn pattern default params args env,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (Parametric.parameterDefault {s₀ with stack := frames} fn pattern default params args env) result ∧
      RuntimeInventory (notes.parameterDefault fn pattern default params roles env tailNotes) ν₀ ν C₀ C R live
        (Parametric.parameterDefault {s₀ with stack := frames} fn pattern default params args env) result := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨targetArgs,targetFrames,targetStack,sourceRoles,targetRoles,sourceTail,targetTail⟩ :=
    inventory.parameter_stack_roles h fn (.dflt pattern default::params) args env frames roles tailNotes stack stackNotes
  obtain ⟨left,right,related⟩ := step_parameter_default_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h value targetValue fn pattern default params args targetArgs env frames targetFrames
    control targetControl stack targetStack missing
  refine ⟨_,left,right,related,inventory.keyLive,?_,?_⟩
  · exact ⟨by simpa only [identity_environment,RuntimeNotes.parameterDefault,Parametric.parameterDefault,St.go] using expressionNote_holds ν₀ C₀ identity default env,
      .cons (by simpa only [identity_environment] using parameterDefaultFrameNote_holds fn pattern params roles.tail env args.tail (parameterRoles_tail sourceRoles))
        sourceTail,inventory.source.cells⟩
  · exact ⟨expressionNote_holds ν C R default env,
      .cons (parameterDefaultFrameNote_holds fn pattern params roles.tail env targetArgs.tail (parameterRoles_tail targetRoles))
        targetTail,inventory.target.cells⟩

theorem RuntimeInventory.parameter_default_return_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (fn : Func) (pattern : Pat) (params : List Pat) (args : List Val) (env : Env)
    (frames : List Frame) (roles : List Value) (role : Value) (tailNotes : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .k (.paramDflt fn pattern params args env)::frames)
    (controlNote : notes.control = returnNote role)
    (stackNotes : notes.stack = parameterDefaultFrameNote fn pattern params roles env::tailNotes) :
    ∃ result, interpC (step F s₀).run C₀ = some (Parametric.parameterDefaultReturn {s₀ with stack := frames} fn pattern params args env value,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (Parametric.parameterDefaultReturn {s₀ with stack := frames} fn pattern params args env value) result ∧
      RuntimeInventory (notes.parameterDefaultReturn fn pattern params roles role env tailNotes) ν₀ ν C₀ C R live
        (Parametric.parameterDefaultReturn {s₀ with stack := frames} fn pattern params args env value) result := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetArgs,frameEq,_⟩ := frameRelation.paramDflt_view
  rw [frameEq] at targetStack
  have sourceNotes := inventory.source.stack
  have targetNotes := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have sourceRoles := parameterDefaultFrameNote_view (ν := ν₀) (C := C₀) (R := identity) fn pattern params roles env args
    (by simpa only [identity_environment] using sourceNotes.head)
  have targetRoles := parameterDefaultFrameNote_view fn pattern params roles env targetArgs targetNotes.head
  have sourceRole := inventory.source.control
  have targetRole := inventory.target.control
  rw [controlNote,control] at sourceRole
  rw [controlNote,targetControl] at targetRole
  obtain ⟨left,right,related⟩ := step_parameter_default_return_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h value targetValue fn pattern params args targetArgs env frames targetFrames
    control targetControl stack targetStack
  refine ⟨_,left,right,related,inventory.keyLive,?_,?_⟩
  · exact ⟨by simpa only [identity_environment,RuntimeNotes.parameterDefaultReturn,Parametric.parameterDefaultReturn,St.go] using bindingNote_holds pattern env .init .let_ (returnNote_view sourceRole),
      .cons (by simpa only [identity_environment] using parameterFrameNote_holds fn params roles env args sourceRoles)
        sourceNotes.tail,inventory.source.cells⟩
  · exact ⟨bindingNote_holds pattern env .init .let_ (returnNote_view targetRole),
      .cons (parameterFrameNote_holds fn params roles env targetArgs targetRoles)
        targetNotes.tail,inventory.target.cells⟩

end Host.Ts.Owned.Annotated
