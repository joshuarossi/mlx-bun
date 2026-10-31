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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA65 from PRE_first_tail_x15_r0_body.s217 to PRE_first_tail_x15_r0_body.s218 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s217).run PRE_first_tail_x15_r0_body.S217 = some (PRE_first_tail_x15_r0_body.s218, PRE_first_tail_x15_r0_body.S218)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB65 from PRE_first_tail_x15_r0_body.s218 to PRE_first_tail_x15_r0_body.s219 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s218).run PRE_first_tail_x15_r0_body.S218 = some (PRE_first_tail_x15_r0_body.s219, PRE_first_tail_x15_r0_body.S219)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA66 from PRE_first_tail_x15_r0_body.s220 to PRE_first_tail_x15_r0_body.s221 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s220).run PRE_first_tail_x15_r0_body.S220 = some (PRE_first_tail_x15_r0_body.s221, PRE_first_tail_x15_r0_body.S221)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB66 from PRE_first_tail_x15_r0_body.s221 to PRE_first_tail_x15_r0_body.s222 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s221).run PRE_first_tail_x15_r0_body.S221 = some (PRE_first_tail_x15_r0_body.s222, PRE_first_tail_x15_r0_body.S222)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA67 from PRE_first_tail_x15_r0_body.s223 to PRE_first_tail_x15_r0_body.s224 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s223).run PRE_first_tail_x15_r0_body.S223 = some (PRE_first_tail_x15_r0_body.s224, PRE_first_tail_x15_r0_body.S224)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA68 from PRE_first_tail_x15_r0_body.s227 to PRE_first_tail_x15_r0_body.s228 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s227).run PRE_first_tail_x15_r0_body.S227 = some (PRE_first_tail_x15_r0_body.s228, PRE_first_tail_x15_r0_body.S228)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB68 from PRE_first_tail_x15_r0_body.s228 to PRE_first_tail_x15_r0_body.s229 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s228).run PRE_first_tail_x15_r0_body.S228 = some (PRE_first_tail_x15_r0_body.s229, PRE_first_tail_x15_r0_body.S229)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA69 from PRE_first_tail_x15_r0_body.s230 to PRE_first_tail_x15_r0_body.s231 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s230).run PRE_first_tail_x15_r0_body.S230 = some (PRE_first_tail_x15_r0_body.s231, PRE_first_tail_x15_r0_body.S231)
end Host.Load.Run.Tpl
