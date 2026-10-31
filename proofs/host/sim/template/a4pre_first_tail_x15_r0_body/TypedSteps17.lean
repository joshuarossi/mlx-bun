import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB84 from PRE_first_tail_x15_r0_body.s308 to PRE_first_tail_x15_r0_body.s309 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s308).run PRE_first_tail_x15_r0_body.S308 = some (PRE_first_tail_x15_r0_body.s309, PRE_first_tail_x15_r0_body.S309)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA85 from PRE_first_tail_x15_r0_body.s311 to PRE_first_tail_x15_r0_body.s312 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s311).run PRE_first_tail_x15_r0_body.S311 = some (PRE_first_tail_x15_r0_body.s312, PRE_first_tail_x15_r0_body.S312)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA86 from PRE_first_tail_x15_r0_body.s315 to PRE_first_tail_x15_r0_body.s316 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s315).run PRE_first_tail_x15_r0_body.S315 = some (PRE_first_tail_x15_r0_body.s316, PRE_first_tail_x15_r0_body.S316)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA87 from PRE_first_tail_x15_r0_body.s320 to PRE_first_tail_x15_r0_body.s321 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s320).run PRE_first_tail_x15_r0_body.S320 = some (PRE_first_tail_x15_r0_body.s321, PRE_first_tail_x15_r0_body.S321)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB87 from PRE_first_tail_x15_r0_body.s321 to PRE_first_tail_x15_r0_body.s322 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s321).run PRE_first_tail_x15_r0_body.S321 = some (PRE_first_tail_x15_r0_body.s322, PRE_first_tail_x15_r0_body.S322)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA88 from PRE_first_tail_x15_r0_body.s324 to PRE_first_tail_x15_r0_body.s325 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s324).run PRE_first_tail_x15_r0_body.S324 = some (PRE_first_tail_x15_r0_body.s325, PRE_first_tail_x15_r0_body.S325)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB88 from PRE_first_tail_x15_r0_body.s325 to PRE_first_tail_x15_r0_body.s326 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s325).run PRE_first_tail_x15_r0_body.S325 = some (PRE_first_tail_x15_r0_body.s326, PRE_first_tail_x15_r0_body.S326)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA89 from PRE_first_tail_x15_r0_body.s327 to PRE_first_tail_x15_r0_body.s328 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s327).run PRE_first_tail_x15_r0_body.S327 = some (PRE_first_tail_x15_r0_body.s328, PRE_first_tail_x15_r0_body.S328)
end Host.Load.Run.Tpl
