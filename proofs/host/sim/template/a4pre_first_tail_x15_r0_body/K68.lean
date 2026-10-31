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
boot_rfl PRE_first_tail_x15_r0_body.patchB81 from PRE_first_tail_x15_r0_body.s272 to PRE_first_tail_x15_r0_body.s273 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s272).run PRE_first_tail_x15_r0_body.S272 = some (PRE_first_tail_x15_r0_body.s273, PRE_first_tail_x15_r0_body.S273)
boot_rfl PRE_first_tail_x15_r0_body.k273 from PRE_first_tail_x15_r0_body.s273 to PRE_first_tail_x15_r0_body.s274 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB81 ((nth? PRE_first_tail_x15_r0_body.ks 273).getD 0) PRE_first_tail_x15_r0_body.s273 PRE_first_tail_x15_r0_body.S273 = some (PRE_first_tail_x15_r0_body.s274, PRE_first_tail_x15_r0_body.S274)
boot_rfl PRE_first_tail_x15_r0_body.stepA82 from PRE_first_tail_x15_r0_body.s274 to PRE_first_tail_x15_r0_body.s275 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s274).run PRE_first_tail_x15_r0_body.S274 = some (PRE_first_tail_x15_r0_body.s275, PRE_first_tail_x15_r0_body.S275)
boot_rfl PRE_first_tail_x15_r0_body.patchB82 from PRE_first_tail_x15_r0_body.s275 to PRE_first_tail_x15_r0_body.s276 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s275).run PRE_first_tail_x15_r0_body.S275 = some (PRE_first_tail_x15_r0_body.s276, PRE_first_tail_x15_r0_body.S276)
end Host.Load.Run.Tpl
