import host.sim.template.a4pre_first_tail_x15_r0_body.st0.H0
import host.sim.template.BootEq
import host.sim.StageRel
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st0.bodyLast from PRE_first_tail_x15_r0_body.st0.s6 to PRE_first_tail_x15_r0_body.st0.s7 :
  interpS (step PRE_first_tail_x15_r0_body.st0.F PRE_first_tail_x15_r0_body.st0.s6).run PRE_first_tail_x15_r0_body.st0.S6 = some (PRE_first_tail_x15_r0_body.st0.s7, PRE_first_tail_x15_r0_body.st0.S7)
kernel_rfl PRE_first_tail_x15_r0_body.st0.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st0.s6.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st0.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st0.s7.stack = true

end Host.Load.Run.Tpl
