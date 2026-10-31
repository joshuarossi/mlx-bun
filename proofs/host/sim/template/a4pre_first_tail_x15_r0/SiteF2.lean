import host.sim.template.a4pre_first_tail_x15_r0.st2.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 2 of chain `PRE_first_tail_x15_r0`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0.wrNodupB2 : nodupT PRE_first_tail_x15_r0.st2.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0.wrNodup2 : PRE_first_tail_x15_r0.st2.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0.wrNodupB2).2
kernel_rfl PRE_first_tail_x15_r0.wrBoundB2 : PRE_first_tail_x15_r0.st2.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0.wrBound2 : ∀ b ∈ PRE_first_tail_x15_r0.st2.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0.wrBoundB2 b hb)
noncomputable def PRE_first_tail_x15_r0.trFr2 := PRE_first_tail_x15_r0.st2.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0.traceEq2 : PRE_first_tail_x15_r0.st2.s2.trace = PRE_first_tail_x15_r0.trFr2 ++ PRE_first_tail_x15_r0.st2.s0.trace
theorem PRE_first_tail_x15_r0.trace2 : ∃ fr, PRE_first_tail_x15_r0.st2.s2.trace = fr ++ PRE_first_tail_x15_r0.st2.s0.trace := ⟨_, PRE_first_tail_x15_r0.traceEq2⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0.wide2 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0.wfixB2 : (PRE_first_tail_x15_r0.wide2.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0.st2.s0) p.2) = true
theorem PRE_first_tail_x15_r0.wfix2 : ∀ p ∈ PRE_first_tail_x15_r0.wide2, WFix Map.id (Present PRE_first_tail_x15_r0.st2.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0.wfixB2 p hp)

end Host.Load.Run.Tpl
