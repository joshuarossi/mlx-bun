import host.ts.RenameNativeCaptureInventory
import host.ts.RenameMaterializeState
import host.ts.RenameShapes
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def literalCaptureRole : Val → Option Value
  | .num (.lit x) => some (.literal (.lit x))
  | _ => none

theorem literalCaptureRole_source {v : Val} {role : Value} (selected : literalCaptureRole v = some role)
    (ν : Nat → F64) (C : CSrv) (R : Ren) : role.Holds ν C R v := by
  cases v <;> simp only [literalCaptureRole] at selected
  all_goals first | contradiction | skip
  case num n => cases n with
    | ref _ => cases selected
    | lit x => cases Option.some.inj selected; exact .literal _ _ rfl

theorem literalCaptureRole_materialized {v : Val} {role : Value} (selected : literalCaptureRole v = some role)
    (table C : CSrv) (ν : Nat → F64) (R : Ren) : role.Holds ν C R ((materializer table).val v) := by
  cases v <;> simp only [literalCaptureRole] at selected
  all_goals first | contradiction | skip
  case num n => cases n with
    | ref _ => cases selected
    | lit x => cases Option.some.inj selected; exact .literal _ _ rfl

def literalNativeNote (code : Native) (data : List Val) : NativeCaptureNote :=
  ⟨code,fun i => literalCaptureRole (Host.Ts.arg data i)⟩

theorem literalNativeNote_source {S : Type} (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) (owner : Nat) (o : Obj) (code : Native) (data : List Val)
    (read : s.heap.get (R.a owner) = some (.obj o)) (kind : o.kind = .fn (.native code data)) :
    (literalNativeNote code data).Holds ν C R owner s := by
  exact ⟨o,data,read,kind,fun _ _ selected => literalCaptureRole_source selected ν C R⟩

theorem literalNativeNote_materialized {S : Type} (ffiMap : CSrv → S → S) (table C : CSrv)
    (ν : Nat → F64) (R : Ren) (s : St S) (owner : Nat) (o : Obj) (code : Native) (data : List Val)
    (read : s.heap.get (R.a owner) = some (.obj o)) (kind : o.kind = .fn (.native code data)) :
    (literalNativeNote code data).Holds ν C R owner (materializeStateWith ffiMap table s) := by
  refine ⟨(materializer table).obj o,(materializer table).vals data,?_,?_,?_⟩
  · change (s.heap.map (materializer table).hobj).get (R.a owner) = _
    rw [PTrie.get_map,read]
    rfl
  · change (materializer table).kind o.kind = _
    rw [kind]
    rfl
  · intro i role selected
    have mapped := Host.Ts.nthD_map (materializer table).val .undef data i
    change Host.Ts.arg ((materializer table).vals data) i = (materializer table).val (Host.Ts.arg data i) at mapped
    rw [mapped]
    exact literalCaptureRole_materialized selected table C ν R

/-- Every selected numeric capture is a literal in the initialized native
closure. There is no meaning selected for a reference or nonnumeric capture. -/
noncomputable def literalCaptures {S : Type} (live : Nat → Prop) (s : St S) : NativeCaptureNotes := by
  classical
  exact ⟨fun a => if live a then match s.heap.get a with
    | some (.obj o) => match o.kind with
      | .fn (.native code data) => some (literalNativeNote code data)
      | _ => none
    | _ => none
    else none⟩

theorem literalCaptures.entry {S : Type} {live : Nat → Prop} {s : St S} {a : Nat} {o : Obj}
    {code : Native} {data : List Val} (alive : live a) (read : s.heap.get a = some (.obj o))
    (kind : o.kind = .fn (.native code data)) :
    (literalCaptures live s).owners a = some (literalNativeNote code data) := by
  simp only [literalCaptures,ite_eq_left alive,read,kind]

theorem literalCaptures.selected {S : Type} (live : Nat → Prop) (s : St S) (a : Nat) (note : NativeCaptureNote)
    (entry : (literalCaptures live s).owners a = some note) :
    live a ∧ ∃ o code data, s.heap.get a = some (.obj o) ∧ o.kind = .fn (.native code data) ∧ note = literalNativeNote code data := by
  classical
  by_cases alive : live a
  · simp only [literalCaptures,ite_eq_left alive] at entry
    cases read : s.heap.get a with
    | none => simp only [read] at entry; cases entry
    | some item => cases item with
      | cell _ => simp only [read] at entry; cases entry
      | obj o =>
        cases kind : o.kind <;> simp only [read,kind] at entry <;> try contradiction
        case fn code =>
          cases code <;> simp only at entry <;> try contradiction
          case native native data => exact ⟨alive,o,native,data,rfl,kind,(Option.some.inj entry).symm⟩
  · simp only [literalCaptures,ite_eq_right alive] at entry
    cases entry

theorem NativeCaptureInventory.literal_seed_same {S : Type} (s : St S)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live : Nat → Prop)
    (fixed : ∀ a note, (literalCaptures live s).owners a = some note → R.a a = a) :
    NativeCaptureInventory (literalCaptures live s) ν₀ ν C₀ C R live s s := by
  refine ⟨fun a note entry => (literalCaptures.selected live s a note entry).1,?_,?_⟩
  · intro a note entry
    obtain ⟨_,o,code,data,read,kind,rfl⟩ := literalCaptures.selected live s a note entry
    exact literalNativeNote_source ν₀ C₀ identity s a o code data read kind
  · intro a note entry
    have fixedAddress := fixed a note entry
    obtain ⟨_,o,code,data,read,kind,rfl⟩ := literalCaptures.selected live s a note entry
    apply literalNativeNote_source ν C R s a o code data _ kind
    simpa only [fixedAddress] using read

theorem NativeCaptureInventory.literal_seed {S : Type} (ffiMap : CSrv → S → S) (table : CSrv)
    (s : St S) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (live : Nat → Prop)
    (fixed : ∀ a note, (literalCaptures live s).owners a = some note → R.a a = a) :
    NativeCaptureInventory (literalCaptures live s) ν₀ ν C₀ C R live s (materializeStateWith ffiMap table s) := by
  have select := literalCaptures.selected live s
  refine ⟨fun a note entry => (select a note entry).1,?_,?_⟩
  · intro a note entry
    obtain ⟨_,o,code,data,read,kind,rfl⟩ := select a note entry
    exact literalNativeNote_source ν₀ C₀ identity s a o code data read kind
  · intro a note entry
    have fixedAddress := fixed a note entry
    obtain ⟨_,o,code,data,read,kind,rfl⟩ := select a note entry
    apply literalNativeNote_materialized ffiMap table C ν R s a o code data _ kind
    simpa only [fixedAddress] using read
end Host.Ts.Owned.Annotated
