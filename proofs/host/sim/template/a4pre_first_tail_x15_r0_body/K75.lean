import host.sim.template.a4pre_first_tail_x15_r0_body.H9
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
boot_rfl PRE_first_tail_x15_r0_body.stepA82 from PRE_first_tail_x15_r0_body.s300 to PRE_first_tail_x15_r0_body.s301 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s300).run PRE_first_tail_x15_r0_body.S300 = some (PRE_first_tail_x15_r0_body.s301, PRE_first_tail_x15_r0_body.S301)
boot_rfl PRE_first_tail_x15_r0_body.patchB82 from PRE_first_tail_x15_r0_body.s301 to PRE_first_tail_x15_r0_body.s302 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s301).run PRE_first_tail_x15_r0_body.S301 = some (PRE_first_tail_x15_r0_body.s302, PRE_first_tail_x15_r0_body.S302)
boot_rfl PRE_first_tail_x15_r0_body.k302 from PRE_first_tail_x15_r0_body.s302 to PRE_first_tail_x15_r0_body.s303 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB82 ((nth? PRE_first_tail_x15_r0_body.ks 302).getD 0) PRE_first_tail_x15_r0_body.s302 PRE_first_tail_x15_r0_body.S302 = some (PRE_first_tail_x15_r0_body.s303, PRE_first_tail_x15_r0_body.S303)
boot_rfl PRE_first_tail_x15_r0_body.stepA83 from PRE_first_tail_x15_r0_body.s303 to PRE_first_tail_x15_r0_body.s304 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s303).run PRE_first_tail_x15_r0_body.S303 = some (PRE_first_tail_x15_r0_body.s304, PRE_first_tail_x15_r0_body.S304)
end Host.Load.Run.Tpl
