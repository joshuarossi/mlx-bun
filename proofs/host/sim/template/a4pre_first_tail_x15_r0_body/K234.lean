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
boot_rfl PRE_first_tail_x15_r0_body.k938 from PRE_first_tail_x15_r0_body.s938 to PRE_first_tail_x15_r0_body.s939 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB253 ((nth? PRE_first_tail_x15_r0_body.ks 938).getD 0) PRE_first_tail_x15_r0_body.s938 PRE_first_tail_x15_r0_body.S938 = some (PRE_first_tail_x15_r0_body.s939, PRE_first_tail_x15_r0_body.S939)
boot_rfl PRE_first_tail_x15_r0_body.stepA254 from PRE_first_tail_x15_r0_body.s939 to PRE_first_tail_x15_r0_body.s940 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s939).run PRE_first_tail_x15_r0_body.S939 = some (PRE_first_tail_x15_r0_body.s940, PRE_first_tail_x15_r0_body.S940)
end Host.Load.Run.Tpl
