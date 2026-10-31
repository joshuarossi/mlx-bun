import host.sim.template.a4pre_first_tail_x15_r0_body.H14
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA125 from PRE_first_tail_x15_r0_body.s463 to PRE_first_tail_x15_r0_body.s464 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s463).run PRE_first_tail_x15_r0_body.S463 = some (PRE_first_tail_x15_r0_body.s464, PRE_first_tail_x15_r0_body.S464)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB125 from PRE_first_tail_x15_r0_body.s464 to PRE_first_tail_x15_r0_body.s465 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s464).run PRE_first_tail_x15_r0_body.S464 = some (PRE_first_tail_x15_r0_body.s465, PRE_first_tail_x15_r0_body.S465)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA126 from PRE_first_tail_x15_r0_body.s466 to PRE_first_tail_x15_r0_body.s467 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s466).run PRE_first_tail_x15_r0_body.S466 = some (PRE_first_tail_x15_r0_body.s467, PRE_first_tail_x15_r0_body.S467)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB126 from PRE_first_tail_x15_r0_body.s467 to PRE_first_tail_x15_r0_body.s468 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s467).run PRE_first_tail_x15_r0_body.S467 = some (PRE_first_tail_x15_r0_body.s468, PRE_first_tail_x15_r0_body.S468)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA127 from PRE_first_tail_x15_r0_body.s469 to PRE_first_tail_x15_r0_body.s470 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s469).run PRE_first_tail_x15_r0_body.S469 = some (PRE_first_tail_x15_r0_body.s470, PRE_first_tail_x15_r0_body.S470)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB127 from PRE_first_tail_x15_r0_body.s470 to PRE_first_tail_x15_r0_body.s471 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s470).run PRE_first_tail_x15_r0_body.S470 = some (PRE_first_tail_x15_r0_body.s471, PRE_first_tail_x15_r0_body.S471)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA128 from PRE_first_tail_x15_r0_body.s472 to PRE_first_tail_x15_r0_body.s473 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s472).run PRE_first_tail_x15_r0_body.S472 = some (PRE_first_tail_x15_r0_body.s473, PRE_first_tail_x15_r0_body.S473)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB128 from PRE_first_tail_x15_r0_body.s473 to PRE_first_tail_x15_r0_body.s474 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s473).run PRE_first_tail_x15_r0_body.S473 = some (PRE_first_tail_x15_r0_body.s474, PRE_first_tail_x15_r0_body.S474)
end Host.Load.Run.Tpl
