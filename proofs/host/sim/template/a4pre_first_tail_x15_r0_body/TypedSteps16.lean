import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA80 from PRE_first_tail_x15_r0_body.s294 to PRE_first_tail_x15_r0_body.s295 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s294).run PRE_first_tail_x15_r0_body.S294 = some (PRE_first_tail_x15_r0_body.s295, PRE_first_tail_x15_r0_body.S295)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB80 from PRE_first_tail_x15_r0_body.s295 to PRE_first_tail_x15_r0_body.s296 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s295).run PRE_first_tail_x15_r0_body.S295 = some (PRE_first_tail_x15_r0_body.s296, PRE_first_tail_x15_r0_body.S296)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA81 from PRE_first_tail_x15_r0_body.s297 to PRE_first_tail_x15_r0_body.s298 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s297).run PRE_first_tail_x15_r0_body.S297 = some (PRE_first_tail_x15_r0_body.s298, PRE_first_tail_x15_r0_body.S298)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB81 from PRE_first_tail_x15_r0_body.s298 to PRE_first_tail_x15_r0_body.s299 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s298).run PRE_first_tail_x15_r0_body.S298 = some (PRE_first_tail_x15_r0_body.s299, PRE_first_tail_x15_r0_body.S299)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA82 from PRE_first_tail_x15_r0_body.s300 to PRE_first_tail_x15_r0_body.s301 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s300).run PRE_first_tail_x15_r0_body.S300 = some (PRE_first_tail_x15_r0_body.s301, PRE_first_tail_x15_r0_body.S301)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB82 from PRE_first_tail_x15_r0_body.s301 to PRE_first_tail_x15_r0_body.s302 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s301).run PRE_first_tail_x15_r0_body.S301 = some (PRE_first_tail_x15_r0_body.s302, PRE_first_tail_x15_r0_body.S302)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA83 from PRE_first_tail_x15_r0_body.s303 to PRE_first_tail_x15_r0_body.s304 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s303).run PRE_first_tail_x15_r0_body.S303 = some (PRE_first_tail_x15_r0_body.s304, PRE_first_tail_x15_r0_body.S304)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA84 from PRE_first_tail_x15_r0_body.s307 to PRE_first_tail_x15_r0_body.s308 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s307).run PRE_first_tail_x15_r0_body.S307 = some (PRE_first_tail_x15_r0_body.s308, PRE_first_tail_x15_r0_body.S308)
end Host.Load.Run.Tpl
