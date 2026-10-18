import host.mlx.NativeSliceGeometry
import host.mlx.NativeBufferSlots

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

/-- Each int32 shape cell retains its literal Number occurrence. A general
numeric-reference occurrence is deliberately a different note. -/
def literalShapeByteNotes : List SymE → List Byte
  | [] => []
  | e::rest => cellPartNotes .i32 (.literal e) 4 0 ++ literalShapeByteNotes rest

private theorem literal_parts_split {ν : Nat → F64} {C : CSrv} {R : Ren}
    (kind : EltK) (e : SymE) (x : F64) (value : e.eval ν = x) (n i : Nat)
    (restRoles : List Byte) (bytes : List Host.Ts.Byte)
    (held : ListR (fun role byte => role.Holds ν C R byte)
      (cellPartNotes kind (.literal e) n i ++ restRoles) bytes) :
    ∃ rest, bytes = cellParts kind (.num (.lit x)) n i ++ rest ∧
      ListR (fun role byte => role.Holds ν C R byte) restRoles rest := by
  induction n generalizing i bytes with
  | zero => exact ⟨bytes,rfl,held⟩
  | succ n ih =>
    cases held with | cons head tail =>
      cases head with | part _ _ _ cell meaning =>
        cases meaning with | literal _ actual denote =>
          have same : actual = x := (Option.some.inj denote).trans value
          subst actual
          obtain ⟨rest,equal,roles⟩ := ih (i+1) _ tail
          exact ⟨rest,congrArg (Host.Ts.Byte.part kind (.num (.lit x)) i :: ·) equal,roles⟩

/-- Exact integer recovery belongs to the fixed dimension schema. The byte
inventory then determines the original coherent shape buffer on each side. -/
theorem literal_shape_bytes_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (expressions : List SymE) (integers : List Int) (bytes : List Host.Ts.Byte)
    (dimensions : LiteralDimensions ν (expressions.map Dimension.literal) integers)
    (held : ListR (fun role byte => role.Holds ν C R byte) (literalShapeByteNotes expressions) bytes) :
    bytes = shapeBytes (integers.map Dim.lit) := by
  induction expressions generalizing integers bytes with
  | nil => cases dimensions; cases held; rfl
  | cons e rest ih =>
    cases dimensions with | cons _ i value exactInteger remaining =>
      obtain ⟨suffix,equal,roles⟩ := literal_parts_split .i32 e (F64.ofInt i) value 4 0
        (literalShapeByteNotes rest) bytes held
      rw [equal,ih _ _ remaining roles]
      rfl

theorem BufferContents.literal_shape {S : Type} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner : Nat} {s : St S} (expressions : List SymE) (integers : List Int)
    (contents : BufferContents (literalShapeByteNotes expressions) ν C R owner s)
    (dimensions : LiteralDimensions ν (expressions.map Dimension.literal) integers) :
    ShapeBuffer.Holds (expressions.map Dimension.literal) ν C (ShapeBuffer.bytesAt s (R.a owner)) := by
  obtain ⟨object,bytes,read,kind,held⟩ := contents
  have equal := literal_shape_bytes_exact expressions integers bytes dimensions held
  simp only [ShapeBuffer.bytesAt,St.obj?,read,kind]
  exact ⟨integers.map Dim.lit,dimensions.holds C,equal⟩

theorem literal_shape_decodable (expressions : List SymE) :
    Shape.Decodable (expressions.map Dimension.literal) := by
  induction expressions with
  | nil => trivial
  | cons _ _ ih => exact ⟨True.intro,ih⟩

private theorem literal_parts_subst (θ : Nat → SymE) (e : SymE) (n i : Nat) :
    cellPartNotes .i32 (.literal (e.subst θ)) n i =
      (cellPartNotes .i32 (.literal e) n i).map (Byte.subst θ) := by
  induction n generalizing i with
  | zero => rfl
  | succ n ih => simp only [cellPartNotes,List.map_cons,Byte.subst,Cell.subst,ih]

theorem literal_shape_notes_subst (θ : Nat → SymE) (expressions : List SymE) :
    literalShapeByteNotes (expressions.map (SymE.subst θ)) =
      (literalShapeByteNotes expressions).map (Byte.subst θ) := by
  induction expressions with
  | nil => rfl
  | cons e rest ih =>
    simp only [literalShapeByteNotes,List.map_cons,List.map_append,literal_parts_subst,ih]

end Host.Ts.Owned.Annotated
