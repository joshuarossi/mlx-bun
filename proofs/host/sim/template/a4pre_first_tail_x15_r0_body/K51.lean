import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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
boot_rfl PRE_first_tail_x15_r0_body.k204 from PRE_first_tail_x15_r0_body.s204 to PRE_first_tail_x15_r0_body.s205 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB55 ((nth? PRE_first_tail_x15_r0_body.ks 204).getD 0) PRE_first_tail_x15_r0_body.s204 PRE_first_tail_x15_r0_body.S204 = some (PRE_first_tail_x15_r0_body.s205, PRE_first_tail_x15_r0_body.S205)
boot_rfl PRE_first_tail_x15_r0_body.stepA56 from PRE_first_tail_x15_r0_body.s205 to PRE_first_tail_x15_r0_body.s206 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s205).run PRE_first_tail_x15_r0_body.S205 = some (PRE_first_tail_x15_r0_body.s206, PRE_first_tail_x15_r0_body.S206)
boot_rfl PRE_first_tail_x15_r0_body.patchB56 from PRE_first_tail_x15_r0_body.s206 to PRE_first_tail_x15_r0_body.s207 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s206).run PRE_first_tail_x15_r0_body.S206 = some (PRE_first_tail_x15_r0_body.s207, PRE_first_tail_x15_r0_body.S207)
boot_rfl PRE_first_tail_x15_r0_body.k207 from PRE_first_tail_x15_r0_body.s207 to PRE_first_tail_x15_r0_body.s208 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB56 ((nth? PRE_first_tail_x15_r0_body.ks 207).getD 0) PRE_first_tail_x15_r0_body.s207 PRE_first_tail_x15_r0_body.S207 = some (PRE_first_tail_x15_r0_body.s208, PRE_first_tail_x15_r0_body.S208)
end Host.Load.Run.Tpl
