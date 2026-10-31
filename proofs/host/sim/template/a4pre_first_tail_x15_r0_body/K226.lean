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
boot_rfl PRE_first_tail_x15_r0_body.stepA268 from PRE_first_tail_x15_r0_body.s904 to PRE_first_tail_x15_r0_body.s905 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s904).run PRE_first_tail_x15_r0_body.S904 = some (PRE_first_tail_x15_r0_body.s905, PRE_first_tail_x15_r0_body.S905)
boot_rfl PRE_first_tail_x15_r0_body.patchB268 from PRE_first_tail_x15_r0_body.s905 to PRE_first_tail_x15_r0_body.s906 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s905).run PRE_first_tail_x15_r0_body.S905 = some (PRE_first_tail_x15_r0_body.s906, PRE_first_tail_x15_r0_body.S906)
boot_rfl PRE_first_tail_x15_r0_body.k906 from PRE_first_tail_x15_r0_body.s906 to PRE_first_tail_x15_r0_body.s907 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB268 ((nth? PRE_first_tail_x15_r0_body.ks 906).getD 0) PRE_first_tail_x15_r0_body.s906 PRE_first_tail_x15_r0_body.S906 = some (PRE_first_tail_x15_r0_body.s907, PRE_first_tail_x15_r0_body.S907)
boot_rfl PRE_first_tail_x15_r0_body.stepA269 from PRE_first_tail_x15_r0_body.s907 to PRE_first_tail_x15_r0_body.s908 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s907).run PRE_first_tail_x15_r0_body.S907 = some (PRE_first_tail_x15_r0_body.s908, PRE_first_tail_x15_r0_body.S908)
end Host.Load.Run.Tpl
