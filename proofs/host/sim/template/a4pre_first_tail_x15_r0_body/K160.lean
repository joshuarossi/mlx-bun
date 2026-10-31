import host.sim.template.a4pre_first_tail_x15_r0_body.H20
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
boot_rfl PRE_first_tail_x15_r0_body.patchB173 from PRE_first_tail_x15_r0_body.s640 to PRE_first_tail_x15_r0_body.s641 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s640).run PRE_first_tail_x15_r0_body.S640 = some (PRE_first_tail_x15_r0_body.s641, PRE_first_tail_x15_r0_body.S641)
boot_rfl PRE_first_tail_x15_r0_body.k641 from PRE_first_tail_x15_r0_body.s641 to PRE_first_tail_x15_r0_body.s642 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB173 ((nth? PRE_first_tail_x15_r0_body.ks 641).getD 0) PRE_first_tail_x15_r0_body.s641 PRE_first_tail_x15_r0_body.S641 = some (PRE_first_tail_x15_r0_body.s642, PRE_first_tail_x15_r0_body.S642)
boot_rfl PRE_first_tail_x15_r0_body.stepA174 from PRE_first_tail_x15_r0_body.s642 to PRE_first_tail_x15_r0_body.s643 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s642).run PRE_first_tail_x15_r0_body.S642 = some (PRE_first_tail_x15_r0_body.s643, PRE_first_tail_x15_r0_body.S643)
boot_rfl PRE_first_tail_x15_r0_body.patchB174 from PRE_first_tail_x15_r0_body.s643 to PRE_first_tail_x15_r0_body.s644 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s643).run PRE_first_tail_x15_r0_body.S643 = some (PRE_first_tail_x15_r0_body.s644, PRE_first_tail_x15_r0_body.S644)
end Host.Load.Run.Tpl
