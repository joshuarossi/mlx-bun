import host.ts.RenameRuntimeArguments
import host.ts.RenameArrayMutation
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The actual mutable push builtin appends the fixed call-argument meanings
and retains every previously annotated array element in source order. -/
theorem RuntimeInventory.array_push_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (arrays : ArrayNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (arrayInventory : ArrayInventory arrays ν₀ ν C₀ C R live s₀ s)
    (f a : Nat) (fo₀ o₀ : Obj) (data₀ args₀ values₀ : List Val) (roles argRoles : List Value)
    (control : s₀.ctl = .call (.obj f) (.obj a) args₀)
    (function : s₀.heap.get f = some (.obj fo₀)) (builtin : fo₀.kind = .fn (.native (.arr .push) data₀))
    (object : s₀.heap.get a = some (.obj o₀)) (array : o₀.kind = .array values₀) (extensible : o₀.extensible = true)
    (entry : arrays.owners a = some roles) (controlNote : notes.control = callNote (.obj f) (.obj a) argRoles)
    (notFramed : ¬ framed a) (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ (o : Obj) (args values : List Val),
      interpC (step F s₀).run C₀ = some
        ((s₀.setObj a {o₀ with kind := .array (values₀++args₀)}).ret (natV (len (values₀++args₀))),C₀) ∧
      interpC (step F s).run C = some
        ((s.setObj (R.a a) {o with kind := .array (values++args)}).ret (natV (len (values₀++args₀))),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ((s₀.setObj a {o₀ with kind := .array (values₀++args₀)}).ret (natV (len (values₀++args₀))))
        ((s.setObj (R.a a) {o with kind := .array (values++args)}).ret (natV (len (values₀++args₀)))) ∧
      RuntimeInventory {notes with control := returnNote (.literal (.lit (F64.ofNat (len (values₀++args₀)))))} ν₀ ν C₀ C R live
        ((s₀.setObj a {o₀ with kind := .array (values₀++args₀)}).ret (natV (len (values₀++args₀))))
        ((s.setObj (R.a a) {o with kind := .array (values++args)}).ret (natV (len (values₀++args₀)))) ∧
      ArrayInventory (arrays.write a (roles++argRoles)) ν₀ ν C₀ C R live
        ((s₀.setObj a {o₀ with kind := .array (values₀++args₀)}).ret (natV (len (values₀++args₀))))
        ((s.setObj (R.a a) {o with kind := .array (values++args)}).ret (natV (len (values₀++args₀)))) := by
  obtain ⟨fo,data,this,args,targetControl,targetFunction,targetBuiltin,_,thisRelation,_⟩ :=
    h.native_call_view f fo₀ (.arr .push) data₀ (.obj a) args₀ control function builtin
  cases thisRelation
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceArgs := (callNote_view sourceControl).2.2
  have targetArgs := (callNote_view targetControlRole).2.2
  obtain ⟨prior₀,o,prior,values,sourceObject,sourceKind,targetObject,targetKind,sourceRoles,targetRoles,_,valuesLive⟩ :=
    arrayInventory.selected a roles entry
  have sourceEq : prior₀ = o₀ := HObj.obj.inj (Option.some.inj (sourceObject.symm.trans object))
  subst prior₀
  have valuesEq : prior = values₀ := Kind.array.inj (sourceKind.symm.trans array)
  subst prior
  have alive := arrayInventory.keyLive a roles entry
  obtain ⟨other,otherObject,objectRelation,objectLive⟩ := h.heap.readObject a o₀ alive notFramed object
  have targetEq : other = o := HObj.obj.inj (Option.some.inj (otherObject.symm.trans targetObject))
  subst other
  have targetExtensible : o.extensible = true := objectRelation.extensible_eq.trans extensible
  have support := h.controlLive
  rw [control] at support
  have argsLive := vals_support_of args₀ support.2.2.1
  have appendedRoles := (annotated_values_paired sourceRoles targetRoles).append (annotated_values_paired sourceArgs targetArgs)
  have appendedLive := listSupport_append valuesLive argsLive
  have sourceWord : a < 2^64 := Nat.lt_of_lt_of_le (h.heap.sourceBound a alive) sourceBound
  have targetWord : R.a a < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound a alive) targetBound
  have lengthEq : len (values++args) = len (values₀++args₀) := by
    simpa only [len_list_length] using (listR_length_eq appendedRoles).symm
  have newObjectLive : treeSupport live (Encode.obj {o₀ with kind := .array (values₀++args₀)}) :=
    ⟨⟨vals_support _ appendedLive,True.intro⟩,objectLive.2⟩
  have post := h.setObject a _ _ alive notFramed (objectRelation.replace_array _ _ appendedRoles) newObjectLive sourceWord targetWord
  have literalRole₀ : (Value.literal (.lit (F64.ofNat (len (values₀++args₀))))).Holds ν₀ C₀ identity (natV (len (values₀++args₀))) := .literal _ _ rfl
  have literalRole : (Value.literal (.lit (F64.ofNat (len (values₀++args₀))))).Holds ν C R (natV (len (values₀++args₀))) := .literal _ _ rfl
  have cells := inventory.cellInventory.setObject h.heap a o₀ o {o₀ with kind := .array (values₀++args₀)} {o with kind := .array (values++args)}
    (natV (len (values₀++args₀))) (natV (len (values₀++args₀))) alive object targetObject sourceWord targetWord
  refine ⟨o,args,values,?_,?_,?_,?_,?_⟩
  · rw [step_array_push_eq F s₀ f a fo₀ o₀ data₀ args₀ values₀ control function builtin object array extensible]; rfl
  · rw [step_array_push_eq F s (R.a f) (R.a a) fo o data args values targetControl targetFunction targetBuiltin targetObject targetKind targetExtensible,lengthEq]; rfl
  · exact post.go (.node _ (.cons (.value (Value.paired literalRole₀ literalRole)) .nil)) ⟨True.intro,True.intro⟩
  · exact ⟨cells.keyLive,⟨returnNote_holds literalRole₀,inventory.source.stack,cells.source⟩,
      ⟨returnNote_holds literalRole,inventory.target.stack,cells.target⟩⟩
  · exact arrayInventory.set_array h.heap a (roles++argRoles) (values₀++args₀) (values++args) o₀ o _ _ alive
      (sourceRoles.append sourceArgs) (targetRoles.append targetArgs) appendedLive sourceWord targetWord
end Host.Ts.Owned.Annotated
