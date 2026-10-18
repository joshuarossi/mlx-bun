import host.ts.RenameRuntimeNotes
import host.ts.RenameParametricArguments
import host.ts.RenameShapeDimensionFields
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def valuesNote (roles : List Value) : Tree := .node "List" (roles.map Tree.value)
def callNote (fn this : Value) (args : List Value) : Tree :=
  .node "Ctl.call" [.value fn,.value this,valuesNote args]
def constructNote (fn : Value) (args : List Value) : Tree :=
  .node "Ctl.construct" [.value fn,valuesNote args,.value fn]
def argumentFrameNote (spread : Bool) (kind : Nat) (fn this : Value) (acc : List Value)
    (rest : List Elem) (env : Env) : Tree :=
  .node "Frame.c" [.node (if spread then "CallF.spread" else "CallF.args")
    [.atom Nat kind,.value fn,.value this,valuesNote acc,.atom (List Elem) rest,environmentNote env]]

def RuntimeNotes.arguments (notes : RuntimeNotes) (kind : Nat) (fn this : Value) (acc : List Value)
    (rest : List Elem) (env : Env) : RuntimeNotes :=
  match rest with
  | .expr e::r => {notes with control := expressionNote e env,stack := argumentFrameNote false kind fn this acc r env::notes.stack}
  | .spread e::r => {notes with control := expressionNote e env,stack := argumentFrameNote true kind fn this acc r env::notes.stack}
  | .hole::r => notes.arguments kind fn this (.undef::acc) r env
  | [] => {notes with control := if kind = 0 then callNote fn this acc.reverse else constructNote fn acc.reverse}

theorem RuntimeNotes.arguments_cells (notes : RuntimeNotes) (kind : Nat) (fn this : Value) (acc : List Value)
    (rest : List Elem) (env : Env) : (notes.arguments kind fn this acc rest env).cells = notes.cells := by
  induction rest generalizing acc with
  | nil => rfl
  | cons element rest ih => cases element with
    | expr _ => rfl
    | spread _ => rfl
    | hole => exact ih (.undef::acc)

section
variable {ν : Nat → F64} {C : CSrv} {R : Ren}

theorem value_fields_holds {roles : List Value} {values : List Val}
    (h : ListR (fun role value => role.Holds ν C R value) roles values) :
    ForestHolds ν C R (roles.map Tree.value) (values.map Encode.val) := by
  induction h with
  | nil => exact .nil
  | cons hv _ ih => exact .cons (.value hv) ih

theorem valuesNote_holds {roles : List Value} {values : List Val}
    (h : ListR (fun role value => role.Holds ν C R value) roles values) :
    (valuesNote roles).Holds ν C R (Encode.vals values) := .node _ (value_fields_holds h)

theorem valuesNote_view {roles : List Value} {values : List Val}
    (h : (valuesNote roles).Holds ν C R (Encode.vals values)) :
    ListR (fun role value => role.Holds ν C R value) roles values := by
  cases h with | node _ fields =>
    induction roles generalizing values with
    | nil => cases values with
      | nil => exact .nil
      | cons v vs => cases fields
    | cons role roles ih => cases values with
      | nil => cases fields
      | cons v vs => cases fields with | cons hv ht =>
        cases hv with | value hv => exact .cons hv (ih ht)

theorem value_roles_reverse {roles : List Value} {values : List Val}
    (h : ListR (fun role value => role.Holds ν C R value) roles values) :
    ListR (fun role value => role.Holds ν C R value) roles.reverse values.reverse := by
  induction h with
  | nil => exact .nil
  | cons hv hs ih => simpa only [List.reverse_cons] using ih.append (.cons hv .nil)

