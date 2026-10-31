import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.CallGen
import host.sim.template.EndGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

def PRE_first_tail_x15_r0_suffix.arrElEnd_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_suffix.arrEEnd_2665 : arrOf PRE_first_tail_x15_r0_suffix.s8 2665 = arrOf PRE_first_tail_x15_r0_suffix.s0 2665 ++ PRE_first_tail_x15_r0_suffix.arrElEnd_2665
kernel_rfl PRE_first_tail_x15_r0_suffix.arrAEnd_2665 : isArrB PRE_first_tail_x15_r0_suffix.s8 2665 = true
theorem PRE_first_tail_x15_r0_suffix.arrEnd_2665 : ∃ o, PRE_first_tail_x15_r0_suffix.s8.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_suffix.s0 2665 ++ PRE_first_tail_x15_r0_suffix.arrElEnd_2665) :=
  arrExt_of PRE_first_tail_x15_r0_suffix.arrEEnd_2665 PRE_first_tail_x15_r0_suffix.arrAEnd_2665
kernel_rfl PRE_first_tail_x15_r0_suffix.arrNEnd_2665 : numRefsB PRE_first_tail_x15_r0_suffix.S0.tab.length PRE_first_tail_x15_r0_suffix.arrElEnd_2665 = true
theorem PRE_first_tail_x15_r0_suffix.arrREnd_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_suffix.S0.tab.length PRE_first_tail_x15_r0_suffix.arrElEnd_2665 := numRefs_of PRE_first_tail_x15_r0_suffix.arrNEnd_2665

def PRE_first_tail_x15_r0_suffix.arrElEnd_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_suffix.arrEEnd_2673467 : arrOf PRE_first_tail_x15_r0_suffix.s8 2673467 = arrOf PRE_first_tail_x15_r0_suffix.s0 2673467 ++ PRE_first_tail_x15_r0_suffix.arrElEnd_2673467
kernel_rfl PRE_first_tail_x15_r0_suffix.arrAEnd_2673467 : isArrB PRE_first_tail_x15_r0_suffix.s8 2673467 = true
theorem PRE_first_tail_x15_r0_suffix.arrEnd_2673467 : ∃ o, PRE_first_tail_x15_r0_suffix.s8.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_suffix.s0 2673467 ++ PRE_first_tail_x15_r0_suffix.arrElEnd_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_suffix.arrEEnd_2673467 PRE_first_tail_x15_r0_suffix.arrAEnd_2673467
kernel_rfl PRE_first_tail_x15_r0_suffix.arrNEnd_2673467 : numRefsB PRE_first_tail_x15_r0_suffix.S0.tab.length PRE_first_tail_x15_r0_suffix.arrElEnd_2673467 = true
theorem PRE_first_tail_x15_r0_suffix.arrREnd_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_suffix.S0.tab.length PRE_first_tail_x15_r0_suffix.arrElEnd_2673467 := numRefs_of PRE_first_tail_x15_r0_suffix.arrNEnd_2673467

kernel_rfl PRE_first_tail_x15_r0_suffix.w4910kEnd : isArrB PRE_first_tail_x15_r0_suffix.s8 4910 = false
theorem PRE_first_tail_x15_r0_suffix.keepEnd (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_suffix.s0 q) PRE_first_tail_x15_r0_suffix.s8 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_suffix.w4910kEnd ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_suffix.arrEnd_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_suffix.arrElEnd_2665]

end Host.Load.Run.Tpl
