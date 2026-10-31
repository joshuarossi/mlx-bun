import host.sim.template.a4pre_first_tail_x15_r0_body.st18.H0
import host.sim.template.BootEq
import host.sim.StageRel
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st18.bodyLast from PRE_first_tail_x15_r0_body.st18.s2 to PRE_first_tail_x15_r0_body.st18.s3 :
  interpS (step PRE_first_tail_x15_r0_body.st18.F PRE_first_tail_x15_r0_body.st18.s2).run PRE_first_tail_x15_r0_body.st18.S2 = some (PRE_first_tail_x15_r0_body.st18.s3, PRE_first_tail_x15_r0_body.st18.S3)
kernel_rfl PRE_first_tail_x15_r0_body.st18.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st18.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st18.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st18.s3.stack = true

end Host.Load.Run.Tpl
