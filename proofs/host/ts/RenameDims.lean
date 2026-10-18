import host.ts.RenameLive
import host.ts.RenameProtocol
namespace Host.Ts.Ren
open Host.Mlx.Ffi

theorem dimOf (R : Host.Ts.Ren) (x : NumV) : R.dim (Host.Mlx.Ffi.dimOf x) =
    Host.Mlx.Ffi.dimOf (R.num x) := by
  cases x with
  | lit f => cases h : F64.toInt? f <;> simp only [Host.Mlx.Ffi.dimOf, h, dim, num]
  | ref _ => rfl

theorem num_injective (R : Host.Ts.Ren) (h : Function.Injective R.n) : Function.Injective R.num := by
  intro a b hab
  cases a <;> cases b <;> simp only [num, NumV.lit.injEq, NumV.ref.injEq, reduceCtorEq] at hab ⊢
  · exact hab
  · exact h hab

theorem dim_injective (R : Host.Ts.Ren) (h : Function.Injective R.n) : Function.Injective R.dim := by
  intro a b hab
  cases a <;> cases b <;> simp only [dim, Dim.lit.injEq, Dim.sym.injEq, reduceCtorEq] at hab ⊢
  · exact hab
  · exact R.num_injective h hab

end Host.Ts.Ren

namespace Host.Mlx.Ffi
open Host.Ts

theorem dAdd_renamed (R : Ren) (a b : Dim) :
    ComputationR R (fun x y => y = R.dim x) (dAdd a b) (dAdd (R.dim a) (R.dim b)) := by
  cases a <;> cases b
  all_goals first
  | exact ComputationR.pure rfl
  | apply ComputationR.bind (ComputationR.numBin R .add _ _)
    intro x y hy
    subst y
    exact ComputationR.pure (R.dimOf x).symm

theorem dSub_renamed (R : Ren) (a b : Dim) :
    ComputationR R (fun x y => y = R.dim x) (dSub a b) (dSub (R.dim a) (R.dim b)) := by
  cases a <;> cases b
  all_goals first
  | exact ComputationR.pure rfl
  | apply ComputationR.bind (ComputationR.numBin R .sub _ _)
    intro x y hy
    subst y
    exact ComputationR.pure (R.dimOf x).symm

theorem dMul_renamed (R : Ren) (a b : Dim) :
    ComputationR R (fun x y => y = R.dim x) (dMul a b) (dMul (R.dim a) (R.dim b)) := by
  cases a <;> cases b
  all_goals first
  | exact ComputationR.pure rfl
  | apply ComputationR.bind (ComputationR.numBin R .mul _ _)
    intro x y hy
    subst y
    exact ComputationR.pure (R.dimOf x).symm

theorem dLt_renamed (R : Ren) (a b : Dim) :
    ComputationR R Eq (dLt a b) (dLt (R.dim a) (R.dim b)) := by
  cases a <;> cases b
  all_goals first
  | exact ComputationR.pure rfl
  | exact ComputationR.numTest R .lt _ _

theorem dEq_renamed (R : Ren) (h : Function.Injective R.n) (a b : Dim) :
    ComputationR R Eq (dEq a b) (dEq (R.dim a) (R.dim b)) := by
  cases a with
  | lit i =>
    cases b with
    | lit j => exact ComputationR.pure rfl
    | sym n =>
      simp only [dEq, Ren.dim, reduceCtorEq, decide_false, Bool.cond_false]
      exact ComputationR.numTest R .eq _ _
  | sym n =>
    cases b with
    | lit j =>
      simp only [dEq, Ren.dim, reduceCtorEq, decide_false, Bool.cond_false]
      exact ComputationR.numTest R .eq _ _
    | sym m =>
      by_cases he : n = m
      · subst m
        simp only [dEq, Ren.dim, decide_true, Bool.cond_true]
        exact ComputationR.pure rfl
      · have he' : R.num n ≠ R.num m := fun hnm => he (R.num_injective h hnm)
        simp only [dEq, Ren.dim, Dim.sym.injEq, he, he', decide_false, Bool.cond_false]
        exact ComputationR.numTest R .eq _ _

theorem dMin_renamed (R : Ren) (a b : Dim) :
    ComputationR R (fun x y => y = R.dim x) (dMin a b) (dMin (R.dim a) (R.dim b)) := by
  apply ComputationR.bind (dLt_renamed R a b)
  intro x y hxy
  subst y
  cases x <;> exact ComputationR.pure rfl

theorem dMax_renamed (R : Ren) (a b : Dim) :
    ComputationR R (fun x y => y = R.dim x) (dMax a b) (dMax (R.dim a) (R.dim b)) := by
  apply ComputationR.bind (dLt_renamed R a b)
  intro x y hxy
  subst y
  cases x <;> exact ComputationR.pure rfl

theorem allEq_renamed (R : Ren) (h : Function.Injective R.n) : ∀ (as bs : List Dim),
    ComputationR R Eq (allEq as bs) (allEq (as.map R.dim) (bs.map R.dim))
  | [], [] => ComputationR.pure rfl
  | [], _ :: _ => ComputationR.pure rfl
  | _ :: _, [] => ComputationR.pure rfl
  | a :: as, b :: bs => by
    apply ComputationR.bind (dEq_renamed R h a b)
    intro x y hxy
    subst y
    cases x with
    | false => exact ComputationR.pure rfl
    | true => exact allEq_renamed R h as bs

theorem dProd_renamed (R : Ren) : ∀ (ds : List Dim),
    ComputationR R (fun x y => y = R.dim x) (dProd ds) (dProd (ds.map R.dim))
  | [] => ComputationR.pure rfl
  | d :: ds => by
    apply ComputationR.bind (dProd_renamed R ds)
    intro x y hxy
    subst y
    exact dMul_renamed R d x

end Host.Mlx.Ffi
