import host.mlx.AnnotatedGeometry

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def closedShape (ints : List Int) : Shape :=
  ints.map fun i => .literal (.lit (F64.ofInt i))

def closedMetadata (metadata : List (List Int × Nat)) : Metadata :=
  metadata.map fun a => (closedShape a.1,a.2)

def literalMetadata (metadata : List (List Int × Nat)) : List (List Dim × Nat) :=
  metadata.map fun a => (a.1.map Dim.lit,a.2)

theorem closedShape_literal (ints : List Int) : Shape.Literal (closedShape ints) := by
  induction ints with
  | nil => exact True.intro
  | cons i ints ih => exact ⟨⟨_,rfl⟩,ih⟩

theorem closedShape_holds (ν : Nat → F64) (C : CSrv) (ints : List Int)
    (exact : listSupport (fun i => F64.toInt? (F64.ofInt i) = some i) ints) :
    Shape.Holds ν C (closedShape ints) (ints.map Dim.lit) := by
  induction ints with
  | nil => exact .nil
  | cons i ints ih => exact .cons (.literal _ i rfl exact.1) (ih exact.2)

theorem closedMetadata_literal (metadata : List (List Int × Nat)) :
    Metadata.Literal (closedMetadata metadata) := by
  induction metadata with
  | nil => exact True.intro
  | cons m ms ih => exact ⟨closedShape_literal m.1,ih⟩

theorem closedMetadata_holds (ν : Nat → F64) (C : CSrv) (metadata : List (List Int × Nat))
    (exact : listSupport (fun a => listSupport (fun i => F64.toInt? (F64.ofInt i) = some i) a.1) metadata) :
    Metadata.Holds ν C (closedMetadata metadata) (literalMetadata metadata) := by
  induction metadata with
  | nil => exact .nil
  | cons m ms ih => exact .cons ⟨closedShape_holds ν C m.1 exact.1,rfl⟩ (ih exact.2)

theorem closedMetadata_unique {ν : Nat → F64} {C : CSrv} (metadata : List (List Int × Nat))
    (exact : listSupport (fun a => listSupport (fun i => F64.toInt? (F64.ofInt i) = some i) a.1) metadata)
    {actual : List (List Dim × Nat)} (h : Metadata.Holds ν C (closedMetadata metadata) actual) :
    actual = literalMetadata metadata :=
  Metadata.literal_unique (closedMetadata_literal metadata) h (closedMetadata_holds ν C metadata exact)

end Host.Mlx.Ffi.Annotated
