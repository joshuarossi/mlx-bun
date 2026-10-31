import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA114 from PRE_first_tail_x15_r0_body.s382 to PRE_first_tail_x15_r0_body.s383 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s382).run PRE_first_tail_x15_r0_body.S382 = some (PRE_first_tail_x15_r0_body.s383, PRE_first_tail_x15_r0_body.S383)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA115 from PRE_first_tail_x15_r0_body.s386 to PRE_first_tail_x15_r0_body.s387 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s386).run PRE_first_tail_x15_r0_body.S386 = some (PRE_first_tail_x15_r0_body.s387, PRE_first_tail_x15_r0_body.S387)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB115 from PRE_first_tail_x15_r0_body.s387 to PRE_first_tail_x15_r0_body.s388 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s387).run PRE_first_tail_x15_r0_body.S387 = some (PRE_first_tail_x15_r0_body.s388, PRE_first_tail_x15_r0_body.S388)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA116 from PRE_first_tail_x15_r0_body.s389 to PRE_first_tail_x15_r0_body.s390 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s389).run PRE_first_tail_x15_r0_body.S389 = some (PRE_first_tail_x15_r0_body.s390, PRE_first_tail_x15_r0_body.S390)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA117 from PRE_first_tail_x15_r0_body.s393 to PRE_first_tail_x15_r0_body.s394 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s393).run PRE_first_tail_x15_r0_body.S393 = some (PRE_first_tail_x15_r0_body.s394, PRE_first_tail_x15_r0_body.S394)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA118 from PRE_first_tail_x15_r0_body.s397 to PRE_first_tail_x15_r0_body.s398 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s397).run PRE_first_tail_x15_r0_body.S397 = some (PRE_first_tail_x15_r0_body.s398, PRE_first_tail_x15_r0_body.S398)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB118 from PRE_first_tail_x15_r0_body.s398 to PRE_first_tail_x15_r0_body.s399 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s398).run PRE_first_tail_x15_r0_body.S398 = some (PRE_first_tail_x15_r0_body.s399, PRE_first_tail_x15_r0_body.S399)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA119 from PRE_first_tail_x15_r0_body.s400 to PRE_first_tail_x15_r0_body.s401 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s400).run PRE_first_tail_x15_r0_body.S400 = some (PRE_first_tail_x15_r0_body.s401, PRE_first_tail_x15_r0_body.S401)
end Host.Load.Run.Tpl
