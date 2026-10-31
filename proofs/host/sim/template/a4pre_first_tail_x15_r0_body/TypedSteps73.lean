import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA362 from PRE_first_tail_x15_r0_body.s1222 to PRE_first_tail_x15_r0_body.s1223 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1222).run PRE_first_tail_x15_r0_body.S1222 = some (PRE_first_tail_x15_r0_body.s1223, PRE_first_tail_x15_r0_body.S1223)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA363 from PRE_first_tail_x15_r0_body.s1226 to PRE_first_tail_x15_r0_body.s1227 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1226).run PRE_first_tail_x15_r0_body.S1226 = some (PRE_first_tail_x15_r0_body.s1227, PRE_first_tail_x15_r0_body.S1227)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB363 from PRE_first_tail_x15_r0_body.s1227 to PRE_first_tail_x15_r0_body.s1228 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1227).run PRE_first_tail_x15_r0_body.S1227 = some (PRE_first_tail_x15_r0_body.s1228, PRE_first_tail_x15_r0_body.S1228)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA364 from PRE_first_tail_x15_r0_body.s1229 to PRE_first_tail_x15_r0_body.s1230 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1229).run PRE_first_tail_x15_r0_body.S1229 = some (PRE_first_tail_x15_r0_body.s1230, PRE_first_tail_x15_r0_body.S1230)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA365 from PRE_first_tail_x15_r0_body.s1233 to PRE_first_tail_x15_r0_body.s1234 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1233).run PRE_first_tail_x15_r0_body.S1233 = some (PRE_first_tail_x15_r0_body.s1234, PRE_first_tail_x15_r0_body.S1234)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA366 from PRE_first_tail_x15_r0_body.s1237 to PRE_first_tail_x15_r0_body.s1238 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1237).run PRE_first_tail_x15_r0_body.S1237 = some (PRE_first_tail_x15_r0_body.s1238, PRE_first_tail_x15_r0_body.S1238)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB366 from PRE_first_tail_x15_r0_body.s1238 to PRE_first_tail_x15_r0_body.s1239 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1238).run PRE_first_tail_x15_r0_body.S1238 = some (PRE_first_tail_x15_r0_body.s1239, PRE_first_tail_x15_r0_body.S1239)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA367 from PRE_first_tail_x15_r0_body.s1240 to PRE_first_tail_x15_r0_body.s1241 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1240).run PRE_first_tail_x15_r0_body.S1240 = some (PRE_first_tail_x15_r0_body.s1241, PRE_first_tail_x15_r0_body.S1241)
end Host.Load.Run.Tpl
