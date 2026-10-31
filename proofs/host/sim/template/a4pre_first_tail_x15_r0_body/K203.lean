import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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
boot_rfl PRE_first_tail_x15_r0_body.patchB219 from PRE_first_tail_x15_r0_body.s812 to PRE_first_tail_x15_r0_body.s813 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s812).run PRE_first_tail_x15_r0_body.S812 = some (PRE_first_tail_x15_r0_body.s813, PRE_first_tail_x15_r0_body.S813)
boot_rfl PRE_first_tail_x15_r0_body.k813 from PRE_first_tail_x15_r0_body.s813 to PRE_first_tail_x15_r0_body.s814 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB219 ((nth? PRE_first_tail_x15_r0_body.ks 813).getD 0) PRE_first_tail_x15_r0_body.s813 PRE_first_tail_x15_r0_body.S813 = some (PRE_first_tail_x15_r0_body.s814, PRE_first_tail_x15_r0_body.S814)
boot_rfl PRE_first_tail_x15_r0_body.stepA220 from PRE_first_tail_x15_r0_body.s814 to PRE_first_tail_x15_r0_body.s815 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s814).run PRE_first_tail_x15_r0_body.S814 = some (PRE_first_tail_x15_r0_body.s815, PRE_first_tail_x15_r0_body.S815)
boot_rfl PRE_first_tail_x15_r0_body.patchB220 from PRE_first_tail_x15_r0_body.s815 to PRE_first_tail_x15_r0_body.s816 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s815).run PRE_first_tail_x15_r0_body.S815 = some (PRE_first_tail_x15_r0_body.s816, PRE_first_tail_x15_r0_body.S816)
end Host.Load.Run.Tpl
