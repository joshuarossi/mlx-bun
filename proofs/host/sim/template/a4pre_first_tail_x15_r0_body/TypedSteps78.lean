import host.sim.template.a4pre_first_tail_x15_r0_body.H40
import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA387 from PRE_first_tail_x15_r0_body.s1307 to PRE_first_tail_x15_r0_body.s1308 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1307).run PRE_first_tail_x15_r0_body.S1307 = some (PRE_first_tail_x15_r0_body.s1308, PRE_first_tail_x15_r0_body.S1308)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA388 from PRE_first_tail_x15_r0_body.s1311 to PRE_first_tail_x15_r0_body.s1312 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1311).run PRE_first_tail_x15_r0_body.S1311 = some (PRE_first_tail_x15_r0_body.s1312, PRE_first_tail_x15_r0_body.S1312)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA389 from PRE_first_tail_x15_r0_body.s1315 to PRE_first_tail_x15_r0_body.s1316 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1315).run PRE_first_tail_x15_r0_body.S1315 = some (PRE_first_tail_x15_r0_body.s1316, PRE_first_tail_x15_r0_body.S1316)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB389 from PRE_first_tail_x15_r0_body.s1316 to PRE_first_tail_x15_r0_body.s1317 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1316).run PRE_first_tail_x15_r0_body.S1316 = some (PRE_first_tail_x15_r0_body.s1317, PRE_first_tail_x15_r0_body.S1317)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA390 from PRE_first_tail_x15_r0_body.s1318 to PRE_first_tail_x15_r0_body.s1319 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1318).run PRE_first_tail_x15_r0_body.S1318 = some (PRE_first_tail_x15_r0_body.s1319, PRE_first_tail_x15_r0_body.S1319)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB390 from PRE_first_tail_x15_r0_body.s1319 to PRE_first_tail_x15_r0_body.s1320 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1319).run PRE_first_tail_x15_r0_body.S1319 = some (PRE_first_tail_x15_r0_body.s1320, PRE_first_tail_x15_r0_body.S1320)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA391 from PRE_first_tail_x15_r0_body.s1321 to PRE_first_tail_x15_r0_body.s1322 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1321).run PRE_first_tail_x15_r0_body.S1321 = some (PRE_first_tail_x15_r0_body.s1322, PRE_first_tail_x15_r0_body.S1322)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB391 from PRE_first_tail_x15_r0_body.s1322 to PRE_first_tail_x15_r0_body.s1323 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1322).run PRE_first_tail_x15_r0_body.S1322 = some (PRE_first_tail_x15_r0_body.s1323, PRE_first_tail_x15_r0_body.S1323)
end Host.Load.Run.Tpl
