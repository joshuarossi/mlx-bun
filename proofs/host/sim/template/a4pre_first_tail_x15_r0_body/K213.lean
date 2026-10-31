import host.sim.template.a4pre_first_tail_x15_r0_body.H26
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
boot_rfl PRE_first_tail_x15_r0_body.k852 from PRE_first_tail_x15_r0_body.s852 to PRE_first_tail_x15_r0_body.s853 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB230 ((nth? PRE_first_tail_x15_r0_body.ks 852).getD 0) PRE_first_tail_x15_r0_body.s852 PRE_first_tail_x15_r0_body.S852 = some (PRE_first_tail_x15_r0_body.s853, PRE_first_tail_x15_r0_body.S853)
boot_rfl PRE_first_tail_x15_r0_body.stepA231 from PRE_first_tail_x15_r0_body.s853 to PRE_first_tail_x15_r0_body.s854 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s853).run PRE_first_tail_x15_r0_body.S853 = some (PRE_first_tail_x15_r0_body.s854, PRE_first_tail_x15_r0_body.S854)
boot_rfl PRE_first_tail_x15_r0_body.patchB231 from PRE_first_tail_x15_r0_body.s854 to PRE_first_tail_x15_r0_body.s855 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s854).run PRE_first_tail_x15_r0_body.S854 = some (PRE_first_tail_x15_r0_body.s855, PRE_first_tail_x15_r0_body.S855)
boot_rfl PRE_first_tail_x15_r0_body.k855 from PRE_first_tail_x15_r0_body.s855 to PRE_first_tail_x15_r0_body.s856 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB231 ((nth? PRE_first_tail_x15_r0_body.ks 855).getD 0) PRE_first_tail_x15_r0_body.s855 PRE_first_tail_x15_r0_body.S855 = some (PRE_first_tail_x15_r0_body.s856, PRE_first_tail_x15_r0_body.S856)
end Host.Load.Run.Tpl
