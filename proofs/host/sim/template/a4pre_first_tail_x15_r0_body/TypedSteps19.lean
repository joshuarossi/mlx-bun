import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA95 from PRE_first_tail_x15_r0_body.s351 to PRE_first_tail_x15_r0_body.s352 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s351).run PRE_first_tail_x15_r0_body.S351 = some (PRE_first_tail_x15_r0_body.s352, PRE_first_tail_x15_r0_body.S352)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB95 from PRE_first_tail_x15_r0_body.s352 to PRE_first_tail_x15_r0_body.s353 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s352).run PRE_first_tail_x15_r0_body.S352 = some (PRE_first_tail_x15_r0_body.s353, PRE_first_tail_x15_r0_body.S353)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA96 from PRE_first_tail_x15_r0_body.s354 to PRE_first_tail_x15_r0_body.s355 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s354).run PRE_first_tail_x15_r0_body.S354 = some (PRE_first_tail_x15_r0_body.s355, PRE_first_tail_x15_r0_body.S355)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB96 from PRE_first_tail_x15_r0_body.s355 to PRE_first_tail_x15_r0_body.s356 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s355).run PRE_first_tail_x15_r0_body.S355 = some (PRE_first_tail_x15_r0_body.s356, PRE_first_tail_x15_r0_body.S356)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA97 from PRE_first_tail_x15_r0_body.s357 to PRE_first_tail_x15_r0_body.s358 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s357).run PRE_first_tail_x15_r0_body.S357 = some (PRE_first_tail_x15_r0_body.s358, PRE_first_tail_x15_r0_body.S358)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB97 from PRE_first_tail_x15_r0_body.s358 to PRE_first_tail_x15_r0_body.s359 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s358).run PRE_first_tail_x15_r0_body.S358 = some (PRE_first_tail_x15_r0_body.s359, PRE_first_tail_x15_r0_body.S359)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA98 from PRE_first_tail_x15_r0_body.s360 to PRE_first_tail_x15_r0_body.s361 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s360).run PRE_first_tail_x15_r0_body.S360 = some (PRE_first_tail_x15_r0_body.s361, PRE_first_tail_x15_r0_body.S361)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA99 from PRE_first_tail_x15_r0_body.s364 to PRE_first_tail_x15_r0_body.s365 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s364).run PRE_first_tail_x15_r0_body.S364 = some (PRE_first_tail_x15_r0_body.s365, PRE_first_tail_x15_r0_body.S365)
end Host.Load.Run.Tpl
