import host.ts.RenameRuntimeArguments
import host.ts.RenameArrayInventory
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem FrameR.spread_view {NR : NumV → NumV → Prop} {R : Ren}
    {kind : Nat} {fn this : Val} {acc : List Val} {rest : List Elem} {env : Env} {f : Frame}
    (h : FrameR NR R (.c (.spread kind fn this acc rest env)) f) :
    ∃ fn' this' acc', f = .c (.spread kind fn' this' acc' rest (R.env env)) ∧
      ValueR NR R fn fn' ∧ ValueR NR R this this' ∧ ListR (ValueR NR R) acc acc' := by
  obtain ⟨cf',rfl,hh⟩ := h.c_view
  have ht := hh.tag_eq
  cases cf' <;> simp only [Encode.callF,treeTag] at ht
  all_goals try contradiction
  case spread kind' fn' this' acc' rest' env' =>
    cases hh with | node tag hs =>
      cases hs with | cons hk hs =>
        cases hs with | cons hfn hs =>
          cases hs with | cons hthis hs =>
            cases hs with | cons hacc hs =>
              cases hs with | cons hr hs =>
                cases hs with | cons he hs =>
                  cases hk
                  cases hr
                  obtain rfl := env_eq_map he
                  cases hfn with | value hfn =>
                    cases hthis with | value hthis => exact ⟨fn',this',acc',rfl,hfn,hthis,vals_roles_of hacc⟩

theorem step_array_argument_spread_eq (F : Ffi) (s : St F.S) (a : Nat) (o : Obj) (values : List Val)
    (kind : Nat) (fn this : Val) (acc : List Val) (rest : List Elem) (env : Env) (fs : List Frame)
    (control : s.ctl = .ret (.obj a)) (stack : s.stack = .c (.spread kind fn this acc rest env)::fs)
    (object : s.heap.get a = some (.obj o)) (array : o.kind = .array values) (ordinary : kind ≤ 1) :
    step F s = M.pure (argumentState {s with stack := fs} kind fn this (values.reverse ++ acc) rest env) := by
  have obj : ({s with stack := fs} : St F.S).obj? a = some o := by simp only [St.obj?,object]
  have elems := elemsOf_array F {s with stack := fs} a o values obj array
  have spread : spreadElems F {s with stack := fs} (.obj a) (.c (.spread kind fn this acc rest env))
      (fun es => argsNext F {s with stack := fs} kind fn this (es.reverse ++ acc) rest env) =
      M.pure (argumentState {s with stack := fs} kind fn this (values.reverse ++ acc) rest env) := by
    unfold spreadElems
    rw [elems]
    change argsNext F {s with stack := fs} kind fn this (values.reverse ++ acc) rest env = _
    exact argsNext_ordinary_eq F _ kind fn this (values.reverse ++ acc) rest env ordinary
  simpa only [step,control,stepRet,stack,retStep,retC] using spread
end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Annotated
open Parametric

