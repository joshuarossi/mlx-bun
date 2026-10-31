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
boot_rfl PRE_first_tail_x15_r0_body.k404 from PRE_first_tail_x15_r0_body.s404 to PRE_first_tail_x15_r0_body.s405 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB109 ((nth? PRE_first_tail_x15_r0_body.ks 404).getD 0) PRE_first_tail_x15_r0_body.s404 PRE_first_tail_x15_r0_body.S404 = some (PRE_first_tail_x15_r0_body.s405, PRE_first_tail_x15_r0_body.S405)
boot_rfl PRE_first_tail_x15_r0_body.k405 from PRE_first_tail_x15_r0_body.s405 to PRE_first_tail_x15_r0_body.s406 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB109 ((nth? PRE_first_tail_x15_r0_body.ks 405).getD 0) PRE_first_tail_x15_r0_body.s405 PRE_first_tail_x15_r0_body.S405 = some (PRE_first_tail_x15_r0_body.s406, PRE_first_tail_x15_r0_body.S406)
boot_rfl PRE_first_tail_x15_r0_body.stepA110 from PRE_first_tail_x15_r0_body.s406 to PRE_first_tail_x15_r0_body.s407 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s406).run PRE_first_tail_x15_r0_body.S406 = some (PRE_first_tail_x15_r0_body.s407, PRE_first_tail_x15_r0_body.S407)
boot_rfl PRE_first_tail_x15_r0_body.patchB110 from PRE_first_tail_x15_r0_body.s407 to PRE_first_tail_x15_r0_body.s408 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s407).run PRE_first_tail_x15_r0_body.S407 = some (PRE_first_tail_x15_r0_body.s408, PRE_first_tail_x15_r0_body.S408)
end Host.Load.Run.Tpl
