import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA55 from PRE_first_tail_x15_r0_body.s200 to PRE_first_tail_x15_r0_body.s201 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s200).run PRE_first_tail_x15_r0_body.S200 = some (PRE_first_tail_x15_r0_body.s201, PRE_first_tail_x15_r0_body.S201)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA56 from PRE_first_tail_x15_r0_body.s205 to PRE_first_tail_x15_r0_body.s206 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s205).run PRE_first_tail_x15_r0_body.S205 = some (PRE_first_tail_x15_r0_body.s206, PRE_first_tail_x15_r0_body.S206)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB56 from PRE_first_tail_x15_r0_body.s206 to PRE_first_tail_x15_r0_body.s207 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s206).run PRE_first_tail_x15_r0_body.S206 = some (PRE_first_tail_x15_r0_body.s207, PRE_first_tail_x15_r0_body.S207)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA57 from PRE_first_tail_x15_r0_body.s209 to PRE_first_tail_x15_r0_body.s210 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s209).run PRE_first_tail_x15_r0_body.S209 = some (PRE_first_tail_x15_r0_body.s210, PRE_first_tail_x15_r0_body.S210)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB57 from PRE_first_tail_x15_r0_body.s210 to PRE_first_tail_x15_r0_body.s211 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s210).run PRE_first_tail_x15_r0_body.S210 = some (PRE_first_tail_x15_r0_body.s211, PRE_first_tail_x15_r0_body.S211)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA58 from PRE_first_tail_x15_r0_body.s212 to PRE_first_tail_x15_r0_body.s213 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s212).run PRE_first_tail_x15_r0_body.S212 = some (PRE_first_tail_x15_r0_body.s213, PRE_first_tail_x15_r0_body.S213)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB58 from PRE_first_tail_x15_r0_body.s213 to PRE_first_tail_x15_r0_body.s214 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s213).run PRE_first_tail_x15_r0_body.S213 = some (PRE_first_tail_x15_r0_body.s214, PRE_first_tail_x15_r0_body.S214)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA59 from PRE_first_tail_x15_r0_body.s216 to PRE_first_tail_x15_r0_body.s217 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s216).run PRE_first_tail_x15_r0_body.S216 = some (PRE_first_tail_x15_r0_body.s217, PRE_first_tail_x15_r0_body.S217)
end Host.Load.Run.Tpl
