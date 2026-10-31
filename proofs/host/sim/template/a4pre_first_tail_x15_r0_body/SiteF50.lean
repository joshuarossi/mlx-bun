import host.sim.template.a4pre_first_tail_x15_r0_body.st50.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 50 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB50 : nodupT PRE_first_tail_x15_r0_body.st50.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup50 : PRE_first_tail_x15_r0_body.st50.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB50).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB50 : PRE_first_tail_x15_r0_body.st50.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound50 : ∀ b ∈ PRE_first_tail_x15_r0_body.st50.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB50 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr50 := PRE_first_tail_x15_r0_body.st50.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq50 : PRE_first_tail_x15_r0_body.st50.s2.trace = PRE_first_tail_x15_r0_body.trFr50 ++ PRE_first_tail_x15_r0_body.st50.s0.trace
theorem PRE_first_tail_x15_r0_body.trace50 : ∃ fr, PRE_first_tail_x15_r0_body.st50.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st50.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq50⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide50 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB50 : (PRE_first_tail_x15_r0_body.wide50.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st50.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix50 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide50, WFix Map.id (Present PRE_first_tail_x15_r0_body.st50.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB50 p hp)

end Host.Load.Run.Tpl
