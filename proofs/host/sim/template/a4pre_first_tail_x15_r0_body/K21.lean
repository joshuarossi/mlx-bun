import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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
boot_rfl PRE_first_tail_x15_r0_body.k84 from PRE_first_tail_x15_r0_body.s84 to PRE_first_tail_x15_r0_body.s85 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB25 ((nth? PRE_first_tail_x15_r0_body.ks 84).getD 0) PRE_first_tail_x15_r0_body.s84 PRE_first_tail_x15_r0_body.S84 = some (PRE_first_tail_x15_r0_body.s85, PRE_first_tail_x15_r0_body.S85)
boot_rfl PRE_first_tail_x15_r0_body.stepA26 from PRE_first_tail_x15_r0_body.s85 to PRE_first_tail_x15_r0_body.s86 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s85).run PRE_first_tail_x15_r0_body.S85 = some (PRE_first_tail_x15_r0_body.s86, PRE_first_tail_x15_r0_body.S86)
boot_rfl PRE_first_tail_x15_r0_body.patchB26 from PRE_first_tail_x15_r0_body.s86 to PRE_first_tail_x15_r0_body.s87 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s86).run PRE_first_tail_x15_r0_body.S86 = some (PRE_first_tail_x15_r0_body.s87, PRE_first_tail_x15_r0_body.S87)
boot_rfl PRE_first_tail_x15_r0_body.k87 from PRE_first_tail_x15_r0_body.s87 to PRE_first_tail_x15_r0_body.s88 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB26 ((nth? PRE_first_tail_x15_r0_body.ks 87).getD 0) PRE_first_tail_x15_r0_body.s87 PRE_first_tail_x15_r0_body.S87 = some (PRE_first_tail_x15_r0_body.s88, PRE_first_tail_x15_r0_body.S88)
end Host.Load.Run.Tpl
