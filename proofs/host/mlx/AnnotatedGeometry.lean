import host.mlx.AnnotatedInputs

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

theorem Dimension.literal_of_holds {ν : Nat → F64} {C : CSrv} {role : Dimension} {i : Int}
    (h : role.Holds ν C (.lit i)) : ∃ e, role = .literal e := by
  cases h with
  | literal e _ _ _ => exact ⟨e,rfl⟩

theorem Shape.literal_of_holds {ν : Nat → F64} {C : CSrv} {roles : Shape} {ints : List Int}
    (h : Shape.Holds ν C roles (ints.map Dim.lit)) : roles.Literal := by
  induction ints generalizing roles with
  | nil => cases h; exact True.intro
  | cons i ints ih => cases h with
    | cons hh ht => exact ⟨Dimension.literal_of_holds hh,ih ht⟩

def Metadata.Literal (roles : Metadata) : Prop := listSupport (fun a => a.1.Literal) roles

theorem Metadata.literal_of_holds {ν : Nat → F64} {C : CSrv} {roles : Metadata}
    {metadata : List (List Dim × Nat)} (h : Metadata.Holds ν C roles metadata)
    (literal : listSupport (fun a : List Dim × Nat => ∃ ints : List Int, a.1 = ints.map Dim.lit) metadata) :
    roles.Literal := by
  induction h with
  | nil => exact True.intro
  | cons hh ht ih =>
    obtain ⟨ints,he⟩ := literal.1
    refine ⟨Shape.literal_of_holds (ν := ν) (C := C) (ints := ints) ?_,ih literal.2⟩
    rw [← he]
    exact hh.1

theorem Metadata.literal_unique {ν : Nat → F64} {C : CSrv} {roles : Metadata}
    {a b : List (List Dim × Nat)} (literal : roles.Literal)
    (ha : Metadata.Holds ν C roles a) (hb : Metadata.Holds ν C roles b) : a = b := by
  induction ha generalizing b with
  | nil => cases hb; rfl
  | cons hh ht ih => cases hb with
    | cons hh' ht' =>
      have hs := Shape.literal_unique literal.1 hh.1 hh'.1
      have hd := hh.2.trans hh'.2.symm
      have he := Prod.ext hs hd
      rw [he,ih literal.2 ht']

end Host.Mlx.Ffi.Annotated
