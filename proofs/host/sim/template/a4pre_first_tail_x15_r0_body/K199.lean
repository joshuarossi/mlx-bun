import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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
boot_rfl PRE_first_tail_x15_r0_body.stepA236 from PRE_first_tail_x15_r0_body.s796 to PRE_first_tail_x15_r0_body.s797 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s796).run PRE_first_tail_x15_r0_body.S796 = some (PRE_first_tail_x15_r0_body.s797, PRE_first_tail_x15_r0_body.S797)
boot_rfl PRE_first_tail_x15_r0_body.patchB236 from PRE_first_tail_x15_r0_body.s797 to PRE_first_tail_x15_r0_body.s798 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s797).run PRE_first_tail_x15_r0_body.S797 = some (PRE_first_tail_x15_r0_body.s798, PRE_first_tail_x15_r0_body.S798)
boot_rfl PRE_first_tail_x15_r0_body.k798 from PRE_first_tail_x15_r0_body.s798 to PRE_first_tail_x15_r0_body.s799 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB236 ((nth? PRE_first_tail_x15_r0_body.ks 798).getD 0) PRE_first_tail_x15_r0_body.s798 PRE_first_tail_x15_r0_body.S798 = some (PRE_first_tail_x15_r0_body.s799, PRE_first_tail_x15_r0_body.S799)
boot_rfl PRE_first_tail_x15_r0_body.stepA237 from PRE_first_tail_x15_r0_body.s799 to PRE_first_tail_x15_r0_body.s800 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s799).run PRE_first_tail_x15_r0_body.S799 = some (PRE_first_tail_x15_r0_body.s800, PRE_first_tail_x15_r0_body.S800)
end Host.Load.Run.Tpl
