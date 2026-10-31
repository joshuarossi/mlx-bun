import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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
boot_rfl PRE_first_tail_x15_r0_body.k81 from PRE_first_tail_x15_r0_body.s81 to PRE_first_tail_x15_r0_body.s82 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB24 ((nth? PRE_first_tail_x15_r0_body.ks 81).getD 0) PRE_first_tail_x15_r0_body.s81 PRE_first_tail_x15_r0_body.S81 = some (PRE_first_tail_x15_r0_body.s82, PRE_first_tail_x15_r0_body.S82)
boot_rfl PRE_first_tail_x15_r0_body.stepA25 from PRE_first_tail_x15_r0_body.s82 to PRE_first_tail_x15_r0_body.s83 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s82).run PRE_first_tail_x15_r0_body.S82 = some (PRE_first_tail_x15_r0_body.s83, PRE_first_tail_x15_r0_body.S83)
boot_rfl PRE_first_tail_x15_r0_body.patchB25 from PRE_first_tail_x15_r0_body.s83 to PRE_first_tail_x15_r0_body.s84 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s83).run PRE_first_tail_x15_r0_body.S83 = some (PRE_first_tail_x15_r0_body.s84, PRE_first_tail_x15_r0_body.S84)
end Host.Load.Run.Tpl
