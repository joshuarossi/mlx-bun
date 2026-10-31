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
boot_rfl PRE_first_tail_x15_r0_body.patchB79 from PRE_first_tail_x15_r0_body.s292 to PRE_first_tail_x15_r0_body.s293 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s292).run PRE_first_tail_x15_r0_body.S292 = some (PRE_first_tail_x15_r0_body.s293, PRE_first_tail_x15_r0_body.S293)
boot_rfl PRE_first_tail_x15_r0_body.k293 from PRE_first_tail_x15_r0_body.s293 to PRE_first_tail_x15_r0_body.s294 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB79 ((nth? PRE_first_tail_x15_r0_body.ks 293).getD 0) PRE_first_tail_x15_r0_body.s293 PRE_first_tail_x15_r0_body.S293 = some (PRE_first_tail_x15_r0_body.s294, PRE_first_tail_x15_r0_body.S294)
boot_rfl PRE_first_tail_x15_r0_body.stepA80 from PRE_first_tail_x15_r0_body.s294 to PRE_first_tail_x15_r0_body.s295 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s294).run PRE_first_tail_x15_r0_body.S294 = some (PRE_first_tail_x15_r0_body.s295, PRE_first_tail_x15_r0_body.S295)
boot_rfl PRE_first_tail_x15_r0_body.patchB80 from PRE_first_tail_x15_r0_body.s295 to PRE_first_tail_x15_r0_body.s296 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s295).run PRE_first_tail_x15_r0_body.S295 = some (PRE_first_tail_x15_r0_body.s296, PRE_first_tail_x15_r0_body.S296)
end Host.Load.Run.Tpl
