import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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
boot_rfl PRE_first_tail_x15_r0_body.k758 from PRE_first_tail_x15_r0_body.s758 to PRE_first_tail_x15_r0_body.s759 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB224 ((nth? PRE_first_tail_x15_r0_body.ks 758).getD 0) PRE_first_tail_x15_r0_body.s758 PRE_first_tail_x15_r0_body.S758 = some (PRE_first_tail_x15_r0_body.s759, PRE_first_tail_x15_r0_body.S759)
boot_rfl PRE_first_tail_x15_r0_body.stepA225 from PRE_first_tail_x15_r0_body.s759 to PRE_first_tail_x15_r0_body.s760 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s759).run PRE_first_tail_x15_r0_body.S759 = some (PRE_first_tail_x15_r0_body.s760, PRE_first_tail_x15_r0_body.S760)
end Host.Load.Run.Tpl
