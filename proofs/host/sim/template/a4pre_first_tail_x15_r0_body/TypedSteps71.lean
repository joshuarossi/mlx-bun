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
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB352 from PRE_first_tail_x15_r0_body.s1304 to PRE_first_tail_x15_r0_body.s1305 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1304).run PRE_first_tail_x15_r0_body.S1304 = some (PRE_first_tail_x15_r0_body.s1305, PRE_first_tail_x15_r0_body.S1305)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA353 from PRE_first_tail_x15_r0_body.s1306 to PRE_first_tail_x15_r0_body.s1307 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1306).run PRE_first_tail_x15_r0_body.S1306 = some (PRE_first_tail_x15_r0_body.s1307, PRE_first_tail_x15_r0_body.S1307)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB353 from PRE_first_tail_x15_r0_body.s1307 to PRE_first_tail_x15_r0_body.s1308 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1307).run PRE_first_tail_x15_r0_body.S1307 = some (PRE_first_tail_x15_r0_body.s1308, PRE_first_tail_x15_r0_body.S1308)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA354 from PRE_first_tail_x15_r0_body.s1309 to PRE_first_tail_x15_r0_body.s1310 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1309).run PRE_first_tail_x15_r0_body.S1309 = some (PRE_first_tail_x15_r0_body.s1310, PRE_first_tail_x15_r0_body.S1310)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA355 from PRE_first_tail_x15_r0_body.s1313 to PRE_first_tail_x15_r0_body.s1314 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1313).run PRE_first_tail_x15_r0_body.S1313 = some (PRE_first_tail_x15_r0_body.s1314, PRE_first_tail_x15_r0_body.S1314)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB355 from PRE_first_tail_x15_r0_body.s1314 to PRE_first_tail_x15_r0_body.s1315 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1314).run PRE_first_tail_x15_r0_body.S1314 = some (PRE_first_tail_x15_r0_body.s1315, PRE_first_tail_x15_r0_body.S1315)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA356 from PRE_first_tail_x15_r0_body.s1317 to PRE_first_tail_x15_r0_body.s1318 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1317).run PRE_first_tail_x15_r0_body.S1317 = some (PRE_first_tail_x15_r0_body.s1318, PRE_first_tail_x15_r0_body.S1318)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA357 from PRE_first_tail_x15_r0_body.s1321 to PRE_first_tail_x15_r0_body.s1322 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1321).run PRE_first_tail_x15_r0_body.S1321 = some (PRE_first_tail_x15_r0_body.s1322, PRE_first_tail_x15_r0_body.S1322)
end Host.Load.Run.Tpl
