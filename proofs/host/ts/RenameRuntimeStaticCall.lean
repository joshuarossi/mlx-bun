import host.ts.RenameRuntimeArguments

set_option Elab.async false
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Under the identity resource map, an object value has only its own address role. -/
theorem Value.Holds.object_source {ν : Nat → F64} {C : CSrv} {role : Value} {address : Nat}
    (h : role.Holds ν C identity (.obj address)) : role = .obj address := by
  cases h
  rfl

theorem Tree.Holds.object_value_source {ν : Nat → F64} {C : CSrv} {note : Tree} {address : Nat}
    (h : note.Holds ν C identity (.value (.obj address))) : note = .value (.obj address) := by
  cases h with
  | value role => rw [Value.Holds.object_source role]

theorem Tree.Holds.empty_list_source {ν : Nat → F64} {C : CSrv} {note : Tree}
    (h : note.Holds ν C identity (.node "List" [])) : note = .node "List" [] := by
  cases h with
  | node _ fields =>
    cases fields
    rfl

/-- The source control annotation of a structural object call is the call note
for those two object roles and no arguments. -/
theorem Tree.Holds.object_call_source {ν : Nat → F64} {C : CSrv} {note : Tree} {callee receiver : Nat}
    (h : note.Holds ν C identity (Encode.ctl (.call (.obj callee) (.obj receiver) []))) :
    note = callNote (.obj callee) (.obj receiver) [] := by
  dsimp only [Encode.ctl,Encode.val,Encode.vals,Encode.seq,List.map] at h
  cases h with
  | node _ fields =>
    cases fields with
    | cons calleeNote fields =>
      cases fields with
      | cons receiverNote fields =>
        cases fields with
        | cons argumentNote fields =>
          cases fields
          rw [Tree.Holds.object_value_source calleeNote,Tree.Holds.object_value_source receiverNote,
            Tree.Holds.empty_list_source argumentNote]
          rfl

/-- An actual empty object call forces its retained control note. Numeric meanings
and the remaining inventories stay untouched. -/
theorem RuntimeInventory.object_call_note {S : Type} {notes : RuntimeNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {source target : St S}
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live source target)
    (callee receiver : Nat)
    (control : source.ctl = .call (.obj callee) (.obj receiver) []) :
    notes.control = callNote (.obj callee) (.obj receiver) [] := by
  have held := inventory.source.control
  rw [control] at held
  exact Tree.Holds.object_call_source held

end Host.Ts.Owned.Annotated
