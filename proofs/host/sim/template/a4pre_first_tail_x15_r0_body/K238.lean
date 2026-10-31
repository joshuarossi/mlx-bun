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
boot_rfl PRE_first_tail_x15_r0_body.stepA257 from PRE_first_tail_x15_r0_body.s952 to PRE_first_tail_x15_r0_body.s953 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s952).run PRE_first_tail_x15_r0_body.S952 = some (PRE_first_tail_x15_r0_body.s953, PRE_first_tail_x15_r0_body.S953)
boot_rfl PRE_first_tail_x15_r0_body.patchB257 from PRE_first_tail_x15_r0_body.s953 to PRE_first_tail_x15_r0_body.s954 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s953).run PRE_first_tail_x15_r0_body.S953 = some (PRE_first_tail_x15_r0_body.s954, PRE_first_tail_x15_r0_body.S954)
boot_rfl PRE_first_tail_x15_r0_body.k954 from PRE_first_tail_x15_r0_body.s954 to PRE_first_tail_x15_r0_body.s955 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB257 ((nth? PRE_first_tail_x15_r0_body.ks 954).getD 0) PRE_first_tail_x15_r0_body.s954 PRE_first_tail_x15_r0_body.S954 = some (PRE_first_tail_x15_r0_body.s955, PRE_first_tail_x15_r0_body.S955)
boot_rfl PRE_first_tail_x15_r0_body.stepA258 from PRE_first_tail_x15_r0_body.s955 to PRE_first_tail_x15_r0_body.s956 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s955).run PRE_first_tail_x15_r0_body.S955 = some (PRE_first_tail_x15_r0_body.s956, PRE_first_tail_x15_r0_body.S956)
end Host.Load.Run.Tpl