theorem callNote_holds {fn this : Value} {args : List Value} {f t : Val} {vs : List Val}
    (hf : fn.Holds ν C R f) (ht : this.Holds ν C R t)
    (ha : ListR (fun role value => role.Holds ν C R value) args vs) :
    (callNote fn this args).Holds ν C R (Encode.ctl (.call f t vs)) :=
  .node _ (.cons (.value hf) (.cons (.value ht) (.cons (valuesNote_holds ha) .nil)))

theorem constructNote_holds {fn : Value} {args : List Value} {f : Val} {vs : List Val}
    (hf : fn.Holds ν C R f) (ha : ListR (fun role value => role.Holds ν C R value) args vs) :
    (constructNote fn args).Holds ν C R (Encode.ctl (.construct f vs f)) :=
  .node _ (.cons (.value hf) (.cons (valuesNote_holds ha) (.cons (.value hf) .nil)))

theorem callNote_view {fn this : Value} {args : List Value} {f t : Val} {vs : List Val}
    (h : (callNote fn this args).Holds ν C R (Encode.ctl (.call f t vs))) :
    fn.Holds ν C R f ∧ this.Holds ν C R t ∧ ListR (fun role value => role.Holds ν C R value) args vs := by
  cases h with | node _ fields =>
    cases fields with | cons hf fields =>
      cases fields with | cons ht fields =>
        cases fields with | cons ha _ =>
          cases hf with | value hf =>
            cases ht with | value ht => exact ⟨hf,ht,valuesNote_view ha⟩

theorem constructNote_view {fn : Value} {args : List Value} {f nt : Val} {vs : List Val}
    (h : (constructNote fn args).Holds ν C R (Encode.ctl (.construct f vs nt))) :
    fn.Holds ν C R f ∧ fn.Holds ν C R nt ∧ ListR (fun role value => role.Holds ν C R value) args vs := by
  cases h with | node _ fields =>
    cases fields with | cons hf fields =>
      cases fields with | cons ha fields =>
        cases fields with | cons hnt _ =>
          cases hf with | value hf =>
            cases hnt with | value hnt => exact ⟨hf,hnt,valuesNote_view ha⟩

theorem argumentFrameNote_holds (spread : Bool) (kind : Nat) (fn this : Value) (acc : List Value)
    (rest : List Elem) (env : Env) (f t : Val) (vs : List Val)
    (hf : fn.Holds ν C R f) (ht : this.Holds ν C R t)
    (ha : ListR (fun role value => role.Holds ν C R value) acc vs) :
    (argumentFrameNote spread kind fn this acc rest env).Holds ν C R
      (Encode.frame (argumentFrame spread kind f t vs rest (R.env env))) := by
  cases spread <;> exact .node _ (.cons (.node _ (.cons (.atom Nat kind) (.cons (.value hf)
    (.cons (.value ht) (.cons (valuesNote_holds ha) (.cons (.atom (List Elem) rest)
      (.cons (environmentNote_holds ν C R env) .nil))))))) .nil)

theorem argumentFrameNote_view (spread : Bool) (kind : Nat) (fn this : Value) (acc : List Value)
    (rest : List Elem) (env : Env) (f t : Val) (vs : List Val)
    (h : (argumentFrameNote spread kind fn this acc rest env).Holds ν C R
      (Encode.frame (argumentFrame spread kind f t vs rest (R.env env)))) :
    fn.Holds ν C R f ∧ this.Holds ν C R t ∧ ListR (fun role value => role.Holds ν C R value) acc vs := by
  cases spread <;> cases h with | node _ outer =>
    cases outer with | cons inner _ =>
      cases inner with | node _ fields =>
        cases fields with | cons _ fields =>
          cases fields with | cons hf fields =>
            cases fields with | cons ht fields =>
              cases fields with | cons ha _ =>
                cases hf with | value hf =>
                  cases ht with | value ht => exact ⟨hf,ht,valuesNote_view ha⟩
end

