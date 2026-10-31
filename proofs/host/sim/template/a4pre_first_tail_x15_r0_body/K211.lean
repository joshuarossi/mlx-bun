import host.sim.template.a4pre_first_tail_x15_r0_body.H26
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
boot_rfl PRE_first_tail_x15_r0_body.stepA250 from PRE_first_tail_x15_r0_body.s844 to PRE_first_tail_x15_r0_body.s845 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s844).run PRE_first_tail_x15_r0_body.S844 = some (PRE_first_tail_x15_r0_body.s845, PRE_first_tail_x15_r0_body.S845)
boot_rfl PRE_first_tail_x15_r0_body.patchB250 from PRE_first_tail_x15_r0_body.s845 to PRE_first_tail_x15_r0_body.s846 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s845).run PRE_first_tail_x15_r0_body.S845 = some (PRE_first_tail_x15_r0_body.s846, PRE_first_tail_x15_r0_body.S846)
boot_rfl PRE_first_tail_x15_r0_body.k846 from PRE_first_tail_x15_r0_body.s846 to PRE_first_tail_x15_r0_body.s847 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB250 ((nth? PRE_first_tail_x15_r0_body.ks 846).getD 0) PRE_first_tail_x15_r0_body.s846 PRE_first_tail_x15_r0_body.S846 = some (PRE_first_tail_x15_r0_body.s847, PRE_first_tail_x15_r0_body.S847)
boot_rfl PRE_first_tail_x15_r0_body.stepA251 from PRE_first_tail_x15_r0_body.s847 to PRE_first_tail_x15_r0_body.s848 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s847).run PRE_first_tail_x15_r0_body.S847 = some (PRE_first_tail_x15_r0_body.s848, PRE_first_tail_x15_r0_body.S848)
end Host.Load.Run.Tpl
