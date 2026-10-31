import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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
boot_rfl PRE_first_tail_x15_r0_body.k980 from PRE_first_tail_x15_r0_body.s980 to PRE_first_tail_x15_r0_body.s981 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB264 ((nth? PRE_first_tail_x15_r0_body.ks 980).getD 0) PRE_first_tail_x15_r0_body.s980 PRE_first_tail_x15_r0_body.S980 = some (PRE_first_tail_x15_r0_body.s981, PRE_first_tail_x15_r0_body.S981)
boot_rfl PRE_first_tail_x15_r0_body.stepA265 from PRE_first_tail_x15_r0_body.s981 to PRE_first_tail_x15_r0_body.s982 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s981).run PRE_first_tail_x15_r0_body.S981 = some (PRE_first_tail_x15_r0_body.s982, PRE_first_tail_x15_r0_body.S982)
boot_rfl PRE_first_tail_x15_r0_body.patchB265 from PRE_first_tail_x15_r0_body.s982 to PRE_first_tail_x15_r0_body.s983 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s982).run PRE_first_tail_x15_r0_body.S982 = some (PRE_first_tail_x15_r0_body.s983, PRE_first_tail_x15_r0_body.S983)
boot_rfl PRE_first_tail_x15_r0_body.k983 from PRE_first_tail_x15_r0_body.s983 to PRE_first_tail_x15_r0_body.s984 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB265 ((nth? PRE_first_tail_x15_r0_body.ks 983).getD 0) PRE_first_tail_x15_r0_body.s983 PRE_first_tail_x15_r0_body.S983 = some (PRE_first_tail_x15_r0_body.s984, PRE_first_tail_x15_r0_body.S984)
end Host.Load.Run.Tpl