/-- Argument scheduling preserves the exact role accumulator, including holes,
ordinary/spread continuations, and final left-to-right call argument order. -/
theorem RuntimeNotes.Holds.arguments {S : Type} {notes : RuntimeNotes} {ν : Nat → F64} {C : CSrv} {R : Ren} {s : St S}
    (h : notes.Holds ν C R s) (kind : Nat) (fn this : Value) (roles : List Value)
    (f t : Val) (values : List Val) (rest : List Elem) (env : Env)
    (hf : fn.Holds ν C R f) (ht : this.Holds ν C R t)
    (ha : ListR (fun role value => role.Holds ν C R value) roles values) :
    (notes.arguments kind fn this roles rest env).Holds ν C R
      (argumentState s kind f t values rest (R.env env)) := by
  induction rest generalizing roles values with
  | nil =>
    simp only [RuntimeNotes.arguments,argumentState]
    split
    · exact ⟨callNote_holds hf ht (value_roles_reverse ha),h.stack,h.cells⟩
    · exact ⟨constructNote_holds hf (value_roles_reverse ha),h.stack,h.cells⟩
  | cons element rest ih => cases element with
    | hole => exact ih (.undef::roles) (.undef::values) (.cons .undef ha)
    | expr expression =>
      exact ⟨expressionNote_holds ν C R expression env,
        .cons (argumentFrameNote_holds false kind fn this roles rest env f t values hf ht ha) h.stack,h.cells⟩
    | spread expression =>
      exact ⟨expressionNote_holds ν C R expression env,
        .cons (argumentFrameNote_holds true kind fn this roles rest env f t values hf ht ha) h.stack,h.cells⟩

