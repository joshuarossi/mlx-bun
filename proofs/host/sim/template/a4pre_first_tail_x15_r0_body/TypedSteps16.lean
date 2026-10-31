import host.sim.template.a4pre_first_tail_x15_r0_body.H8
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA80 from PRE_first_tail_x15_r0_body.s268 to PRE_first_tail_x15_r0_body.s269 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s268).run PRE_first_tail_x15_r0_body.S268 = some (PRE_first_tail_x15_r0_body.s269, PRE_first_tail_x15_r0_body.S269)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB80 from PRE_first_tail_x15_r0_body.s269 to PRE_first_tail_x15_r0_body.s270 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s269).run PRE_first_tail_x15_r0_body.S269 = some (PRE_first_tail_x15_r0_body.s270, PRE_first_tail_x15_r0_body.S270)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA81 from PRE_first_tail_x15_r0_body.s271 to PRE_first_tail_x15_r0_body.s272 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s271).run PRE_first_tail_x15_r0_body.S271 = some (PRE_first_tail_x15_r0_body.s272, PRE_first_tail_x15_r0_body.S272)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB81 from PRE_first_tail_x15_r0_body.s272 to PRE_first_tail_x15_r0_body.s273 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s272).run PRE_first_tail_x15_r0_body.S272 = some (PRE_first_tail_x15_r0_body.s273, PRE_first_tail_x15_r0_body.S273)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA82 from PRE_first_tail_x15_r0_body.s274 to PRE_first_tail_x15_r0_body.s275 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s274).run PRE_first_tail_x15_r0_body.S274 = some (PRE_first_tail_x15_r0_body.s275, PRE_first_tail_x15_r0_body.S275)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB82 from PRE_first_tail_x15_r0_body.s275 to PRE_first_tail_x15_r0_body.s276 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s275).run PRE_first_tail_x15_r0_body.S275 = some (PRE_first_tail_x15_r0_body.s276, PRE_first_tail_x15_r0_body.S276)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA83 from PRE_first_tail_x15_r0_body.s277 to PRE_first_tail_x15_r0_body.s278 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s277).run PRE_first_tail_x15_r0_body.S277 = some (PRE_first_tail_x15_r0_body.s278, PRE_first_tail_x15_r0_body.S278)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA84 from PRE_first_tail_x15_r0_body.s281 to PRE_first_tail_x15_r0_body.s282 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s281).run PRE_first_tail_x15_r0_body.S281 = some (PRE_first_tail_x15_r0_body.s282, PRE_first_tail_x15_r0_body.S282)
end Host.Load.Run.Tpl
