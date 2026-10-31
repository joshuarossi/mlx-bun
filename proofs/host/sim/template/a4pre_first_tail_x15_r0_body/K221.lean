import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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
boot_rfl PRE_first_tail_x15_r0_body.stepA262 from PRE_first_tail_x15_r0_body.s884 to PRE_first_tail_x15_r0_body.s885 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s884).run PRE_first_tail_x15_r0_body.S884 = some (PRE_first_tail_x15_r0_body.s885, PRE_first_tail_x15_r0_body.S885)
boot_rfl PRE_first_tail_x15_r0_body.patchB262 from PRE_first_tail_x15_r0_body.s885 to PRE_first_tail_x15_r0_body.s886 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s885).run PRE_first_tail_x15_r0_body.S885 = some (PRE_first_tail_x15_r0_body.s886, PRE_first_tail_x15_r0_body.S886)
boot_rfl PRE_first_tail_x15_r0_body.k886 from PRE_first_tail_x15_r0_body.s886 to PRE_first_tail_x15_r0_body.s887 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB262 ((nth? PRE_first_tail_x15_r0_body.ks 886).getD 0) PRE_first_tail_x15_r0_body.s886 PRE_first_tail_x15_r0_body.S886 = some (PRE_first_tail_x15_r0_body.s887, PRE_first_tail_x15_r0_body.S887)
boot_rfl PRE_first_tail_x15_r0_body.stepA263 from PRE_first_tail_x15_r0_body.s887 to PRE_first_tail_x15_r0_body.s888 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s887).run PRE_first_tail_x15_r0_body.S887 = some (PRE_first_tail_x15_r0_body.s888, PRE_first_tail_x15_r0_body.S888)
end Host.Load.Run.Tpl
