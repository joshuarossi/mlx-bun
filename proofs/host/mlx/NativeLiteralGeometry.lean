import host.mlx.NativeShapeBuffer

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def Dimension.literalValue (ν : Nat → F64) : Dimension → Option Int
  | .literal e => F64.toInt? (e.eval ν)
  | .symbolic _ => none

def Shape.literalValues (ν : Nat → F64) (roles : Shape) : Option (List Int) :=
  roles.mapM (Dimension.literalValue ν)

theorem Dimension.Holds.literalValue {ν : Nat → F64} {C : CSrv} {role : Dimension} {d : Dim}
    (h : role.Holds ν C d) {i : Int} (hi : role.literalValue ν = some i) : d = .lit i := by
  cases h with
  | literal e j _ hj =>
    have he : j = i := Option.some.inj (hj.symm.trans hi)
    rw [he]
  | symbolic _ => cases hi

/-- Fixed literal dimension meanings determine their exact integer shape,
independently of numeric table allocation and equal-valued resource handles. -/
theorem Shape.Holds.literalValues {ν : Nat → F64} {C : CSrv} {roles : Shape} {shape : List Dim}
    (h : Shape.Holds ν C roles shape) {ints : List Int} (hv : roles.literalValues ν = some ints) :
    shape = ints.map Dim.lit := by
  induction h generalizing ints with
  | nil => cases hv; rfl
  | @cons role d rs ds hd ht ih =>
    cases hh : role.literalValue ν with
    | none => simp only [Shape.literalValues,List.mapM_cons,hh] at hv; cases hv
    | some i =>
      cases htail : Shape.literalValues ν rs with
      | none =>
        simp only [Shape.literalValues] at htail
        simp only [Shape.literalValues,List.mapM_cons,hh,htail] at hv
        cases hv
      | some is =>
        have tailEq := ih htail
        simp only [Shape.literalValues] at htail
        simp only [Shape.literalValues,List.mapM_cons,hh,htail] at hv
        cases hv
        rw [hd.literalValue hh,tailEq]
        rfl

theorem Dimension.literalValue_subst (ν : Nat → F64) (θ : Nat → SymE) (role : Dimension) :
    (role.subst θ).literalValue ν = role.literalValue (Owned.Annotated.nextValuation θ ν) := by
  cases role with
  | literal e => simp only [Dimension.subst,Dimension.literalValue,SymE.eval_subst]; rfl
  | symbolic _ => rfl

theorem Shape.literalValues_subst (ν : Nat → F64) (θ : Nat → SymE) (roles : Shape) :
    (Shape.subst θ roles).literalValues ν = roles.literalValues (Owned.Annotated.nextValuation θ ν) := by
  induction roles with
  | nil => rfl
  | cons r rs ih =>
    simp only [Shape.subst,List.map_cons,Shape.literalValues,List.mapM_cons,Dimension.literalValue_subst]
    exact congrArg (fun tail => (r.literalValue (Owned.Annotated.nextValuation θ ν)).bind
      fun i => tail.bind (fun is => some (i :: is))) ih

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem dProd_literals (ints : List Int) : dProd (ints.map Dim.lit) = M.pure (.lit (ints.foldr (· * ·) 1)) := by
  induction ints with
  | nil => rfl
  | cons i is ih =>
    rw [List.map_cons,dProd,ih]
    rfl

theorem literal_nonnegative_filter (ints : List Int) (h : listSupport (fun i => 0 ≤ i) ints) :
    (ints.map Dim.lit).filter (· = .lit (-1)) = [] := by
  induction ints with
  | nil => rfl
  | cons i is ih =>
    have hn : i ≠ -1 := by have := h.1; omega
    simp only [List.map_cons,List.filter_cons,Dim.lit.injEq,hn,decide_false,ih h.2]
    rfl

theorem reshape_literals (old new : List Int) (nonnegative : listSupport (fun i => 0 ≤ i) new)
    (products : old.foldr (· * ·) 1 = new.foldr (· * ·) 1) :
    reshapeShape (old.map Dim.lit) (new.map Dim.lit) = M.pure (some (new.map Dim.lit)) := by
  unfold reshapeShape
  rw [dProd_literals,literal_nonnegative_filter new nonnegative]
  dsimp only [M.bind,M.pure]
  rw [dProd_literals]
  rw [products]
  change M.pure (bif decide (new.foldr (· * ·) 1 = new.foldr (· * ·) 1) then some (new.map Dim.lit) else none) = _
  rw [show decide (new.foldr (· * ·) 1 = new.foldr (· * ·) 1) = true from by simp]
  rfl

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- A pure integer guard over fixed dimension meanings. It does not mention
native inference, a target execution, or numeric table allocation. -/
def ReshapeGeometry (ν : Nat → F64) (input output : Shape) : Prop :=
  ∃ old new : List Int, input.literalValues ν = some old ∧ output.literalValues ν = some new ∧
    listSupport (fun i => 0 ≤ i) new ∧ old.foldr (· * ·) 1 = new.foldr (· * ·) 1

theorem ReshapeGeometry.subst (ν : Nat → F64) (θ : Nat → SymE) (input output : Shape) :
    ReshapeGeometry ν (Shape.subst θ input) (Shape.subst θ output) ↔
      ReshapeGeometry (Owned.Annotated.nextValuation θ ν) input output := by
  simp only [ReshapeGeometry,Shape.literalValues_subst]

theorem ReshapeGeometry.infer {ν : Nat → F64} {C : CSrv} {input output : Shape}
    (h : ReshapeGeometry ν input output) {old new : List Dim}
    (hi : Shape.Holds ν C input old) (ho : Shape.Holds ν C output new) (dtype : Nat) :
    Host.Mlx.Ffi.infer (.reshape new) [(old,dtype)] = M.pure (some (.node new dtype)) := by
  obtain ⟨is,ns,hinput,houtput,hn,hp⟩ := h
  rw [hi.literalValues hinput,ho.literalValues houtput]
  simp only [Host.Mlx.Ffi.infer,NativeRoles.reshape_literals is ns hn hp]
  rfl

end Host.Mlx.Ffi.Annotated
