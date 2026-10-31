import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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
boot_rfl PRE_first_tail_x15_r0_body.stepA183 from PRE_first_tail_x15_r0_body.s676 to PRE_first_tail_x15_r0_body.s677 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s676).run PRE_first_tail_x15_r0_body.S676 = some (PRE_first_tail_x15_r0_body.s677, PRE_first_tail_x15_r0_body.S677)
boot_rfl PRE_first_tail_x15_r0_body.k679 from PRE_first_tail_x15_r0_body.s679 to PRE_first_tail_x15_r0_body.s680 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB183 ((nth? PRE_first_tail_x15_r0_body.ks 679).getD 0) PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.S679 = some (PRE_first_tail_x15_r0_body.s680, PRE_first_tail_x15_r0_body.S680)
end Host.Load.Run.Tpl
