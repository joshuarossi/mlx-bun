import host.sim.template.a4pre_first_tail_x15_r0_body.st24.H0
import host.sim.template.BootEq
import host.sim.StageRel
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st24.bodyLast from PRE_first_tail_x15_r0_body.st24.s4 to PRE_first_tail_x15_r0_body.st24.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st24.F PRE_first_tail_x15_r0_body.st24.s4).run PRE_first_tail_x15_r0_body.st24.S4 = some (PRE_first_tail_x15_r0_body.st24.s5, PRE_first_tail_x15_r0_body.st24.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st24.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st24.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st24.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st24.s5.stack = true

end Host.Load.Run.Tpl
