import host.sim.template.a4pre_first_tail_x15_r0_body.H28
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
boot_rfl PRE_first_tail_x15_r0_body.k900 from PRE_first_tail_x15_r0_body.s900 to PRE_first_tail_x15_r0_body.s901 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB266 ((nth? PRE_first_tail_x15_r0_body.ks 900).getD 0) PRE_first_tail_x15_r0_body.s900 PRE_first_tail_x15_r0_body.S900 = some (PRE_first_tail_x15_r0_body.s901, PRE_first_tail_x15_r0_body.S901)
boot_rfl PRE_first_tail_x15_r0_body.stepA267 from PRE_first_tail_x15_r0_body.s901 to PRE_first_tail_x15_r0_body.s902 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s901).run PRE_first_tail_x15_r0_body.S901 = some (PRE_first_tail_x15_r0_body.s902, PRE_first_tail_x15_r0_body.S902)
boot_rfl PRE_first_tail_x15_r0_body.patchB267 from PRE_first_tail_x15_r0_body.s902 to PRE_first_tail_x15_r0_body.s903 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s902).run PRE_first_tail_x15_r0_body.S902 = some (PRE_first_tail_x15_r0_body.s903, PRE_first_tail_x15_r0_body.S903)
boot_rfl PRE_first_tail_x15_r0_body.k903 from PRE_first_tail_x15_r0_body.s903 to PRE_first_tail_x15_r0_body.s904 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB267 ((nth? PRE_first_tail_x15_r0_body.ks 903).getD 0) PRE_first_tail_x15_r0_body.s903 PRE_first_tail_x15_r0_body.S903 = some (PRE_first_tail_x15_r0_body.s904, PRE_first_tail_x15_r0_body.S904)
end Host.Load.Run.Tpl
