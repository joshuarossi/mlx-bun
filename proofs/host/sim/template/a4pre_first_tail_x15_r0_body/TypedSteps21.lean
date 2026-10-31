import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB104 from PRE_first_tail_x15_r0_body.s384 to PRE_first_tail_x15_r0_body.s385 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s384).run PRE_first_tail_x15_r0_body.S384 = some (PRE_first_tail_x15_r0_body.s385, PRE_first_tail_x15_r0_body.S385)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA105 from PRE_first_tail_x15_r0_body.s386 to PRE_first_tail_x15_r0_body.s387 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s386).run PRE_first_tail_x15_r0_body.S386 = some (PRE_first_tail_x15_r0_body.s387, PRE_first_tail_x15_r0_body.S387)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB105 from PRE_first_tail_x15_r0_body.s387 to PRE_first_tail_x15_r0_body.s388 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s387).run PRE_first_tail_x15_r0_body.S387 = some (PRE_first_tail_x15_r0_body.s388, PRE_first_tail_x15_r0_body.S388)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA106 from PRE_first_tail_x15_r0_body.s389 to PRE_first_tail_x15_r0_body.s390 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s389).run PRE_first_tail_x15_r0_body.S389 = some (PRE_first_tail_x15_r0_body.s390, PRE_first_tail_x15_r0_body.S390)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA107 from PRE_first_tail_x15_r0_body.s393 to PRE_first_tail_x15_r0_body.s394 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s393).run PRE_first_tail_x15_r0_body.S393 = some (PRE_first_tail_x15_r0_body.s394, PRE_first_tail_x15_r0_body.S394)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB107 from PRE_first_tail_x15_r0_body.s394 to PRE_first_tail_x15_r0_body.s395 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s394).run PRE_first_tail_x15_r0_body.S394 = some (PRE_first_tail_x15_r0_body.s395, PRE_first_tail_x15_r0_body.S395)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA108 from PRE_first_tail_x15_r0_body.s397 to PRE_first_tail_x15_r0_body.s398 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s397).run PRE_first_tail_x15_r0_body.S397 = some (PRE_first_tail_x15_r0_body.s398, PRE_first_tail_x15_r0_body.S398)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA109 from PRE_first_tail_x15_r0_body.s401 to PRE_first_tail_x15_r0_body.s402 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s401).run PRE_first_tail_x15_r0_body.S401 = some (PRE_first_tail_x15_r0_body.s402, PRE_first_tail_x15_r0_body.S402)
end Host.Load.Run.Tpl
