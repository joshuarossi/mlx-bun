import host.sim.template.a4pre_first_tail_x15_r0_body.H29
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
boot_rfl PRE_first_tail_x15_r0_body.patchB277 from PRE_first_tail_x15_r0_body.s936 to PRE_first_tail_x15_r0_body.s937 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s936).run PRE_first_tail_x15_r0_body.S936 = some (PRE_first_tail_x15_r0_body.s937, PRE_first_tail_x15_r0_body.S937)
boot_rfl PRE_first_tail_x15_r0_body.k937 from PRE_first_tail_x15_r0_body.s937 to PRE_first_tail_x15_r0_body.s938 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB277 ((nth? PRE_first_tail_x15_r0_body.ks 937).getD 0) PRE_first_tail_x15_r0_body.s937 PRE_first_tail_x15_r0_body.S937 = some (PRE_first_tail_x15_r0_body.s938, PRE_first_tail_x15_r0_body.S938)
boot_rfl PRE_first_tail_x15_r0_body.stepA278 from PRE_first_tail_x15_r0_body.s938 to PRE_first_tail_x15_r0_body.s939 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s938).run PRE_first_tail_x15_r0_body.S938 = some (PRE_first_tail_x15_r0_body.s939, PRE_first_tail_x15_r0_body.S939)
end Host.Load.Run.Tpl
