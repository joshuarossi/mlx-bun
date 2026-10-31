import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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
boot_rfl PRE_first_tail_x15_r0_body.patchB213 from PRE_first_tail_x15_r0_body.s788 to PRE_first_tail_x15_r0_body.s789 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s788).run PRE_first_tail_x15_r0_body.S788 = some (PRE_first_tail_x15_r0_body.s789, PRE_first_tail_x15_r0_body.S789)
boot_rfl PRE_first_tail_x15_r0_body.k789 from PRE_first_tail_x15_r0_body.s789 to PRE_first_tail_x15_r0_body.s790 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB213 ((nth? PRE_first_tail_x15_r0_body.ks 789).getD 0) PRE_first_tail_x15_r0_body.s789 PRE_first_tail_x15_r0_body.S789 = some (PRE_first_tail_x15_r0_body.s790, PRE_first_tail_x15_r0_body.S790)
boot_rfl PRE_first_tail_x15_r0_body.k790 from PRE_first_tail_x15_r0_body.s790 to PRE_first_tail_x15_r0_body.s791 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB213 ((nth? PRE_first_tail_x15_r0_body.ks 790).getD 0) PRE_first_tail_x15_r0_body.s790 PRE_first_tail_x15_r0_body.S790 = some (PRE_first_tail_x15_r0_body.s791, PRE_first_tail_x15_r0_body.S791)
boot_rfl PRE_first_tail_x15_r0_body.stepA214 from PRE_first_tail_x15_r0_body.s791 to PRE_first_tail_x15_r0_body.s792 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s791).run PRE_first_tail_x15_r0_body.S791 = some (PRE_first_tail_x15_r0_body.s792, PRE_first_tail_x15_r0_body.S792)
end Host.Load.Run.Tpl
