import host.sim.template.a4pre_first_tail_x15_r0_body.st129.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 129 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB129 : nodupT PRE_first_tail_x15_r0_body.st129.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup129 : PRE_first_tail_x15_r0_body.st129.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB129).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB129 : PRE_first_tail_x15_r0_body.st129.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound129 : ∀ b ∈ PRE_first_tail_x15_r0_body.st129.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB129 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr129 := PRE_first_tail_x15_r0_body.st129.s2.trace.take 26
kernel_rfl PRE_first_tail_x15_r0_body.traceEq129 : PRE_first_tail_x15_r0_body.st129.s2.trace = PRE_first_tail_x15_r0_body.trFr129 ++ PRE_first_tail_x15_r0_body.st129.s0.trace
theorem PRE_first_tail_x15_r0_body.trace129 : ∃ fr, PRE_first_tail_x15_r0_body.st129.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st129.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq129⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide129 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB129 : (PRE_first_tail_x15_r0_body.wide129.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st129.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix129 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide129, WFix Map.id (Present PRE_first_tail_x15_r0_body.st129.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB129 p hp)

end Host.Load.Run.Tpl
