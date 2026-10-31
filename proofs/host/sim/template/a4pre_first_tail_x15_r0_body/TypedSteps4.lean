import host.sim.template.a4pre_first_tail_x15_r0_body.H2
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA20 from PRE_first_tail_x15_r0_body.s64 to PRE_first_tail_x15_r0_body.s65 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s64).run PRE_first_tail_x15_r0_body.S64 = some (PRE_first_tail_x15_r0_body.s65, PRE_first_tail_x15_r0_body.S65)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB20 from PRE_first_tail_x15_r0_body.s65 to PRE_first_tail_x15_r0_body.s66 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s65).run PRE_first_tail_x15_r0_body.S65 = some (PRE_first_tail_x15_r0_body.s66, PRE_first_tail_x15_r0_body.S66)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA21 from PRE_first_tail_x15_r0_body.s67 to PRE_first_tail_x15_r0_body.s68 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s67).run PRE_first_tail_x15_r0_body.S67 = some (PRE_first_tail_x15_r0_body.s68, PRE_first_tail_x15_r0_body.S68)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA22 from PRE_first_tail_x15_r0_body.s71 to PRE_first_tail_x15_r0_body.s72 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s71).run PRE_first_tail_x15_r0_body.S71 = some (PRE_first_tail_x15_r0_body.s72, PRE_first_tail_x15_r0_body.S72)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB22 from PRE_first_tail_x15_r0_body.s72 to PRE_first_tail_x15_r0_body.s73 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s72).run PRE_first_tail_x15_r0_body.S72 = some (PRE_first_tail_x15_r0_body.s73, PRE_first_tail_x15_r0_body.S73)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA23 from PRE_first_tail_x15_r0_body.s74 to PRE_first_tail_x15_r0_body.s75 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s74).run PRE_first_tail_x15_r0_body.S74 = some (PRE_first_tail_x15_r0_body.s75, PRE_first_tail_x15_r0_body.S75)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA24 from PRE_first_tail_x15_r0_body.s78 to PRE_first_tail_x15_r0_body.s79 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s78).run PRE_first_tail_x15_r0_body.S78 = some (PRE_first_tail_x15_r0_body.s79, PRE_first_tail_x15_r0_body.S79)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA25 from PRE_first_tail_x15_r0_body.s82 to PRE_first_tail_x15_r0_body.s83 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s82).run PRE_first_tail_x15_r0_body.S82 = some (PRE_first_tail_x15_r0_body.s83, PRE_first_tail_x15_r0_body.S83)
end Host.Load.Run.Tpl
