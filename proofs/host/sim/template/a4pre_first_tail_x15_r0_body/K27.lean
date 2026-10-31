import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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
boot_rfl PRE_first_tail_x15_r0_body.k108 from PRE_first_tail_x15_r0_body.s108 to PRE_first_tail_x15_r0_body.s109 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB32 ((nth? PRE_first_tail_x15_r0_body.ks 108).getD 0) PRE_first_tail_x15_r0_body.s108 PRE_first_tail_x15_r0_body.S108 = some (PRE_first_tail_x15_r0_body.s109, PRE_first_tail_x15_r0_body.S109)
boot_rfl PRE_first_tail_x15_r0_body.stepA33 from PRE_first_tail_x15_r0_body.s109 to PRE_first_tail_x15_r0_body.s110 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s109).run PRE_first_tail_x15_r0_body.S109 = some (PRE_first_tail_x15_r0_body.s110, PRE_first_tail_x15_r0_body.S110)
boot_rfl PRE_first_tail_x15_r0_body.patchB33 from PRE_first_tail_x15_r0_body.s110 to PRE_first_tail_x15_r0_body.s111 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s110).run PRE_first_tail_x15_r0_body.S110 = some (PRE_first_tail_x15_r0_body.s111, PRE_first_tail_x15_r0_body.S111)
boot_rfl PRE_first_tail_x15_r0_body.k111 from PRE_first_tail_x15_r0_body.s111 to PRE_first_tail_x15_r0_body.s112 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB33 ((nth? PRE_first_tail_x15_r0_body.ks 111).getD 0) PRE_first_tail_x15_r0_body.s111 PRE_first_tail_x15_r0_body.S111 = some (PRE_first_tail_x15_r0_body.s112, PRE_first_tail_x15_r0_body.S112)
end Host.Load.Run.Tpl
