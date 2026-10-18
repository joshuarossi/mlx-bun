import host.mlx.NativeLiteralGeometry
import host.mlx.DimRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def Dimension.sizeMeaning : Dimension → SymE
  | .literal e => e
  | .symbolic _ => .lit (F64.zero false)

def Shape.sizeMeaning : Shape → SymE
  | [] => .lit (F64.ofNat 1)
  | d::ds => .bin .mul d.sizeMeaning (Shape.sizeMeaning ds)

/-- Native array_size accepts literal nonnegative dimensions. The bounds make
the corresponding product expression exact in binary64, including zero axes.
Every suffix is bounded independently; a leading zero does not conceal a
rounded intermediate product. -/
inductive NaturalSize (ν : Nat → F64) : Shape → List Nat → Prop where
  | nil : NaturalSize ν [] []
  | cons (e : SymE) (n : Nat) {rs : Shape} {ns : List Nat}
      (meaning : e.eval ν = F64.ofNat n) (dimensionBound : n < 2^53)
      (productBound : n * ns.foldr (·*·) 1 < 2^53) (tail : NaturalSize ν rs ns) :
      NaturalSize ν (.literal e::rs) (n::ns)

theorem NaturalSize.productBound {ν : Nat → F64} {roles : Shape} {ns : List Nat}
    (h : NaturalSize ν roles ns) : ns.foldr (·*·) 1 < 2^53 := by
  cases h with
  | nil => decide +kernel
  | cons _ _ _ _ bound _ => exact bound

theorem NaturalSize.literalValues {ν : Nat → F64} {roles : Shape} {ns : List Nat}
    (h : NaturalSize ν roles ns) : roles.literalValues ν = some (ns.map Int.ofNat) := by
  induction h with
  | nil => rfl
  | cons e n meaning bound _ _ ih =>
    simp only [Shape.literalValues,List.mapM_cons,Dimension.literalValue,meaning,
      F64.toInt_ofNat53 n bound,List.map_cons]
    change (Shape.literalValues ν _).bind (fun rest => some (Int.ofNat n::rest)) = _
    rw [ih]
    rfl

theorem NaturalSize.eval {ν : Nat → F64} {roles : Shape} {ns : List Nat}
    (h : NaturalSize ν roles ns) : roles.sizeMeaning.eval ν = F64.ofNat (ns.foldr (·*·) 1) := by
  induction h with
  | nil => rfl
  | cons e n meaning bound product tail ih =>
    change F64.mul (e.eval ν) ((Shape.sizeMeaning _).eval ν) = F64.ofNat (n * _)
    rw [meaning,ih]
    exact F64.mul_ofNat53 _ _ bound tail.productBound product

theorem natsOfDims_natural (ns : List Nat) :
    natsOfDims (ns.map (fun n => Dim.lit (Int.ofNat n))) = some ns := by
  induction ns with
  | nil => rfl
  | cons n ns ih =>
    simp only [List.map_cons,natsOfDims,show decide (0 ≤ Int.ofNat n) = true from by simp,
      Bool.cond_true,ih,Option.map_some]
    rfl

theorem NaturalSize.decode {ν : Nat → F64} {C : CSrv} {roles : Shape} {shape : List Dim} {ns : List Nat}
    (h : NaturalSize ν roles ns) (hs : Shape.Holds ν C roles shape) : natsOfDims shape = some ns := by
  rw [hs.literalValues h.literalValues,List.map_map]
  exact natsOfDims_natural ns

theorem NaturalSize.denote {ν : Nat → F64} {C : CSrv} {roles : Shape} {ns : List Nat}
    (h : NaturalSize ν roles ns) :
    NumDenote ν C roles.sizeMeaning (.lit (F64.ofInt (Int.ofNat (ns.foldr (·*·) 1)))) := by
  change some (F64.ofNat _) = some (roles.sizeMeaning.eval ν)
  rw [h.eval]

theorem NaturalSize.exactInteger {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : Shape} {ns : List Nat}
    (h : NaturalSize ν roles ns) :
    (Owned.Annotated.Value.exactInteger roles.sizeMeaning).Holds ν C R (.big (Int.ofNat (ns.foldr (·*·) 1))) := by
  exact .exactInteger _ _ h.denote (by rw [h.eval]; exact F64.toInt_ofNat53 _ h.productBound)

theorem Dimension.sizeMeaning_subst (θ : Nat → SymE) (role : Dimension) :
    (role.subst θ).sizeMeaning = role.sizeMeaning.subst θ := by cases role <;> rfl

theorem Shape.sizeMeaning_subst (θ : Nat → SymE) (roles : Shape) :
    (Shape.subst θ roles).sizeMeaning = roles.sizeMeaning.subst θ := by
  induction roles with
  | nil => rfl
  | cons r rs ih =>
    simp only [Shape.subst,List.map_cons,Shape.sizeMeaning,Dimension.sizeMeaning_subst,SymE.subst]
    exact congrArg (SymE.bin .mul _) ih

theorem NaturalSize.subst {ν : Nat → F64} {roles : Shape} {ns : List Nat}
    (θ : Nat → SymE) (h : NaturalSize (Owned.Annotated.nextValuation θ ν) roles ns) :
    NaturalSize ν (Shape.subst θ roles) ns := by
  induction h with
  | nil => exact .nil
  | cons e n meaning bound product _ ih =>
    exact .cons (e.subst θ) n (by rw [SymE.eval_subst]; exact meaning) bound product ih

end Host.Mlx.Ffi.Annotated
