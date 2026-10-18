import host.ts.Init
import host.ts.RenameNativeCaptureInventory
import host.ts.RenameMaterializeState
import host.ts.RenameCaptureRebase
import host.ts.InitCaptureConstruction

set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The two metadata positions written by the original `Init.typedCtor`.
Both are literal numbers, independent of the numeric server and valuation. -/
def NativeCaptureNote.typedConstructor (code proto : Nat) : NativeCaptureNote :=
  ⟨.buf .typedCtor, fun i => if i = 0 then some (.literal (.lit (F64.ofNat code)))
    else if i = 1 then some (.literal (.lit (F64.ofNat proto))) else none⟩

theorem NativeCaptureNote.typedConstructor_code (code proto : Nat) :
    (NativeCaptureNote.typedConstructor code proto).roles 0 = some (.literal (.lit (F64.ofNat code))) := rfl
theorem NativeCaptureNote.typedConstructor_proto (code proto : Nat) :
    (NativeCaptureNote.typedConstructor code proto).roles 1 = some (.literal (.lit (F64.ofNat proto))) := rfl

theorem NativeCaptureNote.typedConstructor_holds {S : Type} (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) (owner code proto : Nat) (o : Obj)
    (object : s.heap.get (R.a owner) = some (.obj o))
    (kind : o.kind = .fn (.native (.buf .typedCtor) [natV code,natV proto])) :
    (NativeCaptureNote.typedConstructor code proto).Holds ν C R owner s := by
  refine ⟨o,[natV code,natV proto],object,kind,?_⟩
  intro i role entry
  by_cases zero : i = 0
  · subst i
    have same : role = .literal (.lit (F64.ofNat code)) := (Option.some.inj entry).symm
    subst role
    exact .literal _ _ rfl
  · by_cases one : i = 1
    · subst i
      have same : role = .literal (.lit (F64.ofNat proto)) := (Option.some.inj entry).symm
      subst role
      exact .literal _ _ rfl
    · simp only [NativeCaptureNote.typedConstructor,zero,one,ite_false] at entry
      cases entry

theorem NativeCaptureNote.typedConstructor_of_kind {S : Type} (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) (owner code proto : Nat)
    (projection : (s.obj? (R.a owner)).map Obj.kind = some (.fn (.native (.buf .typedCtor) [natV code,natV proto]))) :
    (NativeCaptureNote.typedConstructor code proto).Holds ν C R owner s := by
  cases heap : s.heap.get (R.a owner) with
  | none => simp only [St.obj?,heap,Option.map_none] at projection; cases projection
  | some item => cases item with
    | cell value => simp only [St.obj?,heap,Option.map_none] at projection; cases projection
    | obj o =>
      apply NativeCaptureNote.typedConstructor_holds ν C R s owner code proto o heap
      exact Option.some.inj (by simpa only [St.obj?,heap,Option.map_some] using projection)

/-- The metadata invariant is established by executing the original realm
constructor installation, before a later host use of the resulting closure. -/
theorem NativeCaptureNote.typedConstructor_created {S : Type} (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) (owner : Nat) (kind : EltK) (name : Name)
    (fresh : R.a owner = s.next) (bound : s.next < 2^64) (protoBound : aTypedProtoOf kind < 2^64) :
    (NativeCaptureNote.typedConstructor kind.code (aTypedProtoOf kind)).Holds ν C R owner ((typedCtor kind name).run s).2 := by
  apply NativeCaptureNote.typedConstructor_of_kind ν C R _ owner kind.code (aTypedProtoOf kind)
  rw [fresh]
  exact typedCtor_native_kind s kind name bound protoBound

theorem NativeCaptureNote.int32_created {S : Type} (ν : Nat → F64) (C : CSrv) (R : Ren)
    (s : St S) (fresh : R.a 90 = s.next) (bound : s.next < 2^64) :
    (NativeCaptureNote.typedConstructor 4 21).Holds ν C R 90 ((typedCtor .i32 chars!"Int32Array").run s).2 :=
  NativeCaptureNote.typedConstructor_created ν C R s 90 .i32 chars!"Int32Array" fresh bound (by decide +kernel)

/-- Concrete specialization changes references, while these initialized
literal captures remain exactly the original constructor code and prototype. -/
theorem NativeCaptureNote.typedConstructor_materialized {S : Type} (ffiMap : CSrv → S → S)
    (table C : CSrv) (ν : Nat → F64) (R : Ren) (s : St S) (owner code proto : Nat) (o : Obj)
    (object : s.heap.get (R.a owner) = some (.obj o))
    (kind : o.kind = .fn (.native (.buf .typedCtor) [natV code,natV proto])) :
    (NativeCaptureNote.typedConstructor code proto).Holds ν C R owner (materializeStateWith ffiMap table s) := by
  apply NativeCaptureNote.typedConstructor_holds ν C R _ owner code proto ((materializer table).obj o)
  · change (s.heap.map (materializer table).hobj).get (R.a owner) = _
    rw [PTrie.get_map,object]
    rfl
  · change (materializer table).kind o.kind = _
    rw [kind]
    rfl

theorem NativeCaptureNote.typedConstructor_subst (code proto : Nat) (θ : Nat → SymE) :
    (NativeCaptureNote.typedConstructor code proto).mapRoles (Value.subst θ) =
      NativeCaptureNote.typedConstructor code proto := by
  apply congrArg (NativeCaptureNote.mk (.buf .typedCtor))
  funext i
  by_cases zero : i = 0
  · subst i; rfl
  · by_cases one : i = 1
    · subst i; rfl
    · simp only [NativeCaptureNote.typedConstructor,zero,one,ite_false,Option.map_none]

theorem NativeCaptureNote.typedConstructor_rename (code proto : Nat) (K : Ren) :
    (NativeCaptureNote.typedConstructor code proto).rename K =
      NativeCaptureNote.typedConstructor code proto := by
  apply congrArg (NativeCaptureNote.mk (.buf .typedCtor))
  funext i
  by_cases zero : i = 0
  · subst i; rfl
  · by_cases one : i = 1
    · subst i; rfl
    · simp only [NativeCaptureNote.typedConstructor,zero,one,ite_false,Option.map_none]

end Host.Ts.Owned.Annotated
