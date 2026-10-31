import host.sim.template.a4pre_first_tail_x15_r0_body.st106.H0
import host.sim.template.BootEq
import host.sim.StageRel
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st106.bodyLast from PRE_first_tail_x15_r0_body.st106.s1 to PRE_first_tail_x15_r0_body.st106.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st106.F PRE_first_tail_x15_r0_body.st106.s1).run PRE_first_tail_x15_r0_body.st106.S1 = some (PRE_first_tail_x15_r0_body.st106.s2, PRE_first_tail_x15_r0_body.st106.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st106.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st106.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st106.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st106.s2.stack = true

end Host.Load.Run.Tpl
