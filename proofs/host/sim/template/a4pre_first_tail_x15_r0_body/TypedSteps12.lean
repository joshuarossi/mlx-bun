import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA60 from PRE_first_tail_x15_r0_body.s200 to PRE_first_tail_x15_r0_body.s201 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s200).run PRE_first_tail_x15_r0_body.S200 = some (PRE_first_tail_x15_r0_body.s201, PRE_first_tail_x15_r0_body.S201)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB60 from PRE_first_tail_x15_r0_body.s201 to PRE_first_tail_x15_r0_body.s202 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s201).run PRE_first_tail_x15_r0_body.S201 = some (PRE_first_tail_x15_r0_body.s202, PRE_first_tail_x15_r0_body.S202)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA61 from PRE_first_tail_x15_r0_body.s203 to PRE_first_tail_x15_r0_body.s204 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s203).run PRE_first_tail_x15_r0_body.S203 = some (PRE_first_tail_x15_r0_body.s204, PRE_first_tail_x15_r0_body.S204)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA62 from PRE_first_tail_x15_r0_body.s207 to PRE_first_tail_x15_r0_body.s208 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s207).run PRE_first_tail_x15_r0_body.S207 = some (PRE_first_tail_x15_r0_body.s208, PRE_first_tail_x15_r0_body.S208)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA63 from PRE_first_tail_x15_r0_body.s211 to PRE_first_tail_x15_r0_body.s212 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s211).run PRE_first_tail_x15_r0_body.S211 = some (PRE_first_tail_x15_r0_body.s212, PRE_first_tail_x15_r0_body.S212)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB63 from PRE_first_tail_x15_r0_body.s212 to PRE_first_tail_x15_r0_body.s213 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s212).run PRE_first_tail_x15_r0_body.S212 = some (PRE_first_tail_x15_r0_body.s213, PRE_first_tail_x15_r0_body.S213)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA64 from PRE_first_tail_x15_r0_body.s214 to PRE_first_tail_x15_r0_body.s215 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s214).run PRE_first_tail_x15_r0_body.S214 = some (PRE_first_tail_x15_r0_body.s215, PRE_first_tail_x15_r0_body.S215)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB64 from PRE_first_tail_x15_r0_body.s215 to PRE_first_tail_x15_r0_body.s216 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s215).run PRE_first_tail_x15_r0_body.S215 = some (PRE_first_tail_x15_r0_body.s216, PRE_first_tail_x15_r0_body.S216)
end Host.Load.Run.Tpl
