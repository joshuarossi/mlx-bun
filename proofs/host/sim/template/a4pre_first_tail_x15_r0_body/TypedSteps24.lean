import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB119 from PRE_first_tail_x15_r0_body.s401 to PRE_first_tail_x15_r0_body.s402 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s401).run PRE_first_tail_x15_r0_body.S401 = some (PRE_first_tail_x15_r0_body.s402, PRE_first_tail_x15_r0_body.S402)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA120 from PRE_first_tail_x15_r0_body.s403 to PRE_first_tail_x15_r0_body.s404 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s403).run PRE_first_tail_x15_r0_body.S403 = some (PRE_first_tail_x15_r0_body.s404, PRE_first_tail_x15_r0_body.S404)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB120 from PRE_first_tail_x15_r0_body.s404 to PRE_first_tail_x15_r0_body.s405 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s404).run PRE_first_tail_x15_r0_body.S404 = some (PRE_first_tail_x15_r0_body.s405, PRE_first_tail_x15_r0_body.S405)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA121 from PRE_first_tail_x15_r0_body.s406 to PRE_first_tail_x15_r0_body.s407 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s406).run PRE_first_tail_x15_r0_body.S406 = some (PRE_first_tail_x15_r0_body.s407, PRE_first_tail_x15_r0_body.S407)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA122 from PRE_first_tail_x15_r0_body.s410 to PRE_first_tail_x15_r0_body.s411 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s410).run PRE_first_tail_x15_r0_body.S410 = some (PRE_first_tail_x15_r0_body.s411, PRE_first_tail_x15_r0_body.S411)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB122 from PRE_first_tail_x15_r0_body.s411 to PRE_first_tail_x15_r0_body.s412 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s411).run PRE_first_tail_x15_r0_body.S411 = some (PRE_first_tail_x15_r0_body.s412, PRE_first_tail_x15_r0_body.S412)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA123 from PRE_first_tail_x15_r0_body.s413 to PRE_first_tail_x15_r0_body.s414 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s413).run PRE_first_tail_x15_r0_body.S413 = some (PRE_first_tail_x15_r0_body.s414, PRE_first_tail_x15_r0_body.S414)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA124 from PRE_first_tail_x15_r0_body.s417 to PRE_first_tail_x15_r0_body.s418 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s417).run PRE_first_tail_x15_r0_body.S417 = some (PRE_first_tail_x15_r0_body.s418, PRE_first_tail_x15_r0_body.S418)
end Host.Load.Run.Tpl
