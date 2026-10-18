import host.ts.RenameDims
namespace Host.Ts

theorem lenL_map {α β : Type} (f : α → β) : ∀ (xs : List α) (n : Nat),
    lenL (xs.map f) n = lenL xs n
  | [], _ => rfl
  | _ :: xs, n => lenL_map f xs (n + 1)

theorem len_map {α β : Type} (f : α → β) (xs : List α) : len (xs.map f) = len xs :=
  lenL_map f xs 0

theorem nthD_map {α β : Type} (f : α → β) (d : α) : ∀ (xs : List α) (i : Nat),
    nthD (f d) (xs.map f) i = f (nthD d xs i)
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: xs, i + 1 => nthD_map f d xs i

end Host.Ts

namespace Host.Mlx.Ffi
open Host.Ts

theorem setAt_map {α β : Type} (f : α → β) : ∀ (xs : List α) (i : Nat) (v : α),
    setAt (xs.map f) i (f v) = (setAt xs i v).map f
  | [], _, _ => rfl
  | _ :: _, 0, _ => rfl
  | _ :: xs, i + 1, v => by simp only [setAt, List.map_cons, setAt_map f xs i v]

def shapeDt (R : Ren) (p : List Dim × Nat) : List Dim × Nat := (p.1.map R.dim, p.2)

def out (R : Ren) : Out → Out
  | .node s d => .node (s.map R.dim) d
  | .same i => .same i

theorem concatShape_renamed (R : Ren) (h : Function.Injective R.n) (axis : Nat) :
    ∀ (xs : List (List Dim × Nat)),
      ComputationR R (fun x y => y = x.map (shapeDt R))
        (concatShape axis xs) (concatShape axis (xs.map (shapeDt R)))
  | [] => ComputationR.pure rfl
  | [(s, d)] => ComputationR.pure rfl
  | (s, d) :: (s1, d1) :: rest => by
    apply ComputationR.bind (concatShape_renamed R h axis ((s1, d1) :: rest))
    intro x y hxy
    subst y
    cases x with
    | none => exact ComputationR.pure rfl
    | some p =>
      obtain ⟨r, dr⟩ := p
      simp only [shapeDt, Option.map_some, len_map]
      cases hb : Nat.beq (len s) (len r) with
      | false =>
        simp only [Bool.cond_false]
        exact ComputationR.pure rfl
      | true =>
        simp only [Bool.cond_true]
        rw [show (Dim.lit 0 : Dim) = R.dim (.lit 0) from rfl,
          setAt_map R.dim s axis (.lit 0), setAt_map R.dim r axis (.lit 0)]
        apply ComputationR.bind (allEq_renamed R h _ _)
        intro x y hxy
        subst y
        cases x with
        | false => exact ComputationR.pure rfl
        | true =>
          simp only [Bool.cond_true]
          rw [nthD_map R.dim (.lit 0), nthD_map R.dim (.lit 0)]
          apply ComputationR.bind (dAdd_renamed R _ _)
          intro a b hab
          subst b
          exact ComputationR.pure (by simp only [shapeDt, setAt_map, Option.map_some])

theorem infer_concat_renamed (R : Ren) (h : Function.Injective R.n) (axis : Nat)
    (xs : List (List Dim × Nat)) :
    ComputationR R (fun x y => y = x.map (out R)) (infer (.concat axis) xs)
      (infer (R.prim (.concat axis)) (xs.map (shapeDt R))) := by
  simp only [infer, Ren.prim, len_map]
  cases hb : Nat.beq (len xs) 1
  · simp only [Bool.cond_false]
    apply ComputationR.bind (concatShape_renamed R h axis xs)
    intro x y hxy
    subst y
    cases x with
    | none => exact ComputationR.pure rfl
    | some p => cases p; exact ComputationR.pure rfl
  · simp only [Bool.cond_true]
    exact ComputationR.pure rfl

end Host.Mlx.Ffi
