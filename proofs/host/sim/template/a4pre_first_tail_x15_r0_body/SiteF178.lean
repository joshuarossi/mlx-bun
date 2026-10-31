import host.sim.template.a4pre_first_tail_x15_r0_body.st178.Foot
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 178 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB178 : nodupT PRE_first_tail_x15_r0_body.st178.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup178 : PRE_first_tail_x15_r0_body.st178.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB178).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB178 : PRE_first_tail_x15_r0_body.st178.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound178 : ∀ b ∈ PRE_first_tail_x15_r0_body.st178.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB178 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr178 := PRE_first_tail_x15_r0_body.st178.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq178 : PRE_first_tail_x15_r0_body.st178.s2.trace = PRE_first_tail_x15_r0_body.trFr178 ++ PRE_first_tail_x15_r0_body.st178.s0.trace
theorem PRE_first_tail_x15_r0_body.trace178 : ∃ fr, PRE_first_tail_x15_r0_body.st178.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st178.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq178⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide178 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB178 : (PRE_first_tail_x15_r0_body.wide178.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st178.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix178 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide178, WFix Map.id (Present PRE_first_tail_x15_r0_body.st178.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB178 p hp)

end Host.Load.Run.Tpl
