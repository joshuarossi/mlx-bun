import host.sim.template.a4pre_first_tail_x15_r0_body.H0
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
boot_rfl PRE_first_tail_x15_r0_body.stepA3 from PRE_first_tail_x15_r0_body.s8 to PRE_first_tail_x15_r0_body.s9 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s8).run PRE_first_tail_x15_r0_body.S8 = some (PRE_first_tail_x15_r0_body.s9, PRE_first_tail_x15_r0_body.S9)
boot_rfl PRE_first_tail_x15_r0_body.patchB3 from PRE_first_tail_x15_r0_body.s9 to PRE_first_tail_x15_r0_body.s10 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s9).run PRE_first_tail_x15_r0_body.S9 = some (PRE_first_tail_x15_r0_body.s10, PRE_first_tail_x15_r0_body.S10)
boot_rfl PRE_first_tail_x15_r0_body.k10 from PRE_first_tail_x15_r0_body.s10 to PRE_first_tail_x15_r0_body.s11 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB3 ((nth? PRE_first_tail_x15_r0_body.ks 10).getD 0) PRE_first_tail_x15_r0_body.s10 PRE_first_tail_x15_r0_body.S10 = some (PRE_first_tail_x15_r0_body.s11, PRE_first_tail_x15_r0_body.S11)
boot_rfl PRE_first_tail_x15_r0_body.stepA4 from PRE_first_tail_x15_r0_body.s11 to PRE_first_tail_x15_r0_body.s12 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s11).run PRE_first_tail_x15_r0_body.S11 = some (PRE_first_tail_x15_r0_body.s12, PRE_first_tail_x15_r0_body.S12)
end Host.Load.Run.Tpl
