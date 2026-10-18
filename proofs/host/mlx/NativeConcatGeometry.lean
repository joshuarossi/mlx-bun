import host.mlx.NativeSliceGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem setAt_map (f : α → β) (xs : List α) (axis : Nat) (value : α) :
    setAt (xs.map f) axis (f value) = (setAt xs axis value).map f := by
  induction xs generalizing axis with
  | nil => rfl
  | cons x xs ih => cases axis with
    | zero => rfl
    | succ axis => exact congrArg (f x :: ·) (ih axis)

theorem concatShape_literals (left right : List Int) (axis da db : Nat)
    (rank : len left = len right) (matched : setAt left axis 0 = setAt right axis 0) :
    concatShape axis [(left.map Dim.lit,da),(right.map Dim.lit,db)] =
      M.pure (some (((setAt left axis (nthD 0 left axis + nthD 0 right axis)).map Dim.lit),promote da db)) := by
  have hlen : Nat.beq (len (left.map Dim.lit)) (len (right.map Dim.lit)) = true := by
    simp only [Host.Ts.len_map,rank,Nat.beq_refl]
  have equal : allEq (setAt (left.map Dim.lit) axis (.lit 0)) (setAt (right.map Dim.lit) axis (.lit 0)) = M.pure true := by
    rw [setAt_map,setAt_map,matched]
    exact InferenceRoles.allEq_self _
  funext β k
  simp only [concatShape,hlen,equal,M.bind,M.pure,Bool.cond_true,Host.Ts.nthD_map,dAdd]
  rw [setAt_map]

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

/-- Two literal input profiles agree outside the normalized concatenation
axis. The output's exact dimension meanings use the integer sum on that axis. -/
def ConcatGeometry (ν : Nat → F64) (left right output : Shape) (axis : Nat) : Prop :=
  ∃ xs ys : List Int, left.literalValues ν = some xs ∧ right.literalValues ν = some ys ∧
    len xs = len ys ∧ setAt xs axis 0 = setAt ys axis 0 ∧
    LiteralDimensions ν output (setAt xs axis (nthD 0 xs axis + nthD 0 ys axis))

theorem ConcatGeometry.subst (ν : Nat → F64) (θ : Nat → SymE) (left right output : Shape) (axis : Nat) :
    ConcatGeometry ν (Shape.subst θ left) (Shape.subst θ right) (Shape.subst θ output) axis ↔
    ConcatGeometry (Owned.Annotated.nextValuation θ ν) left right output axis := by
  simp only [ConcatGeometry,Shape.literalValues_subst]
  constructor
  · rintro ⟨xs,ys,hx,hy,rank,matched,out⟩
    exact ⟨xs,ys,hx,hy,rank,matched,out.of_subst θ⟩
  · rintro ⟨xs,ys,hx,hy,rank,matched,out⟩
    exact ⟨xs,ys,hx,hy,rank,matched,out.subst θ⟩

theorem ConcatGeometry.infer {ν : Nat → F64} {C : CSrv} {left right output : Shape} {axis : Nat}
    (geometry : ConcatGeometry ν left right output axis) (da db : Nat) {x y : List Dim}
    (hx : Shape.Holds ν C left x) (hy : Shape.Holds ν C right y) :
    ∃ shape, Shape.Holds ν C output shape ∧
      infer (.concat axis) [(x,da),(y,db)] = M.pure (some (.node shape (promote da db))) := by
  obtain ⟨xs,ys,hxv,hyv,rank,matched,out⟩ := geometry
  refine ⟨_,out.holds C,?_⟩
  rw [hx.literalValues hxv,hy.literalValues hyv]
  simp only [Host.Mlx.Ffi.infer]
  have htwo : Nat.beq (len [(xs.map Dim.lit,da),(ys.map Dim.lit,db)]) 1 = false := rfl
  rw [htwo]
  simp only [Bool.cond_false,NativeRoles.concatShape_literals xs ys axis da db rank matched]
  rfl

end Host.Mlx.Ffi.Annotated
