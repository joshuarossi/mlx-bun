import host.sim.compose.a4b.PrefillFirstTailX15
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def firstTailRows : List Row := [first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, first_tail_x22.r0, first_tail_x22.r1, first_tail_x23.r0, first_tail_x24.r0, first_tail_x25.r0, first_tail_x26.r0, first_tail_x26.r1, first_tail_x27.r0, first_tail_x28.r0, first_tail_x29.r0, first_tail_x30.r0, first_tail_x30.r1, first_tail_x31.r0, first_tail_x32.r0, first_tail_x32.r1, first_tail_x33.r0, first_tail_x33.r1, first_tail_x34.r0, first_tail_x34.r1, first_tail_x35.r0, first_tail_x35.r1, first_tail_x36.r0]

theorem firstTailFacts {r : Row} {i : Cls.Inst} (hr : r ∈ firstTailRows) (hi : InRow r i) :
    2 ≤ i.L ∧ i.L ≤ 2048 ∧ i.n = i.L - 1 ∧ i.C = 2048 := by
  simp only [firstTailRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, first_tail_x22.r0, first_tail_x22.r1, first_tail_x23.r0, first_tail_x24.r0, first_tail_x25.r0, first_tail_x26.r0, first_tail_x26.r1, first_tail_x27.r0, first_tail_x28.r0, first_tail_x29.r0, first_tail_x30.r0, first_tail_x30.r1, first_tail_x31.r0, first_tail_x32.r0, first_tail_x32.r1, first_tail_x33.r0, first_tail_x33.r1, first_tail_x34.r0, first_tail_x34.r1, first_tail_x35.r0, first_tail_x35.r1, first_tail_x36.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    omega
end Host.Ts.Sim.Compose.VWFirst
