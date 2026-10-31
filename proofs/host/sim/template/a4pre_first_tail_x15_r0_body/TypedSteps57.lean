import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.a4pre_first_tail_x15_r0_body.H33
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA283 from PRE_first_tail_x15_r0_body.s1047 to PRE_first_tail_x15_r0_body.s1048 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1047).run PRE_first_tail_x15_r0_body.S1047 = some (PRE_first_tail_x15_r0_body.s1048, PRE_first_tail_x15_r0_body.S1048)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB283 from PRE_first_tail_x15_r0_body.s1048 to PRE_first_tail_x15_r0_body.s1049 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1048).run PRE_first_tail_x15_r0_body.S1048 = some (PRE_first_tail_x15_r0_body.s1049, PRE_first_tail_x15_r0_body.S1049)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA284 from PRE_first_tail_x15_r0_body.s1050 to PRE_first_tail_x15_r0_body.s1051 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1050).run PRE_first_tail_x15_r0_body.S1050 = some (PRE_first_tail_x15_r0_body.s1051, PRE_first_tail_x15_r0_body.S1051)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA285 from PRE_first_tail_x15_r0_body.s1054 to PRE_first_tail_x15_r0_body.s1055 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1054).run PRE_first_tail_x15_r0_body.S1054 = some (PRE_first_tail_x15_r0_body.s1055, PRE_first_tail_x15_r0_body.S1055)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB285 from PRE_first_tail_x15_r0_body.s1055 to PRE_first_tail_x15_r0_body.s1056 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1055).run PRE_first_tail_x15_r0_body.S1055 = some (PRE_first_tail_x15_r0_body.s1056, PRE_first_tail_x15_r0_body.S1056)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA286 from PRE_first_tail_x15_r0_body.s1058 to PRE_first_tail_x15_r0_body.s1059 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1058).run PRE_first_tail_x15_r0_body.S1058 = some (PRE_first_tail_x15_r0_body.s1059, PRE_first_tail_x15_r0_body.S1059)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA287 from PRE_first_tail_x15_r0_body.s1062 to PRE_first_tail_x15_r0_body.s1063 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1062).run PRE_first_tail_x15_r0_body.S1062 = some (PRE_first_tail_x15_r0_body.s1063, PRE_first_tail_x15_r0_body.S1063)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA288 from PRE_first_tail_x15_r0_body.s1067 to PRE_first_tail_x15_r0_body.s1068 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1067).run PRE_first_tail_x15_r0_body.S1067 = some (PRE_first_tail_x15_r0_body.s1068, PRE_first_tail_x15_r0_body.S1068)
end Host.Load.Run.Tpl
