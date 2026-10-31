import host.sim.template.a4pre_first_tail_x15_r0_body.H15
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
boot_rfl PRE_first_tail_x15_r0_body.k501 from PRE_first_tail_x15_r0_body.s501 to PRE_first_tail_x15_r0_body.s502 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB148 ((nth? PRE_first_tail_x15_r0_body.ks 501).getD 0) PRE_first_tail_x15_r0_body.s501 PRE_first_tail_x15_r0_body.S501 = some (PRE_first_tail_x15_r0_body.s502, PRE_first_tail_x15_r0_body.S502)
boot_rfl PRE_first_tail_x15_r0_body.stepA149 from PRE_first_tail_x15_r0_body.s502 to PRE_first_tail_x15_r0_body.s503 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s502).run PRE_first_tail_x15_r0_body.S502 = some (PRE_first_tail_x15_r0_body.s503, PRE_first_tail_x15_r0_body.S503)
boot_rfl PRE_first_tail_x15_r0_body.patchB149 from PRE_first_tail_x15_r0_body.s503 to PRE_first_tail_x15_r0_body.s504 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s503).run PRE_first_tail_x15_r0_body.S503 = some (PRE_first_tail_x15_r0_body.s504, PRE_first_tail_x15_r0_body.S504)
end Host.Load.Run.Tpl
