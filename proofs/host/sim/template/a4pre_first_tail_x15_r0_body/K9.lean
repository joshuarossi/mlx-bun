import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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
boot_rfl PRE_first_tail_x15_r0_body.patchB10 from PRE_first_tail_x15_r0_body.s36 to PRE_first_tail_x15_r0_body.s37 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s36).run PRE_first_tail_x15_r0_body.S36 = some (PRE_first_tail_x15_r0_body.s37, PRE_first_tail_x15_r0_body.S37)
boot_rfl PRE_first_tail_x15_r0_body.k37 from PRE_first_tail_x15_r0_body.s37 to PRE_first_tail_x15_r0_body.s38 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB10 ((nth? PRE_first_tail_x15_r0_body.ks 37).getD 0) PRE_first_tail_x15_r0_body.s37 PRE_first_tail_x15_r0_body.S37 = some (PRE_first_tail_x15_r0_body.s38, PRE_first_tail_x15_r0_body.S38)
boot_rfl PRE_first_tail_x15_r0_body.stepA11 from PRE_first_tail_x15_r0_body.s38 to PRE_first_tail_x15_r0_body.s39 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s38).run PRE_first_tail_x15_r0_body.S38 = some (PRE_first_tail_x15_r0_body.s39, PRE_first_tail_x15_r0_body.S39)
boot_rfl PRE_first_tail_x15_r0_body.patchB11 from PRE_first_tail_x15_r0_body.s39 to PRE_first_tail_x15_r0_body.s40 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s39).run PRE_first_tail_x15_r0_body.S39 = some (PRE_first_tail_x15_r0_body.s40, PRE_first_tail_x15_r0_body.S40)
end Host.Load.Run.Tpl
