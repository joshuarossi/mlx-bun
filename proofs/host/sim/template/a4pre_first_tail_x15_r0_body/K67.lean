import host.sim.template.a4pre_first_tail_x15_r0_body.H8
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
boot_rfl PRE_first_tail_x15_r0_body.stepA73 from PRE_first_tail_x15_r0_body.s268 to PRE_first_tail_x15_r0_body.s269 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s268).run PRE_first_tail_x15_r0_body.S268 = some (PRE_first_tail_x15_r0_body.s269, PRE_first_tail_x15_r0_body.S269)
boot_rfl PRE_first_tail_x15_r0_body.patchB73 from PRE_first_tail_x15_r0_body.s269 to PRE_first_tail_x15_r0_body.s270 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s269).run PRE_first_tail_x15_r0_body.S269 = some (PRE_first_tail_x15_r0_body.s270, PRE_first_tail_x15_r0_body.S270)
boot_rfl PRE_first_tail_x15_r0_body.k270 from PRE_first_tail_x15_r0_body.s270 to PRE_first_tail_x15_r0_body.s271 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB73 ((nth? PRE_first_tail_x15_r0_body.ks 270).getD 0) PRE_first_tail_x15_r0_body.s270 PRE_first_tail_x15_r0_body.S270 = some (PRE_first_tail_x15_r0_body.s271, PRE_first_tail_x15_r0_body.S271)
boot_rfl PRE_first_tail_x15_r0_body.stepA74 from PRE_first_tail_x15_r0_body.s271 to PRE_first_tail_x15_r0_body.s272 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s271).run PRE_first_tail_x15_r0_body.S271 = some (PRE_first_tail_x15_r0_body.s272, PRE_first_tail_x15_r0_body.S272)
end Host.Load.Run.Tpl
