import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.H39
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB332 from PRE_first_tail_x15_r0_body.s1228 to PRE_first_tail_x15_r0_body.s1229 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1228).run PRE_first_tail_x15_r0_body.S1228 = some (PRE_first_tail_x15_r0_body.s1229, PRE_first_tail_x15_r0_body.S1229)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA333 from PRE_first_tail_x15_r0_body.s1231 to PRE_first_tail_x15_r0_body.s1232 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1231).run PRE_first_tail_x15_r0_body.S1231 = some (PRE_first_tail_x15_r0_body.s1232, PRE_first_tail_x15_r0_body.S1232)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA334 from PRE_first_tail_x15_r0_body.s1235 to PRE_first_tail_x15_r0_body.s1236 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1235).run PRE_first_tail_x15_r0_body.S1235 = some (PRE_first_tail_x15_r0_body.s1236, PRE_first_tail_x15_r0_body.S1236)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA335 from PRE_first_tail_x15_r0_body.s1240 to PRE_first_tail_x15_r0_body.s1241 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1240).run PRE_first_tail_x15_r0_body.S1240 = some (PRE_first_tail_x15_r0_body.s1241, PRE_first_tail_x15_r0_body.S1241)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB335 from PRE_first_tail_x15_r0_body.s1241 to PRE_first_tail_x15_r0_body.s1242 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1241).run PRE_first_tail_x15_r0_body.S1241 = some (PRE_first_tail_x15_r0_body.s1242, PRE_first_tail_x15_r0_body.S1242)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA336 from PRE_first_tail_x15_r0_body.s1244 to PRE_first_tail_x15_r0_body.s1245 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1244).run PRE_first_tail_x15_r0_body.S1244 = some (PRE_first_tail_x15_r0_body.s1245, PRE_first_tail_x15_r0_body.S1245)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB336 from PRE_first_tail_x15_r0_body.s1245 to PRE_first_tail_x15_r0_body.s1246 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1245).run PRE_first_tail_x15_r0_body.S1245 = some (PRE_first_tail_x15_r0_body.s1246, PRE_first_tail_x15_r0_body.S1246)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA337 from PRE_first_tail_x15_r0_body.s1247 to PRE_first_tail_x15_r0_body.s1248 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1247).run PRE_first_tail_x15_r0_body.S1247 = some (PRE_first_tail_x15_r0_body.s1248, PRE_first_tail_x15_r0_body.S1248)
end Host.Load.Run.Tpl
