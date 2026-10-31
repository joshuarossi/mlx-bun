import host.sim.template.a4pre_first_tail_x15_r0_body.H8
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA70 from PRE_first_tail_x15_r0_body.s257 to PRE_first_tail_x15_r0_body.s258 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s257).run PRE_first_tail_x15_r0_body.S257 = some (PRE_first_tail_x15_r0_body.s258, PRE_first_tail_x15_r0_body.S258)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA71 from PRE_first_tail_x15_r0_body.s262 to PRE_first_tail_x15_r0_body.s263 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s262).run PRE_first_tail_x15_r0_body.S262 = some (PRE_first_tail_x15_r0_body.s263, PRE_first_tail_x15_r0_body.S263)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB71 from PRE_first_tail_x15_r0_body.s263 to PRE_first_tail_x15_r0_body.s264 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s263).run PRE_first_tail_x15_r0_body.S263 = some (PRE_first_tail_x15_r0_body.s264, PRE_first_tail_x15_r0_body.S264)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA72 from PRE_first_tail_x15_r0_body.s265 to PRE_first_tail_x15_r0_body.s266 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s265).run PRE_first_tail_x15_r0_body.S265 = some (PRE_first_tail_x15_r0_body.s266, PRE_first_tail_x15_r0_body.S266)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB72 from PRE_first_tail_x15_r0_body.s266 to PRE_first_tail_x15_r0_body.s267 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s266).run PRE_first_tail_x15_r0_body.S266 = some (PRE_first_tail_x15_r0_body.s267, PRE_first_tail_x15_r0_body.S267)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA73 from PRE_first_tail_x15_r0_body.s268 to PRE_first_tail_x15_r0_body.s269 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s268).run PRE_first_tail_x15_r0_body.S268 = some (PRE_first_tail_x15_r0_body.s269, PRE_first_tail_x15_r0_body.S269)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB73 from PRE_first_tail_x15_r0_body.s269 to PRE_first_tail_x15_r0_body.s270 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s269).run PRE_first_tail_x15_r0_body.S269 = some (PRE_first_tail_x15_r0_body.s270, PRE_first_tail_x15_r0_body.S270)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA74 from PRE_first_tail_x15_r0_body.s271 to PRE_first_tail_x15_r0_body.s272 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s271).run PRE_first_tail_x15_r0_body.S271 = some (PRE_first_tail_x15_r0_body.s272, PRE_first_tail_x15_r0_body.S272)
end Host.Load.Run.Tpl
