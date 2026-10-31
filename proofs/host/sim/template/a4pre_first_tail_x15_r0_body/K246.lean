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
boot_rfl PRE_first_tail_x15_r0_body.stepA266 from PRE_first_tail_x15_r0_body.s984 to PRE_first_tail_x15_r0_body.s985 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s984).run PRE_first_tail_x15_r0_body.S984 = some (PRE_first_tail_x15_r0_body.s985, PRE_first_tail_x15_r0_body.S985)
boot_rfl PRE_first_tail_x15_r0_body.patchB266 from PRE_first_tail_x15_r0_body.s985 to PRE_first_tail_x15_r0_body.s986 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s985).run PRE_first_tail_x15_r0_body.S985 = some (PRE_first_tail_x15_r0_body.s986, PRE_first_tail_x15_r0_body.S986)
boot_rfl PRE_first_tail_x15_r0_body.k986 from PRE_first_tail_x15_r0_body.s986 to PRE_first_tail_x15_r0_body.s987 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB266 ((nth? PRE_first_tail_x15_r0_body.ks 986).getD 0) PRE_first_tail_x15_r0_body.s986 PRE_first_tail_x15_r0_body.S986 = some (PRE_first_tail_x15_r0_body.s987, PRE_first_tail_x15_r0_body.S987)
boot_rfl PRE_first_tail_x15_r0_body.stepA267 from PRE_first_tail_x15_r0_body.s987 to PRE_first_tail_x15_r0_body.s988 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s987).run PRE_first_tail_x15_r0_body.S987 = some (PRE_first_tail_x15_r0_body.s988, PRE_first_tail_x15_r0_body.S988)
end Host.Load.Run.Tpl
