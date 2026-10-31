import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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
boot_rfl PRE_first_tail_x15_r0_body.stepA188 from PRE_first_tail_x15_r0_body.s696 to PRE_first_tail_x15_r0_body.s697 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s696).run PRE_first_tail_x15_r0_body.S696 = some (PRE_first_tail_x15_r0_body.s697, PRE_first_tail_x15_r0_body.S697)
boot_rfl PRE_first_tail_x15_r0_body.patchB188 from PRE_first_tail_x15_r0_body.s697 to PRE_first_tail_x15_r0_body.s698 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s697).run PRE_first_tail_x15_r0_body.S697 = some (PRE_first_tail_x15_r0_body.s698, PRE_first_tail_x15_r0_body.S698)
boot_rfl PRE_first_tail_x15_r0_body.k698 from PRE_first_tail_x15_r0_body.s698 to PRE_first_tail_x15_r0_body.s699 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB188 ((nth? PRE_first_tail_x15_r0_body.ks 698).getD 0) PRE_first_tail_x15_r0_body.s698 PRE_first_tail_x15_r0_body.S698 = some (PRE_first_tail_x15_r0_body.s699, PRE_first_tail_x15_r0_body.S699)
boot_rfl PRE_first_tail_x15_r0_body.stepA189 from PRE_first_tail_x15_r0_body.s699 to PRE_first_tail_x15_r0_body.s700 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s699).run PRE_first_tail_x15_r0_body.S699 = some (PRE_first_tail_x15_r0_body.s700, PRE_first_tail_x15_r0_body.S700)
end Host.Load.Run.Tpl
