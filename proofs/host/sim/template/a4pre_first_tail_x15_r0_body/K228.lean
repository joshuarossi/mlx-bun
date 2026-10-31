import host.sim.template.a4pre_first_tail_x15_r0_body.H28
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
boot_rfl PRE_first_tail_x15_r0_body.patchB270 from PRE_first_tail_x15_r0_body.s912 to PRE_first_tail_x15_r0_body.s913 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s912).run PRE_first_tail_x15_r0_body.S912 = some (PRE_first_tail_x15_r0_body.s913, PRE_first_tail_x15_r0_body.S913)
boot_rfl PRE_first_tail_x15_r0_body.k913 from PRE_first_tail_x15_r0_body.s913 to PRE_first_tail_x15_r0_body.s914 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB270 ((nth? PRE_first_tail_x15_r0_body.ks 913).getD 0) PRE_first_tail_x15_r0_body.s913 PRE_first_tail_x15_r0_body.S913 = some (PRE_first_tail_x15_r0_body.s914, PRE_first_tail_x15_r0_body.S914)
boot_rfl PRE_first_tail_x15_r0_body.stepA271 from PRE_first_tail_x15_r0_body.s914 to PRE_first_tail_x15_r0_body.s915 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s914).run PRE_first_tail_x15_r0_body.S914 = some (PRE_first_tail_x15_r0_body.s915, PRE_first_tail_x15_r0_body.S915)
end Host.Load.Run.Tpl
