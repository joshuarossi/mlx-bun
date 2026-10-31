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
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB104 from PRE_first_tail_x15_r0_body.s350 to PRE_first_tail_x15_r0_body.s351 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s350).run PRE_first_tail_x15_r0_body.S350 = some (PRE_first_tail_x15_r0_body.s351, PRE_first_tail_x15_r0_body.S351)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA105 from PRE_first_tail_x15_r0_body.s352 to PRE_first_tail_x15_r0_body.s353 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s352).run PRE_first_tail_x15_r0_body.S352 = some (PRE_first_tail_x15_r0_body.s353, PRE_first_tail_x15_r0_body.S353)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB105 from PRE_first_tail_x15_r0_body.s353 to PRE_first_tail_x15_r0_body.s354 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s353).run PRE_first_tail_x15_r0_body.S353 = some (PRE_first_tail_x15_r0_body.s354, PRE_first_tail_x15_r0_body.S354)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA106 from PRE_first_tail_x15_r0_body.s355 to PRE_first_tail_x15_r0_body.s356 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s355).run PRE_first_tail_x15_r0_body.S355 = some (PRE_first_tail_x15_r0_body.s356, PRE_first_tail_x15_r0_body.S356)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA107 from PRE_first_tail_x15_r0_body.s359 to PRE_first_tail_x15_r0_body.s360 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s359).run PRE_first_tail_x15_r0_body.S359 = some (PRE_first_tail_x15_r0_body.s360, PRE_first_tail_x15_r0_body.S360)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB107 from PRE_first_tail_x15_r0_body.s360 to PRE_first_tail_x15_r0_body.s361 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s360).run PRE_first_tail_x15_r0_body.S360 = some (PRE_first_tail_x15_r0_body.s361, PRE_first_tail_x15_r0_body.S361)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA108 from PRE_first_tail_x15_r0_body.s362 to PRE_first_tail_x15_r0_body.s363 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s362).run PRE_first_tail_x15_r0_body.S362 = some (PRE_first_tail_x15_r0_body.s363, PRE_first_tail_x15_r0_body.S363)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA109 from PRE_first_tail_x15_r0_body.s366 to PRE_first_tail_x15_r0_body.s367 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s366).run PRE_first_tail_x15_r0_body.S366 = some (PRE_first_tail_x15_r0_body.s367, PRE_first_tail_x15_r0_body.S367)
end Host.Load.Run.Tpl
