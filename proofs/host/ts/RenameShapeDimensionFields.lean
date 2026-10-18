import host.ts.RenameParametricShapeSpread

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem ListR.nth_some {α β : Type} {rel : α → β → Prop} {xs : List α} {ys : List β}
    (h : ListR rel xs ys) (i : Nat) (x : α) (hx : xs[i]? = some x) :
    ∃ y, ys[i]? = some y ∧ rel x y := by
  induction h generalizing i with
  | nil => simp at hx
  | cons hr hs ih =>
    cases i with
    | zero => simp only [List.getElem?_cons_zero,Option.some.injEq] at hx; subst x; exact ⟨_,rfl,hr⟩
    | succ i => exact ih i hx

end Host.Ts.Owned.Parametric

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem Dimension.literal_one {ν : Nat → F64} {C : CSrv} {d : Dim}
    (h : Dimension.Holds ν C (.literal (.lit (F64.ofNat 1))) d) : d = .lit 1 := by
  cases h with
  | literal e i hd hi =>
    have hone : F64.toInt? ((SymE.lit (F64.ofNat 1)).eval ν) = some 1 := by rfl
    have he : i = 1 := Option.some.inj (hi.symm.trans hone)
    subst i
    rfl

end Host.Mlx.Ffi.Annotated
