import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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
boot_rfl PRE_first_tail_x15_r0_body.stepA94 from PRE_first_tail_x15_r0_body.s316 to PRE_first_tail_x15_r0_body.s317 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s316).run PRE_first_tail_x15_r0_body.S316 = some (PRE_first_tail_x15_r0_body.s317, PRE_first_tail_x15_r0_body.S317)
boot_rfl PRE_first_tail_x15_r0_body.patchB94 from PRE_first_tail_x15_r0_body.s317 to PRE_first_tail_x15_r0_body.s318 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s317).run PRE_first_tail_x15_r0_body.S317 = some (PRE_first_tail_x15_r0_body.s318, PRE_first_tail_x15_r0_body.S318)
boot_rfl PRE_first_tail_x15_r0_body.k318 from PRE_first_tail_x15_r0_body.s318 to PRE_first_tail_x15_r0_body.s319 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB94 ((nth? PRE_first_tail_x15_r0_body.ks 318).getD 0) PRE_first_tail_x15_r0_body.s318 PRE_first_tail_x15_r0_body.S318 = some (PRE_first_tail_x15_r0_body.s319, PRE_first_tail_x15_r0_body.S319)
boot_rfl PRE_first_tail_x15_r0_body.stepA95 from PRE_first_tail_x15_r0_body.s319 to PRE_first_tail_x15_r0_body.s320 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s319).run PRE_first_tail_x15_r0_body.S319 = some (PRE_first_tail_x15_r0_body.s320, PRE_first_tail_x15_r0_body.S320)
end Host.Load.Run.Tpl
