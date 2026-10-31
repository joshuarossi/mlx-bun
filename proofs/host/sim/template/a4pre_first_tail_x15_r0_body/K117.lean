import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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
boot_rfl PRE_first_tail_x15_r0_body.k468 from PRE_first_tail_x15_r0_body.s468 to PRE_first_tail_x15_r0_body.s469 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB126 ((nth? PRE_first_tail_x15_r0_body.ks 468).getD 0) PRE_first_tail_x15_r0_body.s468 PRE_first_tail_x15_r0_body.S468 = some (PRE_first_tail_x15_r0_body.s469, PRE_first_tail_x15_r0_body.S469)
boot_rfl PRE_first_tail_x15_r0_body.stepA127 from PRE_first_tail_x15_r0_body.s469 to PRE_first_tail_x15_r0_body.s470 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s469).run PRE_first_tail_x15_r0_body.S469 = some (PRE_first_tail_x15_r0_body.s470, PRE_first_tail_x15_r0_body.S470)
boot_rfl PRE_first_tail_x15_r0_body.patchB127 from PRE_first_tail_x15_r0_body.s470 to PRE_first_tail_x15_r0_body.s471 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s470).run PRE_first_tail_x15_r0_body.S470 = some (PRE_first_tail_x15_r0_body.s471, PRE_first_tail_x15_r0_body.S471)
boot_rfl PRE_first_tail_x15_r0_body.k471 from PRE_first_tail_x15_r0_body.s471 to PRE_first_tail_x15_r0_body.s472 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB127 ((nth? PRE_first_tail_x15_r0_body.ks 471).getD 0) PRE_first_tail_x15_r0_body.s471 PRE_first_tail_x15_r0_body.S471 = some (PRE_first_tail_x15_r0_body.s472, PRE_first_tail_x15_r0_body.S472)
end Host.Load.Run.Tpl
