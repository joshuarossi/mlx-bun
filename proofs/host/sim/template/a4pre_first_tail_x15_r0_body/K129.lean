import host.sim.template.a4pre_first_tail_x15_r0_body.H16
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
boot_rfl PRE_first_tail_x15_r0_body.stepA140 from PRE_first_tail_x15_r0_body.s516 to PRE_first_tail_x15_r0_body.s517 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s516).run PRE_first_tail_x15_r0_body.S516 = some (PRE_first_tail_x15_r0_body.s517, PRE_first_tail_x15_r0_body.S517)
boot_rfl PRE_first_tail_x15_r0_body.k519 from PRE_first_tail_x15_r0_body.s519 to PRE_first_tail_x15_r0_body.s520 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB140 ((nth? PRE_first_tail_x15_r0_body.ks 519).getD 0) PRE_first_tail_x15_r0_body.s519 PRE_first_tail_x15_r0_body.S519 = some (PRE_first_tail_x15_r0_body.s520, PRE_first_tail_x15_r0_body.S520)
end Host.Load.Run.Tpl
