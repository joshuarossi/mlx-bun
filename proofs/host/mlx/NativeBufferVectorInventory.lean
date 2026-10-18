import host.mlx.NativeHandleArrayCells
import host.mlx.NativeVectorObjects

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric Host.Mlx.Ffi.Annotated

private theorem byte_note_forest {ν : Nat → F64} {C : CSrv} {R : Ren}
    {roles : List Byte} {bytes : List Host.Ts.Byte}
    (held : ListR (fun role byte => role.Holds ν C R byte) roles bytes) :
    ForestHolds ν C R (roles.map Tree.byte) (bytes.map Encode.byte) := by
  induction held with
  | nil => exact .nil
  | cons head tail ih => exact .cons (.byte head) ih

theorem vector_buffer_fields (handles : List Nat) :
    VectorBuffer.fields handles = (handleArrayBytes handles).map Tree.byte := by
  induction handles with
  | nil => rfl
  | cons handle rest ih =>
    simp only [VectorBuffer.fields,handleArrayBytes,List.map_append,←ih]
    rfl

theorem buffer_bytes_vector_role {ν : Nat → F64} {C : CSrv} {R : Ren} {handles : List Nat} {bytes : List Host.Ts.Byte}
    (held : ListR (fun role byte => role.Holds ν C R byte) (handleArrayBytes handles) bytes) :
    (VectorBuffer.role handles).Holds ν C R (Encode.kind (.buf bytes)) := by
  refine .node _ (.cons (.node _ ?_) .nil)
  rw [vector_buffer_fields]
  exact byte_note_forest held

theorem BufferContents.vector_role {S : Type} {ν : Nat → F64} {C : CSrv} {R : Ren} {owner : Nat}
    {handles : List Nat} {s : St S} (contents : BufferContents (handleArrayBytes handles) ν C R owner s) :
    (VectorBuffer.role handles).Holds ν C R (objectKindAt s (R.a owner)) := by
  obtain ⟨object,bytes,read,kind,held⟩ := contents
  have role := buffer_bytes_vector_role held
  simpa only [objectKindAt,St.obj?,read,kind] using role

/-- ABI integer decoding may consume a fixed ordinary integer or a fixed
exact-integer expression. The expression certificate is independent of both
executions; rounded numeric-integer roles alone are deliberately insufficient. -/
inductive FixedIntegerRole : Value → Int → Prop where
  | ordinary (value : Int) : FixedIntegerRole (.ordinaryBig value) value
  | exact (meaning : SymE) (value : Int)
      (closed : ∀ valuation, meaning.eval valuation = F64.ofInt value)
      (exactValue : F64.toInt? (F64.ofInt value) = some value) :
      FixedIntegerRole (.exactInteger meaning) value

theorem FixedIntegerRole.holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Int} {actual : Val}
    (schema : FixedIntegerRole role value) (held : role.Holds ν C R actual) :
    (Value.ordinaryBig value).Holds ν C R actual := by
  cases schema with
  | ordinary value => exact held
  | exact meaning value closed exactValue =>
    cases held with | exactInteger _ i _ exactActual =>
      rw [closed ν] at exactActual
      have same : i = value := Option.some.inj (exactActual.symm.trans exactValue)
      subst i
      exact .ordinaryBig value

end Host.Ts.Owned.Annotated
