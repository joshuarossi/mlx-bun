import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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
boot_rfl PRE_first_tail_x15_r0_body.patchB95 from PRE_first_tail_x15_r0_body.s320 to PRE_first_tail_x15_r0_body.s321 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s320).run PRE_first_tail_x15_r0_body.S320 = some (PRE_first_tail_x15_r0_body.s321, PRE_first_tail_x15_r0_body.S321)
boot_rfl PRE_first_tail_x15_r0_body.k321 from PRE_first_tail_x15_r0_body.s321 to PRE_first_tail_x15_r0_body.s322 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB95 ((nth? PRE_first_tail_x15_r0_body.ks 321).getD 0) PRE_first_tail_x15_r0_body.s321 PRE_first_tail_x15_r0_body.S321 = some (PRE_first_tail_x15_r0_body.s322, PRE_first_tail_x15_r0_body.S322)
boot_rfl PRE_first_tail_x15_r0_body.stepA96 from PRE_first_tail_x15_r0_body.s322 to PRE_first_tail_x15_r0_body.s323 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s322).run PRE_first_tail_x15_r0_body.S322 = some (PRE_first_tail_x15_r0_body.s323, PRE_first_tail_x15_r0_body.S323)
boot_rfl PRE_first_tail_x15_r0_body.patchB96 from PRE_first_tail_x15_r0_body.s323 to PRE_first_tail_x15_r0_body.s324 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s323).run PRE_first_tail_x15_r0_body.S323 = some (PRE_first_tail_x15_r0_body.s324, PRE_first_tail_x15_r0_body.S324)
end Host.Load.Run.Tpl
