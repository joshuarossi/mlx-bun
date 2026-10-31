import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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
boot_rfl PRE_first_tail_x15_r0_body.patchB258 from PRE_first_tail_x15_r0_body.s956 to PRE_first_tail_x15_r0_body.s957 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s956).run PRE_first_tail_x15_r0_body.S956 = some (PRE_first_tail_x15_r0_body.s957, PRE_first_tail_x15_r0_body.S957)
boot_rfl PRE_first_tail_x15_r0_body.k957 from PRE_first_tail_x15_r0_body.s957 to PRE_first_tail_x15_r0_body.s958 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB258 ((nth? PRE_first_tail_x15_r0_body.ks 957).getD 0) PRE_first_tail_x15_r0_body.s957 PRE_first_tail_x15_r0_body.S957 = some (PRE_first_tail_x15_r0_body.s958, PRE_first_tail_x15_r0_body.S958)
boot_rfl PRE_first_tail_x15_r0_body.stepA259 from PRE_first_tail_x15_r0_body.s958 to PRE_first_tail_x15_r0_body.s959 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s958).run PRE_first_tail_x15_r0_body.S958 = some (PRE_first_tail_x15_r0_body.s959, PRE_first_tail_x15_r0_body.S959)
boot_rfl PRE_first_tail_x15_r0_body.patchB259 from PRE_first_tail_x15_r0_body.s959 to PRE_first_tail_x15_r0_body.s960 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s959).run PRE_first_tail_x15_r0_body.S959 = some (PRE_first_tail_x15_r0_body.s960, PRE_first_tail_x15_r0_body.S960)
end Host.Load.Run.Tpl
