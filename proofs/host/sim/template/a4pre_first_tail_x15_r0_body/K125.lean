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
boot_rfl PRE_first_tail_x15_r0_body.k500 from PRE_first_tail_x15_r0_body.s500 to PRE_first_tail_x15_r0_body.s501 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB135 ((nth? PRE_first_tail_x15_r0_body.ks 500).getD 0) PRE_first_tail_x15_r0_body.s500 PRE_first_tail_x15_r0_body.S500 = some (PRE_first_tail_x15_r0_body.s501, PRE_first_tail_x15_r0_body.S501)
boot_rfl PRE_first_tail_x15_r0_body.stepA136 from PRE_first_tail_x15_r0_body.s501 to PRE_first_tail_x15_r0_body.s502 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s501).run PRE_first_tail_x15_r0_body.S501 = some (PRE_first_tail_x15_r0_body.s502, PRE_first_tail_x15_r0_body.S502)
boot_rfl PRE_first_tail_x15_r0_body.patchB136 from PRE_first_tail_x15_r0_body.s502 to PRE_first_tail_x15_r0_body.s503 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s502).run PRE_first_tail_x15_r0_body.S502 = some (PRE_first_tail_x15_r0_body.s503, PRE_first_tail_x15_r0_body.S503)
boot_rfl PRE_first_tail_x15_r0_body.k503 from PRE_first_tail_x15_r0_body.s503 to PRE_first_tail_x15_r0_body.s504 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB136 ((nth? PRE_first_tail_x15_r0_body.ks 503).getD 0) PRE_first_tail_x15_r0_body.s503 PRE_first_tail_x15_r0_body.S503 = some (PRE_first_tail_x15_r0_body.s504, PRE_first_tail_x15_r0_body.S504)
end Host.Load.Run.Tpl
