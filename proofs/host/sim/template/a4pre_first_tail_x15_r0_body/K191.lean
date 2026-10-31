import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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
boot_rfl PRE_first_tail_x15_r0_body.patchB226 from PRE_first_tail_x15_r0_body.s764 to PRE_first_tail_x15_r0_body.s765 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s764).run PRE_first_tail_x15_r0_body.S764 = some (PRE_first_tail_x15_r0_body.s765, PRE_first_tail_x15_r0_body.S765)
boot_rfl PRE_first_tail_x15_r0_body.k765 from PRE_first_tail_x15_r0_body.s765 to PRE_first_tail_x15_r0_body.s766 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB226 ((nth? PRE_first_tail_x15_r0_body.ks 765).getD 0) PRE_first_tail_x15_r0_body.s765 PRE_first_tail_x15_r0_body.S765 = some (PRE_first_tail_x15_r0_body.s766, PRE_first_tail_x15_r0_body.S766)
boot_rfl PRE_first_tail_x15_r0_body.stepA227 from PRE_first_tail_x15_r0_body.s766 to PRE_first_tail_x15_r0_body.s767 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s766).run PRE_first_tail_x15_r0_body.S766 = some (PRE_first_tail_x15_r0_body.s767, PRE_first_tail_x15_r0_body.S767)
boot_rfl PRE_first_tail_x15_r0_body.patchB227 from PRE_first_tail_x15_r0_body.s767 to PRE_first_tail_x15_r0_body.s768 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s767).run PRE_first_tail_x15_r0_body.S767 = some (PRE_first_tail_x15_r0_body.s768, PRE_first_tail_x15_r0_body.S768)
end Host.Load.Run.Tpl
