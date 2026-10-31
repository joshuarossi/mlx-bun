import host.sim.template.a4pre_first_tail_x15_r0_body.st15.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 15 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB15 : nodupT PRE_first_tail_x15_r0_body.st15.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup15 : PRE_first_tail_x15_r0_body.st15.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB15).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB15 : PRE_first_tail_x15_r0_body.st15.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound15 : ∀ b ∈ PRE_first_tail_x15_r0_body.st15.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB15 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr15 := PRE_first_tail_x15_r0_body.st15.s3.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq15 : PRE_first_tail_x15_r0_body.st15.s3.trace = PRE_first_tail_x15_r0_body.trFr15 ++ PRE_first_tail_x15_r0_body.st15.s0.trace
theorem PRE_first_tail_x15_r0_body.trace15 : ∃ fr, PRE_first_tail_x15_r0_body.st15.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st15.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq15⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide15 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB15 : (PRE_first_tail_x15_r0_body.wide15.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st15.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix15 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide15, WFix Map.id (Present PRE_first_tail_x15_r0_body.st15.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB15 p hp)

end Host.Load.Run.Tpl
