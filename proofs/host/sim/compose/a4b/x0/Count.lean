import host.sim.compose.a4b.X4Count
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

kernel_rfl x0Count2 : x4CountTerm.eval (fun _ => F64.ofNat 2) = F64.ofNat 1

/-- x0's count is the term x4's prefix leaves, at the prompt's length. -/
theorem x0Count {r : Row} {i : Cls.Inst} (hr : r ∈ [first_tail_x0.r0]) (hi : InRow r i)
    {ν : Nat → F64} (h9 : ν 9 = F64.ofNat i.L) : F64.ofNat i.n = x4CountTerm.eval ν := by
  obtain rfl : r = first_tail_x0.r0 := List.mem_singleton.mp hr
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [first_tail_x0.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  have hc : i.L = 2 ∧ i.n = 1 := by omega
  have e : x4CountTerm.eval ν = x4CountTerm.eval (fun _ => ν 9) := rfl
  rw [e, h9, hc.1, hc.2]
  exact x0Count2.symm

/-- x0's rows, and the four facts `firstTailFacts` gives the wide rows. -/
def x0Rows : List Row := [first_tail_x0.r0]

theorem x0TailFacts {r : Row} {i : Cls.Inst} (hr : r ∈ x0Rows) (hi : InRow r i) :
    2 ≤ i.L ∧ i.L ≤ 2048 ∧ i.n = i.L - 1 ∧ i.C = 2048 := by
  obtain rfl : r = first_tail_x0.r0 := List.mem_singleton.mp hr
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [first_tail_x0.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  omega

/-- What x0's row fixes. -/
theorem x0Facts {i : Cls.Inst} (hi : InRow first_tail_x0.r0 i) : i.L = 2 ∧ i.n = 1 ∧ i.C = 2048 := by
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [first_tail_x0.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  omega

end Host.Ts.Sim.Compose.VWFirst
