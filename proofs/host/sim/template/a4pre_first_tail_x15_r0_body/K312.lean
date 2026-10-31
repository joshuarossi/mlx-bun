import host.sim.template.a4pre_first_tail_x15_r0_body.H39
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
boot_rfl PRE_first_tail_x15_r0_body.patchB337 from PRE_first_tail_x15_r0_body.s1248 to PRE_first_tail_x15_r0_body.s1249 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1248).run PRE_first_tail_x15_r0_body.S1248 = some (PRE_first_tail_x15_r0_body.s1249, PRE_first_tail_x15_r0_body.S1249)
boot_rfl PRE_first_tail_x15_r0_body.k1249 from PRE_first_tail_x15_r0_body.s1249 to PRE_first_tail_x15_r0_body.s1250 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB337 ((nth? PRE_first_tail_x15_r0_body.ks 1249).getD 0) PRE_first_tail_x15_r0_body.s1249 PRE_first_tail_x15_r0_body.S1249 = some (PRE_first_tail_x15_r0_body.s1250, PRE_first_tail_x15_r0_body.S1250)
boot_rfl PRE_first_tail_x15_r0_body.k1250 from PRE_first_tail_x15_r0_body.s1250 to PRE_first_tail_x15_r0_body.s1251 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB337 ((nth? PRE_first_tail_x15_r0_body.ks 1250).getD 0) PRE_first_tail_x15_r0_body.s1250 PRE_first_tail_x15_r0_body.S1250 = some (PRE_first_tail_x15_r0_body.s1251, PRE_first_tail_x15_r0_body.S1251)
boot_rfl PRE_first_tail_x15_r0_body.stepA338 from PRE_first_tail_x15_r0_body.s1251 to PRE_first_tail_x15_r0_body.s1252 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1251).run PRE_first_tail_x15_r0_body.S1251 = some (PRE_first_tail_x15_r0_body.s1252, PRE_first_tail_x15_r0_body.S1252)
end Host.Load.Run.Tpl
