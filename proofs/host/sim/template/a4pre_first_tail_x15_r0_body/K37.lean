import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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
boot_rfl PRE_first_tail_x15_r0_body.k148 from PRE_first_tail_x15_r0_body.s148 to PRE_first_tail_x15_r0_body.s149 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB44 ((nth? PRE_first_tail_x15_r0_body.ks 148).getD 0) PRE_first_tail_x15_r0_body.s148 PRE_first_tail_x15_r0_body.S148 = some (PRE_first_tail_x15_r0_body.s149, PRE_first_tail_x15_r0_body.S149)
boot_rfl PRE_first_tail_x15_r0_body.stepA45 from PRE_first_tail_x15_r0_body.s149 to PRE_first_tail_x15_r0_body.s150 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s149).run PRE_first_tail_x15_r0_body.S149 = some (PRE_first_tail_x15_r0_body.s150, PRE_first_tail_x15_r0_body.S150)
boot_rfl PRE_first_tail_x15_r0_body.patchB45 from PRE_first_tail_x15_r0_body.s150 to PRE_first_tail_x15_r0_body.s151 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s150).run PRE_first_tail_x15_r0_body.S150 = some (PRE_first_tail_x15_r0_body.s151, PRE_first_tail_x15_r0_body.S151)
boot_rfl PRE_first_tail_x15_r0_body.k151 from PRE_first_tail_x15_r0_body.s151 to PRE_first_tail_x15_r0_body.s152 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB45 ((nth? PRE_first_tail_x15_r0_body.ks 151).getD 0) PRE_first_tail_x15_r0_body.s151 PRE_first_tail_x15_r0_body.S151 = some (PRE_first_tail_x15_r0_body.s152, PRE_first_tail_x15_r0_body.S152)
end Host.Load.Run.Tpl
