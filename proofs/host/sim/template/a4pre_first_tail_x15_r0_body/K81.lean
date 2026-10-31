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
boot_rfl PRE_first_tail_x15_r0_body.k324 from PRE_first_tail_x15_r0_body.s324 to PRE_first_tail_x15_r0_body.s325 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB96 ((nth? PRE_first_tail_x15_r0_body.ks 324).getD 0) PRE_first_tail_x15_r0_body.s324 PRE_first_tail_x15_r0_body.S324 = some (PRE_first_tail_x15_r0_body.s325, PRE_first_tail_x15_r0_body.S325)
boot_rfl PRE_first_tail_x15_r0_body.stepA97 from PRE_first_tail_x15_r0_body.s325 to PRE_first_tail_x15_r0_body.s326 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s325).run PRE_first_tail_x15_r0_body.S325 = some (PRE_first_tail_x15_r0_body.s326, PRE_first_tail_x15_r0_body.S326)
boot_rfl PRE_first_tail_x15_r0_body.patchB97 from PRE_first_tail_x15_r0_body.s326 to PRE_first_tail_x15_r0_body.s327 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s326).run PRE_first_tail_x15_r0_body.S326 = some (PRE_first_tail_x15_r0_body.s327, PRE_first_tail_x15_r0_body.S327)
boot_rfl PRE_first_tail_x15_r0_body.k327 from PRE_first_tail_x15_r0_body.s327 to PRE_first_tail_x15_r0_body.s328 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB97 ((nth? PRE_first_tail_x15_r0_body.ks 327).getD 0) PRE_first_tail_x15_r0_body.s327 PRE_first_tail_x15_r0_body.S327 = some (PRE_first_tail_x15_r0_body.s328, PRE_first_tail_x15_r0_body.S328)
end Host.Load.Run.Tpl
