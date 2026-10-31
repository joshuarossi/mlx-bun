import host.sim.template.a4pre_first_tail_x15_r0_body.H12
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
boot_rfl PRE_first_tail_x15_r0_body.stepA119 from PRE_first_tail_x15_r0_body.s400 to PRE_first_tail_x15_r0_body.s401 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s400).run PRE_first_tail_x15_r0_body.S400 = some (PRE_first_tail_x15_r0_body.s401, PRE_first_tail_x15_r0_body.S401)
boot_rfl PRE_first_tail_x15_r0_body.patchB119 from PRE_first_tail_x15_r0_body.s401 to PRE_first_tail_x15_r0_body.s402 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s401).run PRE_first_tail_x15_r0_body.S401 = some (PRE_first_tail_x15_r0_body.s402, PRE_first_tail_x15_r0_body.S402)
boot_rfl PRE_first_tail_x15_r0_body.k402 from PRE_first_tail_x15_r0_body.s402 to PRE_first_tail_x15_r0_body.s403 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB119 ((nth? PRE_first_tail_x15_r0_body.ks 402).getD 0) PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.S402 = some (PRE_first_tail_x15_r0_body.s403, PRE_first_tail_x15_r0_body.S403)
boot_rfl PRE_first_tail_x15_r0_body.stepA120 from PRE_first_tail_x15_r0_body.s403 to PRE_first_tail_x15_r0_body.s404 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s403).run PRE_first_tail_x15_r0_body.S403 = some (PRE_first_tail_x15_r0_body.s404, PRE_first_tail_x15_r0_body.S404)
end Host.Load.Run.Tpl
