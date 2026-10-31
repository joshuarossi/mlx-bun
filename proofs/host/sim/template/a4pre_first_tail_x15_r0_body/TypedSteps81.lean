import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.a4pre_first_tail_x15_r0_body.H47
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA402 from PRE_first_tail_x15_r0_body.s1489 to PRE_first_tail_x15_r0_body.s1490 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1489).run PRE_first_tail_x15_r0_body.S1489 = some (PRE_first_tail_x15_r0_body.s1490, PRE_first_tail_x15_r0_body.S1490)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA403 from PRE_first_tail_x15_r0_body.s1493 to PRE_first_tail_x15_r0_body.s1494 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1493).run PRE_first_tail_x15_r0_body.S1493 = some (PRE_first_tail_x15_r0_body.s1494, PRE_first_tail_x15_r0_body.S1494)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA404 from PRE_first_tail_x15_r0_body.s1498 to PRE_first_tail_x15_r0_body.s1499 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1498).run PRE_first_tail_x15_r0_body.S1498 = some (PRE_first_tail_x15_r0_body.s1499, PRE_first_tail_x15_r0_body.S1499)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB404 from PRE_first_tail_x15_r0_body.s1499 to PRE_first_tail_x15_r0_body.s1500 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1499).run PRE_first_tail_x15_r0_body.S1499 = some (PRE_first_tail_x15_r0_body.s1500, PRE_first_tail_x15_r0_body.S1500)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA405 from PRE_first_tail_x15_r0_body.s1501 to PRE_first_tail_x15_r0_body.s1502 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1501).run PRE_first_tail_x15_r0_body.S1501 = some (PRE_first_tail_x15_r0_body.s1502, PRE_first_tail_x15_r0_body.S1502)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB405 from PRE_first_tail_x15_r0_body.s1502 to PRE_first_tail_x15_r0_body.s1503 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1502).run PRE_first_tail_x15_r0_body.S1502 = some (PRE_first_tail_x15_r0_body.s1503, PRE_first_tail_x15_r0_body.S1503)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA406 from PRE_first_tail_x15_r0_body.s1504 to PRE_first_tail_x15_r0_body.s1505 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1504).run PRE_first_tail_x15_r0_body.S1504 = some (PRE_first_tail_x15_r0_body.s1505, PRE_first_tail_x15_r0_body.S1505)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB406 from PRE_first_tail_x15_r0_body.s1505 to PRE_first_tail_x15_r0_body.s1506 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1505).run PRE_first_tail_x15_r0_body.S1505 = some (PRE_first_tail_x15_r0_body.s1506, PRE_first_tail_x15_r0_body.S1506)
end Host.Load.Run.Tpl
