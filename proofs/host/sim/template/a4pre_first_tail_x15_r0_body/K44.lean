import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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
boot_rfl PRE_first_tail_x15_r0_body.stepA53 from PRE_first_tail_x15_r0_body.s176 to PRE_first_tail_x15_r0_body.s177 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s176).run PRE_first_tail_x15_r0_body.S176 = some (PRE_first_tail_x15_r0_body.s177, PRE_first_tail_x15_r0_body.S177)
boot_rfl PRE_first_tail_x15_r0_body.patchB53 from PRE_first_tail_x15_r0_body.s177 to PRE_first_tail_x15_r0_body.s178 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s177).run PRE_first_tail_x15_r0_body.S177 = some (PRE_first_tail_x15_r0_body.s178, PRE_first_tail_x15_r0_body.S178)
boot_rfl PRE_first_tail_x15_r0_body.k178 from PRE_first_tail_x15_r0_body.s178 to PRE_first_tail_x15_r0_body.s179 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB53 ((nth? PRE_first_tail_x15_r0_body.ks 178).getD 0) PRE_first_tail_x15_r0_body.s178 PRE_first_tail_x15_r0_body.S178 = some (PRE_first_tail_x15_r0_body.s179, PRE_first_tail_x15_r0_body.S179)
boot_rfl PRE_first_tail_x15_r0_body.stepA54 from PRE_first_tail_x15_r0_body.s179 to PRE_first_tail_x15_r0_body.s180 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s179).run PRE_first_tail_x15_r0_body.S179 = some (PRE_first_tail_x15_r0_body.s180, PRE_first_tail_x15_r0_body.S180)
end Host.Load.Run.Tpl
