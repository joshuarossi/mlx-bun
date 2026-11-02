import host.sim.dispatch.Base
set_option Elab.async false

/-! # A frame list's lookup, for POST's hand-off -/

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

theorem lookupW_mem {a : Nat} {w : WFrame} : ∀ {l : List (Nat × WFrame)}, Disp.lookupW a l = some w → (a, w) ∈ l
  | [], h => by cases h
  | (b, v) :: l, h => by
    unfold Disp.lookupW at h
    cases hb : Nat.beq a b with
    | true =>
      rw [hb] at h
      have e := Nat.eq_of_beq_eq_true hb
      subst e
      cases h
      exact List.mem_cons_self
    | false =>
      rw [hb] at h
      exact List.mem_cons_of_mem _ (lookupW_mem h)

end Host.Ts.Sim.Template
