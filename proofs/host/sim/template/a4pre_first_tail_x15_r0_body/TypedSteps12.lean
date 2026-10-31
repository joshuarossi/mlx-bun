import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA60 from PRE_first_tail_x15_r0_body.s220 to PRE_first_tail_x15_r0_body.s221 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s220).run PRE_first_tail_x15_r0_body.S220 = some (PRE_first_tail_x15_r0_body.s221, PRE_first_tail_x15_r0_body.S221)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB60 from PRE_first_tail_x15_r0_body.s221 to PRE_first_tail_x15_r0_body.s222 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s221).run PRE_first_tail_x15_r0_body.S221 = some (PRE_first_tail_x15_r0_body.s222, PRE_first_tail_x15_r0_body.S222)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA61 from PRE_first_tail_x15_r0_body.s224 to PRE_first_tail_x15_r0_body.s225 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s224).run PRE_first_tail_x15_r0_body.S224 = some (PRE_first_tail_x15_r0_body.s225, PRE_first_tail_x15_r0_body.S225)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA62 from PRE_first_tail_x15_r0_body.s228 to PRE_first_tail_x15_r0_body.s229 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s228).run PRE_first_tail_x15_r0_body.S228 = some (PRE_first_tail_x15_r0_body.s229, PRE_first_tail_x15_r0_body.S229)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA63 from PRE_first_tail_x15_r0_body.s233 to PRE_first_tail_x15_r0_body.s234 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s233).run PRE_first_tail_x15_r0_body.S233 = some (PRE_first_tail_x15_r0_body.s234, PRE_first_tail_x15_r0_body.S234)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB63 from PRE_first_tail_x15_r0_body.s234 to PRE_first_tail_x15_r0_body.s235 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s234).run PRE_first_tail_x15_r0_body.S234 = some (PRE_first_tail_x15_r0_body.s235, PRE_first_tail_x15_r0_body.S235)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA64 from PRE_first_tail_x15_r0_body.s236 to PRE_first_tail_x15_r0_body.s237 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s236).run PRE_first_tail_x15_r0_body.S236 = some (PRE_first_tail_x15_r0_body.s237, PRE_first_tail_x15_r0_body.S237)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB64 from PRE_first_tail_x15_r0_body.s237 to PRE_first_tail_x15_r0_body.s238 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s237).run PRE_first_tail_x15_r0_body.S237 = some (PRE_first_tail_x15_r0_body.s238, PRE_first_tail_x15_r0_body.S238)
end Host.Load.Run.Tpl