/-- Enumerating an owned JavaScript array uses its retained element meanings.
Both executions follow the original spread collector and argument scheduler. -/
theorem RuntimeInventory.array_argument_spread_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (arrays : ArrayNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (elementRoles : List Value) (entry : arrays.owners a = some elementRoles)
    (fnRole thisRole : Value) (roles : List Value) (kind : Nat) (fn this : Val) (acc : List Val)
    (rest : List Elem) (env : Env) (frames : List Frame) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .c (.spread kind fn this acc rest env)::frames) (ordinary : kind ≤ 1)
    (stackNotes : notes.stack = argumentFrameNote true kind fnRole thisRole roles rest env::tailNotes) :
    ∃ (values targetValues : List Val) (targetFn targetThis : Val) (targetAcc : List Val) (targetFrames : List Frame),
      interpC (step F s₀).run C₀ = some
        (argumentState {s₀ with stack := frames} kind fn this (values.reverse ++ acc) rest env,C₀) ∧
      interpC (step F s).run C = some
        (argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValues.reverse ++ targetAcc) rest (R.env env),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (argumentState {s₀ with stack := frames} kind fn this (values.reverse ++ acc) rest env)
        (argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValues.reverse ++ targetAcc) rest (R.env env)) ∧
      RuntimeInventory ({notes with stack := tailNotes}.arguments kind fnRole thisRole (elementRoles.reverse ++ roles) rest env)
        ν₀ ν C₀ C R live
        (argumentState {s₀ with stack := frames} kind fn this (values.reverse ++ acc) rest env)
        (argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValues.reverse ++ targetAcc) rest (R.env env)) ∧
      ArrayInventory arrays ν₀ ν C₀ C R live
        (argumentState {s₀ with stack := frames} kind fn this (values.reverse ++ acc) rest env)
        (argumentState {s with stack := targetFrames} kind targetFn targetThis (targetValues.reverse ++ targetAcc) rest (R.env env)) := by
  obtain ⟨o₀,o,values,targetValues,sourceObject,sourceKind,targetObject,targetKind,sourceElements,targetElements,pairedElements,elementsLive⟩ :=
    arrayInventory.selected a elementRoles entry
  obtain ⟨receiver,targetControl,receiverRole⟩ := (h.control_view control).ret_view
  cases receiverRole
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨targetFn,targetThis,targetAcc,frameEq,fnRelation,thisRelation,accRelation⟩ := frameRelation.spread_view
  rw [frameEq] at targetStack
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  obtain ⟨sourceHead,sourceTail⟩ :
      (argumentFrameNote true kind fnRole thisRole roles rest env).Holds ν₀ C₀ identity
        (Encode.frame (.c (.spread kind fn this acc rest env))) ∧
      ForestHolds ν₀ C₀ identity tailNotes (frames.map Encode.frame) := by
    cases sourceStack with | cons head tail => exact ⟨head,tail⟩
  obtain ⟨targetHead,targetTail⟩ :
      (argumentFrameNote true kind fnRole thisRole roles rest env).Holds ν C R
        (Encode.frame (.c (.spread kind targetFn targetThis targetAcc rest (R.env env)))) ∧
      ForestHolds ν C R tailNotes (targetFrames.map Encode.frame) := by
    cases targetStackRole with | cons head tail => exact ⟨head,tail⟩
  have sourceHead' := argumentFrameNote_view (ν:=ν₀) (C:=C₀) (R:=identity) true kind fnRole thisRole roles rest env fn this acc
    (by simpa only [identity_environment,argumentFrame,↓reduceIte] using sourceHead)
  have targetHead' := argumentFrameNote_view true kind fnRole thisRole roles rest env targetFn targetThis targetAcc targetHead
  have support := h.stackLive
  rw [stack] at support
  have fnLive : valueSupport live fn := support.1.1.2.1
  have thisLive : valueSupport live this := support.1.1.2.2.1
  have accLive := vals_support_of acc support.1.1.2.2.2.1
  have envLive : treeSupport live (Encode.env env) := support.1.1.2.2.2.2.2.1
  refine ⟨values,targetValues,targetFn,targetThis,targetAcc,targetFrames,?_,?_,?_,?_,?_⟩
  · rw [step_array_argument_spread_eq F s₀ a o₀ values kind fn this acc rest env frames control stack sourceObject sourceKind ordinary]
    rfl
  · rw [step_array_argument_spread_eq F s (R.a a) o targetValues kind targetFn targetThis targetAcc rest (R.env env) targetFrames
      targetControl targetStack targetObject targetKind ordinary]
    rfl
  · exact argumentState_roles (h.restack tailRelation support.2) kind fn targetFn this targetThis
      (values.reverse ++ acc) (targetValues.reverse ++ targetAcc) rest env fnRelation thisRelation
      ((values_reverse_roles pairedElements).append accRelation) fnLive thisLive
      (listSupport_append (listSupport_reverse elementsLive) accLive) envLive
  · refine ⟨?_,?_,?_⟩
    · rw [RuntimeNotes.arguments_cells]
      exact inventory.keyLive
    · have popped : ({notes with stack := tailNotes}).Holds ν₀ C₀ identity {s₀ with stack := frames} :=
        ⟨inventory.source.control,sourceTail,inventory.source.cells⟩
      simpa only [identity_environment] using popped.arguments kind fnRole thisRole (elementRoles.reverse ++ roles)
        fn this (values.reverse ++ acc) rest env sourceHead'.1 sourceHead'.2.1
        ((value_roles_reverse sourceElements).append sourceHead'.2.2)
    · have popped : ({notes with stack := tailNotes}).Holds ν C R {s with stack := targetFrames} :=
        ⟨inventory.target.control,targetTail,inventory.target.cells⟩
      exact popped.arguments kind fnRole thisRole (elementRoles.reverse ++ roles) targetFn targetThis
        (targetValues.reverse ++ targetAcc) rest env targetHead'.1 targetHead'.2.1
        ((value_roles_reverse targetElements).append targetHead'.2.2)
  · apply arrayInventory.frame (fun _ alive => alive)
    · intro b roles entry
      rw [argumentState_heap]
    · intro b roles entry
      rw [argumentState_heap]
end Host.Ts.Owned.Annotated
