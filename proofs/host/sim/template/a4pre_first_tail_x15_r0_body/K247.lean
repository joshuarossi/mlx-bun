import host.sim.template.a4pre_first_tail_x15_r0_body.H31
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
boot_rfl PRE_first_tail_x15_r0_body.k988 from PRE_first_tail_x15_r0_body.s988 to PRE_first_tail_x15_r0_body.s989 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB292 ((nth? PRE_first_tail_x15_r0_body.ks 988).getD 0) PRE_first_tail_x15_r0_body.s988 PRE_first_tail_x15_r0_body.S988 = some (PRE_first_tail_x15_r0_body.s989, PRE_first_tail_x15_r0_body.S989)
boot_rfl PRE_first_tail_x15_r0_body.stepA293 from PRE_first_tail_x15_r0_body.s989 to PRE_first_tail_x15_r0_body.s990 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s989).run PRE_first_tail_x15_r0_body.S989 = some (PRE_first_tail_x15_r0_body.s990, PRE_first_tail_x15_r0_body.S990)
boot_rfl PRE_first_tail_x15_r0_body.patchB293 from PRE_first_tail_x15_r0_body.s990 to PRE_first_tail_x15_r0_body.s991 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s990).run PRE_first_tail_x15_r0_body.S990 = some (PRE_first_tail_x15_r0_body.s991, PRE_first_tail_x15_r0_body.S991)
boot_rfl PRE_first_tail_x15_r0_body.k991 from PRE_first_tail_x15_r0_body.s991 to PRE_first_tail_x15_r0_body.s992 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB293 ((nth? PRE_first_tail_x15_r0_body.ks 991).getD 0) PRE_first_tail_x15_r0_body.s991 PRE_first_tail_x15_r0_body.S991 = some (PRE_first_tail_x15_r0_body.s992, PRE_first_tail_x15_r0_body.S992)
end Host.Load.Run.Tpl
