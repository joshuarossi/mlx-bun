import host.sim.compose.a4b.VWFirstRows
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-- The term x4's prefix leaves in its table for the count: the prompt's length less one. -/
noncomputable def x4CountTerm : SymE :=
  .bin .add (.lit (F64.zero false))
    (.bin .sub (.bin .sub (.var 9) (.lit (F64.zero false))) (.lit (F64.fin false 1 (0))))

kernel_rfl x4Count7 : x4CountTerm.eval (fun _ => F64.ofNat 7) = F64.ofNat 6
kernel_rfl x4Count8 : x4CountTerm.eval (fun _ => F64.ofNat 8) = F64.ofNat 7
kernel_rfl x4Count9 : x4CountTerm.eval (fun _ => F64.ofNat 9) = F64.ofNat 8

/-- x4's count is its term's value at the prompt's length. -/
theorem x4Count {r : Row} {i : Cls.Inst} (hr : r ∈ [first_tail_x4.r0]) (hi : InRow r i)
    {ν : Nat → F64} (h9 : ν 9 = F64.ofNat i.L) : F64.ofNat i.n = x4CountTerm.eval ν := by
  obtain rfl : r = first_tail_x4.r0 := List.mem_singleton.mp hr
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [first_tail_x4.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  have hc : (i.L = 7 ∧ i.n = 6) ∨ (i.L = 8 ∧ i.n = 7) ∨ (i.L = 9 ∧ i.n = 8) := by omega
  have e : x4CountTerm.eval ν = x4CountTerm.eval (fun _ => ν 9) := rfl
  rw [e, h9]
  rcases hc with ⟨hL, hn⟩ | ⟨hL, hn⟩ | ⟨hL, hn⟩ <;> rw [hL, hn]
  · exact x4Count7.symm
  · exact x4Count8.symm
  · exact x4Count9.symm

end Host.Ts.Sim.Compose.VWFirst
