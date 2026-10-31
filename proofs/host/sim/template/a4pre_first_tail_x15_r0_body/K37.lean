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
boot_rfl PRE_first_tail_x15_r0_body.patchB40 from PRE_first_tail_x15_r0_body.s148 to PRE_first_tail_x15_r0_body.s149 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s148).run PRE_first_tail_x15_r0_body.S148 = some (PRE_first_tail_x15_r0_body.s149, PRE_first_tail_x15_r0_body.S149)
boot_rfl PRE_first_tail_x15_r0_body.k149 from PRE_first_tail_x15_r0_body.s149 to PRE_first_tail_x15_r0_body.s150 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB40 ((nth? PRE_first_tail_x15_r0_body.ks 149).getD 0) PRE_first_tail_x15_r0_body.s149 PRE_first_tail_x15_r0_body.S149 = some (PRE_first_tail_x15_r0_body.s150, PRE_first_tail_x15_r0_body.S150)
boot_rfl PRE_first_tail_x15_r0_body.stepA41 from PRE_first_tail_x15_r0_body.s150 to PRE_first_tail_x15_r0_body.s151 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s150).run PRE_first_tail_x15_r0_body.S150 = some (PRE_first_tail_x15_r0_body.s151, PRE_first_tail_x15_r0_body.S151)
boot_rfl PRE_first_tail_x15_r0_body.patchB41 from PRE_first_tail_x15_r0_body.s151 to PRE_first_tail_x15_r0_body.s152 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s151).run PRE_first_tail_x15_r0_body.S151 = some (PRE_first_tail_x15_r0_body.s152, PRE_first_tail_x15_r0_body.S152)
end Host.Load.Run.Tpl
