import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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
boot_rfl PRE_first_tail_x15_r0_body.patchB63 from PRE_first_tail_x15_r0_body.s212 to PRE_first_tail_x15_r0_body.s213 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s212).run PRE_first_tail_x15_r0_body.S212 = some (PRE_first_tail_x15_r0_body.s213, PRE_first_tail_x15_r0_body.S213)
boot_rfl PRE_first_tail_x15_r0_body.k213 from PRE_first_tail_x15_r0_body.s213 to PRE_first_tail_x15_r0_body.s214 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB63 ((nth? PRE_first_tail_x15_r0_body.ks 213).getD 0) PRE_first_tail_x15_r0_body.s213 PRE_first_tail_x15_r0_body.S213 = some (PRE_first_tail_x15_r0_body.s214, PRE_first_tail_x15_r0_body.S214)
boot_rfl PRE_first_tail_x15_r0_body.stepA64 from PRE_first_tail_x15_r0_body.s214 to PRE_first_tail_x15_r0_body.s215 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s214).run PRE_first_tail_x15_r0_body.S214 = some (PRE_first_tail_x15_r0_body.s215, PRE_first_tail_x15_r0_body.S215)
boot_rfl PRE_first_tail_x15_r0_body.patchB64 from PRE_first_tail_x15_r0_body.s215 to PRE_first_tail_x15_r0_body.s216 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s215).run PRE_first_tail_x15_r0_body.S215 = some (PRE_first_tail_x15_r0_body.s216, PRE_first_tail_x15_r0_body.S216)
end Host.Load.Run.Tpl
