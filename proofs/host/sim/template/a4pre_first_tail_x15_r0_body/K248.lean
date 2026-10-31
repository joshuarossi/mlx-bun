import host.sim.template.a4pre_first_tail_x15_r0_body.H31
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
boot_rfl PRE_first_tail_x15_r0_body.stepA294 from PRE_first_tail_x15_r0_body.s992 to PRE_first_tail_x15_r0_body.s993 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s992).run PRE_first_tail_x15_r0_body.S992 = some (PRE_first_tail_x15_r0_body.s993, PRE_first_tail_x15_r0_body.S993)
boot_rfl PRE_first_tail_x15_r0_body.k995 from PRE_first_tail_x15_r0_body.s995 to PRE_first_tail_x15_r0_body.s996 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB294 ((nth? PRE_first_tail_x15_r0_body.ks 995).getD 0) PRE_first_tail_x15_r0_body.s995 PRE_first_tail_x15_r0_body.S995 = some (PRE_first_tail_x15_r0_body.s996, PRE_first_tail_x15_r0_body.S996)
end Host.Load.Run.Tpl
