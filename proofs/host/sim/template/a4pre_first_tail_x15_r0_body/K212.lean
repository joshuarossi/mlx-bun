import host.sim.template.a4pre_first_tail_x15_r0_body.H26
import host.sim.template.a4pre_first_tail_x15_r0_body.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.patchB251 from PRE_first_tail_x15_r0_body.s848 to PRE_first_tail_x15_r0_body.s849 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s848).run PRE_first_tail_x15_r0_body.S848 = some (PRE_first_tail_x15_r0_body.s849, PRE_first_tail_x15_r0_body.S849)
boot_rfl PRE_first_tail_x15_r0_body.k849 from PRE_first_tail_x15_r0_body.s849 to PRE_first_tail_x15_r0_body.s850 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB251 ((nth? PRE_first_tail_x15_r0_body.ks 849).getD 0) PRE_first_tail_x15_r0_body.s849 PRE_first_tail_x15_r0_body.S849 = some (PRE_first_tail_x15_r0_body.s850, PRE_first_tail_x15_r0_body.S850)
boot_rfl PRE_first_tail_x15_r0_body.stepA252 from PRE_first_tail_x15_r0_body.s850 to PRE_first_tail_x15_r0_body.s851 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s850).run PRE_first_tail_x15_r0_body.S850 = some (PRE_first_tail_x15_r0_body.s851, PRE_first_tail_x15_r0_body.S851)
boot_rfl PRE_first_tail_x15_r0_body.patchB252 from PRE_first_tail_x15_r0_body.s851 to PRE_first_tail_x15_r0_body.s852 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s851).run PRE_first_tail_x15_r0_body.S851 = some (PRE_first_tail_x15_r0_body.s852, PRE_first_tail_x15_r0_body.S852)
end Host.Load.Run.Tpl
