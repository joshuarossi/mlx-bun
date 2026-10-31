import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA125 from PRE_first_tail_x15_r0_body.s421 to PRE_first_tail_x15_r0_body.s422 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s421).run PRE_first_tail_x15_r0_body.S421 = some (PRE_first_tail_x15_r0_body.s422, PRE_first_tail_x15_r0_body.S422)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB125 from PRE_first_tail_x15_r0_body.s422 to PRE_first_tail_x15_r0_body.s423 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s422).run PRE_first_tail_x15_r0_body.S422 = some (PRE_first_tail_x15_r0_body.s423, PRE_first_tail_x15_r0_body.S423)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA126 from PRE_first_tail_x15_r0_body.s424 to PRE_first_tail_x15_r0_body.s425 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s424).run PRE_first_tail_x15_r0_body.S424 = some (PRE_first_tail_x15_r0_body.s425, PRE_first_tail_x15_r0_body.S425)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB126 from PRE_first_tail_x15_r0_body.s425 to PRE_first_tail_x15_r0_body.s426 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s425).run PRE_first_tail_x15_r0_body.S425 = some (PRE_first_tail_x15_r0_body.s426, PRE_first_tail_x15_r0_body.S426)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA127 from PRE_first_tail_x15_r0_body.s427 to PRE_first_tail_x15_r0_body.s428 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s427).run PRE_first_tail_x15_r0_body.S427 = some (PRE_first_tail_x15_r0_body.s428, PRE_first_tail_x15_r0_body.S428)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB127 from PRE_first_tail_x15_r0_body.s428 to PRE_first_tail_x15_r0_body.s429 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s428).run PRE_first_tail_x15_r0_body.S428 = some (PRE_first_tail_x15_r0_body.s429, PRE_first_tail_x15_r0_body.S429)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA128 from PRE_first_tail_x15_r0_body.s430 to PRE_first_tail_x15_r0_body.s431 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s430).run PRE_first_tail_x15_r0_body.S430 = some (PRE_first_tail_x15_r0_body.s431, PRE_first_tail_x15_r0_body.S431)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB128 from PRE_first_tail_x15_r0_body.s431 to PRE_first_tail_x15_r0_body.s432 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s431).run PRE_first_tail_x15_r0_body.S431 = some (PRE_first_tail_x15_r0_body.s432, PRE_first_tail_x15_r0_body.S432)
end Host.Load.Run.Tpl
