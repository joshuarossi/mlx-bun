import host.sim.LoopArith
import host.sim.Upd
import host.sim.template.ShiftJS

/-! # Facts of a loop case for the loop induction (`host.sim.LoopInv`)

Generic lemmas turning the Boolean checks of a case's facts module into the
statements `LoopCase` consumes. -/

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

/-- Addresses every loop case keeps: `forwarded`, `emitted` and the cell of the driver's
`emitted` binding (the loop invariant's `fixA`). -/
def loopFix : List Nat := [2673447, 12502, 2590]

theorem loopTheta_big {g : Bool} {w j : Nat} (h : 17 ≤ j) : loopTheta g w j = .var j := by
  unfold loopTheta
  split <;> first | omega | rfl

/-- An explicit substitution agrees with `loopTheta g 17` everywhere if it does below 18 and
lists no variable from 18 on. -/
theorem theta_eq {l : List (Nat × SymE)} {g : Bool}
    (h1 : (List.range 18).all (fun j => decide (thetaOf l j = loopTheta g 17 j)) = true)
    (h2 : l.all (fun p => Nat.blt p.1 18) = true) : ∀ j, thetaOf l j = loopTheta g 17 j := by
  intro j
  by_cases hj : j < 18
  · have := List.all_eq_true.mp h1 j (List.mem_range.mpr hj)
    simpa using this
  · rw [loopTheta_big (by omega)]
    unfold thetaOf
    have : l.find? (fun p => p.1 == j) = none := by
      rw [List.find?_eq_none]
      intro x hx
      have := List.all_eq_true.mp h2 x hx
      simp only [Nat.blt_eq] at this
      simp only [beq_iff_eq]
      omega
    rw [this]
    rfl

/-- A control that is not a return. -/
def notRetB : Ctl → Bool
  | .ret _ => false
  | _ => true

theorem notRet_of {c : Ctl} (h : notRetB c = true) : ∀ v, c ≠ .ret v := by
  intro v hv
  rw [hv] at h
  cases h

end Host.Ts.Sim.Template
