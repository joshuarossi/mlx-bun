import host.ts.RenameRuntimeArrayPush
import host.ts.RenameBufferKindFrame
import host.ts.RenameCaptureKindFrame
import host.ts.RenamePrivateKindFrame
import host.ts.RenameRetainedInventory

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

def RetainedNotes.arrayPush (notes : RetainedNotes) (owner length : Nat) (roles argRoles : List Value) : RetainedNotes :=
  {notes with runtime := {notes.runtime with control := returnNote (.literal (.lit (F64.ofNat length)))}, arrays := notes.arrays.write owner (roles++argRoles)}

/-- Mutable push retains the original array elements and current argument
meanings in order. Private/public headers, captured native functions and all
buffer notes are framed from the actual source update and live injectivity. -/
theorem RetainedInventory.array_push_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (fn owner : Nat) (function object : Obj) (data args values : List Val) (roles argRoles : List Value)
    (control : s₀.ctl = .call (.obj fn) (.obj owner) args)
    (functionRead : s₀.heap.get fn = some (.obj function)) (builtin : function.kind = .fn (.native (.arr .push) data))
    (objectRead : s₀.heap.get owner = some (.obj object)) (array : object.kind = .array values) (extensible : object.extensible = true)
    (entry : notes.arrays.owners owner = some roles) (controlNote : notes.runtime.control = callNote (.obj fn) (.obj owner) argRoles)
    (notFramed : ¬ framed owner) (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ sourcePost targetPost, interpC (step F s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step F s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.arrayPush owner (len (values++args)) roles argRoles) ν₀ ν C₀ C R live sourcePost targetPost := by
  have alive := inventory.arrays.keyLive owner roles entry
  have sourceWord := Nat.lt_of_lt_of_le (h.heap.sourceBound owner alive) sourceBound
  have targetWord := Nat.lt_of_lt_of_le (h.heap.targetBound owner alive) targetBound
  obtain ⟨targetFunction,targetData,targetThis,targetArgs,targetControl,targetFunctionRead,targetBuiltin,_,thisRelation,argsRelation⟩ :=
    h.native_call_view fn function (.arr .push) data (.obj owner) args control functionRead builtin
  cases thisRelation
  obtain ⟨targetObject,targetObjectRead,objectRelation,_⟩ := h.heap.readObject owner object alive notFramed objectRead
  have kindRelation := objectRelation.kind
  rw [array] at kindRelation
  obtain ⟨targetValues,targetKind,valuesRelation⟩ := kind_array kindRelation
  have targetExtensible := objectRelation.extensible_eq.trans extensible
  have lengthEq : len (targetValues++targetArgs) = len (values++args) := by
    simpa only [len_list_length] using (listR_length_eq (valuesRelation.append argsRelation)).symm
  obtain ⟨_,_,_,left,right,post,runtime,arraysPost⟩ := inventory.runtime.array_push_step F FR notes.runtime notes.arrays
    ν₀ ν C₀ C R live framed before after old old' s₀ s h inventory.arrays fn owner function object data args values roles argRoles
    control functionRead builtin objectRead array extensible entry controlNote notFramed sourceBound targetBound
  have actualTarget : interpC (step F s).run C = some
      ((s.setObj (R.a owner) {targetObject with kind := .array (targetValues++targetArgs)}).ret (natV (len (values++args))),C) := by
    rw [step_array_push_eq F s (R.a fn) (R.a owner) targetFunction targetObject targetData targetArgs targetValues
      targetControl targetFunctionRead targetBuiltin targetObjectRead targetKind targetExtensible,lengthEq]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actualTarget))
  dsimp only at same
  rw [same] at post runtime arraysPost
  have privates := inventory.privates.setKind owner object targetObject (.array (values++args)) (.array (targetValues++targetArgs))
    objectRead targetObjectRead sourceWord targetWord
  have publicFields := inventory.publicFields.setKind owner object targetObject (.array (values++args)) (.array (targetValues++targetArgs))
    objectRead targetObjectRead sourceWord targetWord
  have nonNative : ∀ code captures, object.kind ≠ .fn (.native code captures) := by
    intro code captures impossible; rw [array] at impossible; cases impossible
  have nonBuffer : ∀ bytes, object.kind ≠ .buf bytes := by
    intro bytes impossible; rw [array] at impossible; cases impossible
  have captures := inventory.captures.setNonNativeKind h.heap owner object {object with kind := .array (values++args)}
    {targetObject with kind := .array (targetValues++targetArgs)} (natV (len (values++args))) (natV (len (values++args)))
    alive objectRead nonNative sourceWord targetWord
  have buffers := inventory.buffers.setNonBufferKind h.heap owner object {object with kind := .array (values++args)}
    {targetObject with kind := .array (targetValues++targetArgs)} (natV (len (values++args))) (natV (len (values++args)))
    alive objectRead nonBuffer sourceWord targetWord
  exact ⟨_,_,left,actualTarget,post,runtime,
    privates.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl),captures,arraysPost,
    publicFields.frame (fun _ h => h) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl),buffers⟩

end Host.Ts.Owned.Annotated
