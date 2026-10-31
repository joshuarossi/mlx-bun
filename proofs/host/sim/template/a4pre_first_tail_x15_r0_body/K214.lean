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
boot_rfl PRE_first_tail_x15_r0_body.k856 from PRE_first_tail_x15_r0_body.s856 to PRE_first_tail_x15_r0_body.s857 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB253 ((nth? PRE_first_tail_x15_r0_body.ks 856).getD 0) PRE_first_tail_x15_r0_body.s856 PRE_first_tail_x15_r0_body.S856 = some (PRE_first_tail_x15_r0_body.s857, PRE_first_tail_x15_r0_body.S857)
boot_rfl PRE_first_tail_x15_r0_body.stepA254 from PRE_first_tail_x15_r0_body.s857 to PRE_first_tail_x15_r0_body.s858 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s857).run PRE_first_tail_x15_r0_body.S857 = some (PRE_first_tail_x15_r0_body.s858, PRE_first_tail_x15_r0_body.S858)
boot_rfl PRE_first_tail_x15_r0_body.patchB254 from PRE_first_tail_x15_r0_body.s858 to PRE_first_tail_x15_r0_body.s859 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s858).run PRE_first_tail_x15_r0_body.S858 = some (PRE_first_tail_x15_r0_body.s859, PRE_first_tail_x15_r0_body.S859)
boot_rfl PRE_first_tail_x15_r0_body.k859 from PRE_first_tail_x15_r0_body.s859 to PRE_first_tail_x15_r0_body.s860 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB254 ((nth? PRE_first_tail_x15_r0_body.ks 859).getD 0) PRE_first_tail_x15_r0_body.s859 PRE_first_tail_x15_r0_body.S859 = some (PRE_first_tail_x15_r0_body.s860, PRE_first_tail_x15_r0_body.S860)
end Host.Load.Run.Tpl