/-- The current return annotation is copied into the original reversed
argument accumulator. Source-only frame facts derive the actual target step. -/
theorem RuntimeInventory.argument_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role fnRole thisRole : Value) (roles : List Value)
    (kind : Nat) (fn this : Val) (acc : List Val) (rest : List Elem) (env : Env) (frames : List Frame)
    (tailNotes : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .c (.args kind fn this acc rest env)::frames) (ordinary : kind ≤ 1)
    (controlNote : notes.control = returnNote role)
    (stackNotes : notes.stack = argumentFrameNote false kind fnRole thisRole roles rest env::tailNotes) :
    ∃ targetValue targetFn targetThis targetAcc targetFrames,
      interpC (step F s₀).run C₀ = some (argumentState {s₀ with stack := frames} kind fn this (value::acc) rest env,C₀) ∧
      interpC (step F s).run C = some (argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValue::targetAcc) rest (R.env env),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (argumentState {s₀ with stack := frames} kind fn this (value::acc) rest env)
        (argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValue::targetAcc) rest (R.env env)) ∧
      RuntimeInventory ({notes with stack := tailNotes}.arguments kind fnRole thisRole (role::roles) rest env) ν₀ ν C₀ C R live
        (argumentState {s₀ with stack := frames} kind fn this (value::acc) rest env)
        (argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValue::targetAcc) rest (R.env env)) := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetFn,targetThis,targetAcc,frameEq,_,_,_⟩ := frameRelation.args_view
  rw [frameEq] at targetStack
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
  obtain ⟨sourceHead,sourceTail⟩ :
      (argumentFrameNote false kind fnRole thisRole roles rest env).Holds ν₀ C₀ identity
        (Encode.frame (.c (.args kind fn this acc rest env))) ∧
      ForestHolds ν₀ C₀ identity tailNotes (frames.map Encode.frame) := by
    cases sourceStack with | cons head tail => exact ⟨head,tail⟩
  obtain ⟨targetHead,targetTail⟩ :
      (argumentFrameNote false kind fnRole thisRole roles rest env).Holds ν C R
        (Encode.frame (.c (.args kind targetFn targetThis targetAcc rest (R.env env)))) ∧
      ForestHolds ν C R tailNotes (targetFrames.map Encode.frame) := by
    cases targetStackRole with | cons head tail => exact ⟨head,tail⟩
  have sourceHead' := argumentFrameNote_view (ν:=ν₀) (C:=C₀) (R:=identity) false kind fnRole thisRole roles rest env fn this acc
    (by simpa only [identity_environment,argumentFrame,Bool.false_eq_true,↓reduceIte] using sourceHead)
  have targetHead' := argumentFrameNote_view false kind fnRole thisRole roles rest env targetFn targetThis targetAcc targetHead
  obtain ⟨result,sourceRun,targetRun,post⟩ := step_argument_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h value kind fn this acc rest env frames control stack ordinary
  have actual : interpC (step F s).run C = some
      (argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValue::targetAcc) rest (R.env env),C) := by
    rw [step_argument_eq F s targetValue kind targetFn targetThis targetAcc rest (R.env env) targetFrames targetControl targetStack ordinary]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post
  refine ⟨targetValue,targetFn,targetThis,targetAcc,targetFrames,sourceRun,actual,post,?_,?_,?_⟩
  · rw [RuntimeNotes.arguments_cells]
    exact inventory.keyLive
  · have popped : ({notes with stack := tailNotes}).Holds ν₀ C₀ identity {s₀ with stack := frames} :=
      ⟨inventory.source.control,sourceTail,inventory.source.cells⟩
    simpa only [identity_environment] using popped.arguments kind fnRole thisRole (role::roles)
      fn this (value::acc) rest env sourceHead'.1 sourceHead'.2.1 (.cons sourceRole sourceHead'.2.2)
  · have popped : ({notes with stack := tailNotes}).Holds ν C R {s with stack := targetFrames} :=
      ⟨inventory.target.control,targetTail,inventory.target.cells⟩
    exact popped.arguments kind fnRole thisRole (role::roles) targetFn targetThis (targetValue::targetAcc) rest env
      targetHead'.1 targetHead'.2.1 (.cons targetRole targetHead'.2.2)
theorem argument_of_getElem (i : Nat) {vs : List Val} {v : Val} (h : vs[i]? = some v) : Host.Ts.arg vs i = v := by
  induction i generalizing vs with
  | zero => cases vs with
    | nil => cases h
    | cons x xs => exact Option.some.inj h
  | succ i ih => cases vs with
    | nil => cases h
    | cons x xs => exact ih h

/-- Native ABI argument annotations are read from the retained call note;
there is no new choice of meaning at the native call. -/
theorem RuntimeInventory.call_argument_role {S : Type} {notes : RuntimeNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (fnRole thisRole : Value) (roles : List Value) (fn this : Val) (args : List Val)
    (control : s₀.ctl = .call fn this args) (note : notes.control = callNote fnRole thisRole roles)
    (i : Nat) (role : Value) (entry : roles[i]? = some role) :
    role.Holds ν₀ C₀ identity (callArgument s₀.ctl i) ∧ role.Holds ν C R (callArgument s.ctl i) := by
  have paired := inventory.control_pair
  rw [control] at paired
  obtain ⟨targetFn,targetThis,targetArgs,targetControl,_,_,_⟩ := paired.call_view
  have sourceNotes := inventory.source.control
  have targetNotes := inventory.target.control
  rw [note,control] at sourceNotes
  rw [note,targetControl] at targetNotes
  have sourceRoles := (callNote_view sourceNotes).2.2
  have targetRoles := (callNote_view targetNotes).2.2
  obtain ⟨value,valueAt,sourceRole⟩ := ListR.nth_some sourceRoles i role entry
  obtain ⟨targetValue,targetAt,targetRole⟩ := ListR.nth_some targetRoles i role entry
  rw [control,targetControl]
  change role.Holds ν₀ C₀ identity (Host.Ts.arg args i) ∧ role.Holds ν C R (Host.Ts.arg targetArgs i)
  rw [argument_of_getElem i valueAt,argument_of_getElem i targetAt]
  exact ⟨sourceRole,targetRole⟩
end Host.Ts.Owned.Annotated
