import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA169 from PRE_first_tail_x15_r0_body.s569 to PRE_first_tail_x15_r0_body.s570 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s569).run PRE_first_tail_x15_r0_body.S569 = some (PRE_first_tail_x15_r0_body.s570, PRE_first_tail_x15_r0_body.S570)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB169 from PRE_first_tail_x15_r0_body.s570 to PRE_first_tail_x15_r0_body.s571 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s570).run PRE_first_tail_x15_r0_body.S570 = some (PRE_first_tail_x15_r0_body.s571, PRE_first_tail_x15_r0_body.S571)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA170 from PRE_first_tail_x15_r0_body.s572 to PRE_first_tail_x15_r0_body.s573 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s572).run PRE_first_tail_x15_r0_body.S572 = some (PRE_first_tail_x15_r0_body.s573, PRE_first_tail_x15_r0_body.S573)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA171 from PRE_first_tail_x15_r0_body.s576 to PRE_first_tail_x15_r0_body.s577 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s576).run PRE_first_tail_x15_r0_body.S576 = some (PRE_first_tail_x15_r0_body.s577, PRE_first_tail_x15_r0_body.S577)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA172 from PRE_first_tail_x15_r0_body.s580 to PRE_first_tail_x15_r0_body.s581 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s580).run PRE_first_tail_x15_r0_body.S580 = some (PRE_first_tail_x15_r0_body.s581, PRE_first_tail_x15_r0_body.S581)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB172 from PRE_first_tail_x15_r0_body.s581 to PRE_first_tail_x15_r0_body.s582 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s581).run PRE_first_tail_x15_r0_body.S581 = some (PRE_first_tail_x15_r0_body.s582, PRE_first_tail_x15_r0_body.S582)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA173 from PRE_first_tail_x15_r0_body.s583 to PRE_first_tail_x15_r0_body.s584 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s583).run PRE_first_tail_x15_r0_body.S583 = some (PRE_first_tail_x15_r0_body.s584, PRE_first_tail_x15_r0_body.S584)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB173 from PRE_first_tail_x15_r0_body.s584 to PRE_first_tail_x15_r0_body.s585 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s584).run PRE_first_tail_x15_r0_body.S584 = some (PRE_first_tail_x15_r0_body.s585, PRE_first_tail_x15_r0_body.S585)
end Host.Load.Run.Tpl
