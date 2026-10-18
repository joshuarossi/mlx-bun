import host.mlx.NativeQuantizedRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem literal_nonnegative_filter_ne (ints : List Int) (h : listSupport (fun i => 0 ≤ i) ints) :
    (ints.map Dim.lit).filter (· ≠ Dim.lit (-1)) = ints.map Dim.lit := by
  induction ints with
  | nil => rfl
  | cons i is ih =>
    have hn : i ≠ -1 := by have := h.1; omega
    have yes : decide (Dim.lit i ≠ Dim.lit (-1)) = true := decide_eq_true (fun he => hn (Dim.lit.inj he))
    rw [List.map_cons,List.filter_cons,ite_eq_left yes,ih h.2]

theorem literal_nonnegative_replace (ints : List Int) (feature : Int) (h : listSupport (fun i => 0 ≤ i) ints) :
    (ints.map Dim.lit).map (fun d => bif decide (d = Dim.lit (-1)) then Dim.lit feature else d) = ints.map Dim.lit := by
  induction ints with
  | nil => rfl
  | cons i is ih =>
    have hn : i ≠ -1 := by have := h.1; omega
    simp only [List.map_cons,Dim.lit.injEq,hn,decide_false,Bool.cond_false,ih h.2]

/-- Original trailing-minus-one inference, including its nonzero divisor
and exact integer divisibility test. -/
theorem reshape_trailing_literals (old leading : List Int) (feature : Int)
    (nonnegative : listSupport (fun i => 0 ≤ i) leading)
    (divisor : leading.foldr (· * ·) 1 ≠ 0) (divides : old.foldr (· * ·) 1 % leading.foldr (· * ·) 1 = 0)
    (quotient : old.foldr (· * ·) 1 / leading.foldr (· * ·) 1 = feature) :
    reshapeShape (old.map Dim.lit) (leading.map Dim.lit ++ [Dim.lit (-1)]) =
      M.pure (some (leading.map Dim.lit ++ [Dim.lit feature])) := by
  have filterEq : (leading.map Dim.lit ++ [Dim.lit (-1)]).filter (· = Dim.lit (-1)) = [Dim.lit (-1)] := by
    rw [List.filter_append,literal_nonnegative_filter leading nonnegative]
    rfl
  have filterNe : (leading.map Dim.lit ++ [Dim.lit (-1)]).filter (· ≠ Dim.lit (-1)) = leading.map Dim.lit := by
    rw [List.filter_append,literal_nonnegative_filter_ne leading nonnegative]
    simp only [List.filter_cons,List.filter_nil,ne_eq,not_true_eq_false,decide_false]
    change leading.map Dim.lit ++ [] = leading.map Dim.lit
    exact List.append_nil _
  unfold reshapeShape
  rw [dProd_literals,filterEq]
  dsimp only [M.bind,M.pure]
  rw [filterNe,dProd_literals]
  change (bif decide (leading.foldr (· * ·) 1 ≠ 0 ∧ old.foldr (· * ·) 1 % leading.foldr (· * ·) 1 = 0) then
    M.pure (some ((leading.map Dim.lit ++ [Dim.lit (-1)]).map
      (fun d => bif decide (d = Dim.lit (-1)) then Dim.lit (old.foldr (· * ·) 1 / leading.foldr (· * ·) 1) else d))) else M.pure none) = _
  rw [show decide (leading.foldr (· * ·) 1 ≠ 0 ∧ old.foldr (· * ·) 1 % leading.foldr (· * ·) 1 = 0) = true from
    decide_eq_true ⟨divisor,divides⟩]
  simp only [Bool.cond_true,quotient,List.map_append,literal_nonnegative_replace leading feature nonnegative,
    List.map_cons,List.map_nil,decide_true]

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- The trailing inferred feature has a fixed integer value; the requested
leading dimensions can still depend on the numeric valuation. -/
def TrailingReshapeGeometry (ν : Nat → F64) (input leading : Shape) (feature : Int) : Prop :=
  ∃ old ps : List Int, input.literalValues ν = some old ∧ leading.literalValues ν = some ps ∧
    listSupport (fun i => 0 ≤ i) ps ∧ ps.foldr (· * ·) 1 ≠ 0 ∧
    old.foldr (· * ·) 1 % ps.foldr (· * ·) 1 = 0 ∧ old.foldr (· * ·) 1 / ps.foldr (· * ·) 1 = feature

theorem TrailingReshapeGeometry.subst (ν : Nat → F64) (θ : Nat → SymE) (input leading : Shape) (feature : Int) :
    TrailingReshapeGeometry ν (Shape.subst θ input) (Shape.subst θ leading) feature ↔
      TrailingReshapeGeometry (Owned.Annotated.nextValuation θ ν) input leading feature := by
  simp only [TrailingReshapeGeometry,Shape.literalValues_subst]

def trailingRequest (leading : Shape) : Shape := leading ++ [constantDimension (-1)]
def trailingResult (leading : Shape) (feature : Int) : Shape := leading ++ [constantDimension feature]

theorem trailingRequest_subst (θ : Nat → SymE) (leading : Shape) :
    Shape.subst θ (trailingRequest leading) = trailingRequest (Shape.subst θ leading) := by
  simp only [Shape.subst,trailingRequest,List.map_append,List.map_cons,List.map_nil]
  rfl

theorem trailingResult_subst (θ : Nat → SymE) (leading : Shape) (feature : Int) :
    Shape.subst θ (trailingResult leading feature) = trailingResult (Shape.subst θ leading) feature := by
  simp only [Shape.subst,trailingResult,List.map_append,List.map_cons,List.map_nil]
  rfl

theorem TrailingReshapeGeometry.infer {ν : Nat → F64} {C : CSrv} {input leading : Shape} {feature : Int}
    (geometry : TrailingReshapeGeometry ν input leading feature) (dtype : Nat) {old request : List Dim}
    (hi : Shape.Holds ν C input old) (hr : Shape.Holds ν C (trailingRequest leading) request)
    (exact : F64.toInt? (F64.ofInt feature) = some feature) :
    ∃ result, infer (.reshape request) [(old,dtype)] = M.pure (some (.node result dtype)) ∧
      Shape.Holds ν C (trailingResult leading feature) result := by
  obtain ⟨is,ps,hold,hprefix,nonnegative,divisor,divides,quotient⟩ := geometry
  obtain ⟨prefixShape,tailShape,split,prefixHold,tailHold⟩ := Shape.split leading [constantDimension (-1)] request hr
  cases tailHold with
  | cons minus ht =>
    cases ht
    have zeroMinus := constantDimension_holds ν C (-1) (by decide +kernel)
    have minusEq := Dimension.literal_unique minus zeroMinus
    refine ⟨prefixShape ++ [Dim.lit feature],?_,prefixHold.append (.cons (constantDimension_holds ν C feature exact) .nil)⟩
    rw [split,minusEq,hi.literalValues hold,prefixHold.literalValues hprefix]
    simp only [Host.Mlx.Ffi.infer,NativeRoles.reshape_trailing_literals is ps feature nonnegative divisor divides quotient]
    rfl

end Host.Mlx.Ffi.Annotated
