import host.mlx.NativeClosedDimensions
import host.mlx.NativeShapeBufferInventory
import host.ts.RenameRetainedInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

theorem closedLiteralShape_literals (expressions : List SymE) :
    closedLiteralShape (expressions.map Dimension.literal) = expressions.all SymE.closed := by
  induction expressions with
  | nil => rfl
  | cons e rest ih => simp only [List.map_cons,closedLiteralShape,List.all_cons,ih]

end Host.Mlx.Ffi.Annotated

namespace Host.Ts.Owned.Annotated
open Parametric Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

/-- Recover the meaning of each current literal occurrence from its source
cell bytes. Exact integer conversion remains a separate checked fact. -/
theorem literal_shape_values_from_bytes {ν : Nat → F64} {C : CSrv} {R : Ren}
    (expressions : List SymE) (integers : List Int) (exact : ExactDimensions integers)
    (held : ListR (fun role byte => role.Holds ν C R byte) (literalShapeByteNotes expressions)
      (shapeBytes (integers.map Dim.lit))) :
    LiteralDimensions ν (expressions.map Dimension.literal) integers := by
  induction expressions generalizing integers with
  | nil => cases integers <;> cases held; exact .nil
  | cons e rest ih =>
    cases integers with
    | nil => cases held
    | cons i integers =>
      cases held with | cons head tail =>
        cases tail with | cons _ tail =>
          cases tail with | cons _ tail =>
            cases tail with | cons _ tail =>
              have value : e.eval ν = F64.ofInt i := by
                cases head with | part _ _ _ _ cell =>
                  cases cell with | literal _ _ meaning => exact (Option.some.inj meaning).symm
              exact .cons e i value (by rw [value]; exact exact.1) (ih integers exact.2 tail)

theorem literal_shape_bytes_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    (expressions : List SymE) (integers : List Int)
    (values : LiteralDimensions ν (expressions.map Dimension.literal) integers) :
    ListR (fun role byte => role.Holds ν C R byte) (literalShapeByteNotes expressions)
      (shapeBytes (integers.map Dim.lit)) := by
  induction expressions generalizing integers with
  | nil => cases values; exact .nil
  | cons e rest ih =>
    cases values with | cons _ i value _ remaining =>
      have meaning : NumDenote ν C e (.lit (F64.ofInt i)) := by
        change some (F64.ofInt i) = some (e.eval ν)
        rw [value]
      exact (cellPartNotes_holds (.literal e (F64.ofInt i) meaning) .i32 4 0).append (ih _ remaining)

/-- Only the selected existing buffer notes are normalized. Closure of each
current expression transfers its source-certified value to the target; no
target read or independently chosen target meaning is assumed. -/
theorem BufferInventory.normalize_closed_shape {S : Type} {notes : BufferNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner : Nat) (expressions : List SymE) (integers : List Int)
    (selected : notes.owners owner = some (literalShapeByteNotes expressions))
    (object : Obj) (read : s₀.heap.get owner = some (.obj object))
    (kind : object.kind = .buf (shapeBytes (integers.map Dim.lit)))
    (exact : ExactDimensions integers) (closed : expressions.all SymE.closed = true) :
    BufferInventory (notes.write owner (literalShapeByteNotes (constantExpressions integers))) ν₀ ν C₀ C R live s₀ s := by
  obtain ⟨sourceObject,targetObject,bytes,targetBytes,sourceRead,sourceKind,targetRead,targetKind,sourceRoles,targetRoles⟩ :=
    inventory.selected owner _ selected
  have same : sourceObject = object := HObj.obj.inj (Option.some.inj (sourceRead.symm.trans read))
  subst sourceObject
  have bytesEqual : bytes = shapeBytes (integers.map Dim.lit) := Kind.buf.inj (sourceKind.symm.trans kind)
  have sourceValues := literal_shape_values_from_bytes expressions integers exact (bytesEqual ▸ sourceRoles)
  have targetValues : LiteralDimensions ν (expressions.map Dimension.literal) integers :=
    sourceValues.closed_transfer (by rw [closedLiteralShape_literals]; exact closed)
  have targetEqual := literal_shape_bytes_exact expressions integers targetBytes targetValues targetRoles
  have constants₀ : LiteralDimensions ν₀ ((constantExpressions integers).map Dimension.literal) integers := by
    rw [constantExpressions_shape]; exact .constants ν₀ integers exact
  have constants : LiteralDimensions ν ((constantExpressions integers).map Dimension.literal) integers := by
    rw [constantExpressions_shape]; exact .constants ν integers exact
  apply inventory.annotate owner _ (inventory.keyLive owner _ selected)
  · exact ⟨object,_,read,kind,literal_shape_bytes_holds _ _ constants₀⟩
  · exact ⟨targetObject,_,targetRead,targetKind.trans (congrArg Kind.buf targetEqual),literal_shape_bytes_holds _ _ constants⟩

def RetainedNotes.normalizeShapeBuffer (notes : RetainedNotes) (owner : Nat) (integers : List Int) : RetainedNotes :=
  {notes with buffers := notes.buffers.write owner (literalShapeByteNotes (constantExpressions integers))}

theorem RetainedInventory.normalize_closed_shape_buffer {S : Type} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner : Nat) (expressions : List SymE) (integers : List Int)
    (selected : notes.buffers.owners owner = some (literalShapeByteNotes expressions))
    (object : Obj) (read : s₀.heap.get owner = some (.obj object))
    (kind : object.kind = .buf (shapeBytes (integers.map Dim.lit)))
    (exact : ExactDimensions integers) (closed : expressions.all SymE.closed = true) :
    RetainedInventory (notes.normalizeShapeBuffer owner integers) ν₀ ν C₀ C R live s₀ s :=
  ⟨inventory.runtime,inventory.privates,inventory.captures,inventory.arrays,inventory.publicFields,
    inventory.buffers.normalize_closed_shape owner expressions integers selected object read kind exact closed⟩

end Host.Ts.Owned.Annotated
