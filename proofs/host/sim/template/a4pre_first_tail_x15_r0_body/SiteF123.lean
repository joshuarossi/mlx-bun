import host.sim.template.a4pre_first_tail_x15_r0_body.st123.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 123 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB123 : nodupT PRE_first_tail_x15_r0_body.st123.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup123 : PRE_first_tail_x15_r0_body.st123.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB123).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB123 : PRE_first_tail_x15_r0_body.st123.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound123 : ∀ b ∈ PRE_first_tail_x15_r0_body.st123.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB123 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr123 := PRE_first_tail_x15_r0_body.st123.s3.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq123 : PRE_first_tail_x15_r0_body.st123.s3.trace = PRE_first_tail_x15_r0_body.trFr123 ++ PRE_first_tail_x15_r0_body.st123.s0.trace
theorem PRE_first_tail_x15_r0_body.trace123 : ∃ fr, PRE_first_tail_x15_r0_body.st123.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st123.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq123⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide123 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB123 : (PRE_first_tail_x15_r0_body.wide123.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st123.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix123 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide123, WFix Map.id (Present PRE_first_tail_x15_r0_body.st123.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB123 p hp)

end Host.Load.Run.Tpl
