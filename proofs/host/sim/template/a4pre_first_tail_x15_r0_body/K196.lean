import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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
boot_rfl PRE_first_tail_x15_r0_body.stepA212 from PRE_first_tail_x15_r0_body.s784 to PRE_first_tail_x15_r0_body.s785 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s784).run PRE_first_tail_x15_r0_body.S784 = some (PRE_first_tail_x15_r0_body.s785, PRE_first_tail_x15_r0_body.S785)
boot_rfl PRE_first_tail_x15_r0_body.patchB212 from PRE_first_tail_x15_r0_body.s785 to PRE_first_tail_x15_r0_body.s786 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s785).run PRE_first_tail_x15_r0_body.S785 = some (PRE_first_tail_x15_r0_body.s786, PRE_first_tail_x15_r0_body.S786)
boot_rfl PRE_first_tail_x15_r0_body.k786 from PRE_first_tail_x15_r0_body.s786 to PRE_first_tail_x15_r0_body.s787 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB212 ((nth? PRE_first_tail_x15_r0_body.ks 786).getD 0) PRE_first_tail_x15_r0_body.s786 PRE_first_tail_x15_r0_body.S786 = some (PRE_first_tail_x15_r0_body.s787, PRE_first_tail_x15_r0_body.S787)
boot_rfl PRE_first_tail_x15_r0_body.stepA213 from PRE_first_tail_x15_r0_body.s787 to PRE_first_tail_x15_r0_body.s788 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s787).run PRE_first_tail_x15_r0_body.S787 = some (PRE_first_tail_x15_r0_body.s788, PRE_first_tail_x15_r0_body.S788)
end Host.Load.Run.Tpl
