import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.a4pre_first_tail_x15_r0_body.H4
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA35 from PRE_first_tail_x15_r0_body.s127 to PRE_first_tail_x15_r0_body.s128 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s127).run PRE_first_tail_x15_r0_body.S127 = some (PRE_first_tail_x15_r0_body.s128, PRE_first_tail_x15_r0_body.S128)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB35 from PRE_first_tail_x15_r0_body.s128 to PRE_first_tail_x15_r0_body.s129 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s128).run PRE_first_tail_x15_r0_body.S128 = some (PRE_first_tail_x15_r0_body.s129, PRE_first_tail_x15_r0_body.S129)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA36 from PRE_first_tail_x15_r0_body.s130 to PRE_first_tail_x15_r0_body.s131 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s130).run PRE_first_tail_x15_r0_body.S130 = some (PRE_first_tail_x15_r0_body.s131, PRE_first_tail_x15_r0_body.S131)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA37 from PRE_first_tail_x15_r0_body.s134 to PRE_first_tail_x15_r0_body.s135 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s134).run PRE_first_tail_x15_r0_body.S134 = some (PRE_first_tail_x15_r0_body.s135, PRE_first_tail_x15_r0_body.S135)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB37 from PRE_first_tail_x15_r0_body.s135 to PRE_first_tail_x15_r0_body.s136 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s135).run PRE_first_tail_x15_r0_body.S135 = some (PRE_first_tail_x15_r0_body.s136, PRE_first_tail_x15_r0_body.S136)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA38 from PRE_first_tail_x15_r0_body.s138 to PRE_first_tail_x15_r0_body.s139 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s138).run PRE_first_tail_x15_r0_body.S138 = some (PRE_first_tail_x15_r0_body.s139, PRE_first_tail_x15_r0_body.S139)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA39 from PRE_first_tail_x15_r0_body.s142 to PRE_first_tail_x15_r0_body.s143 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s142).run PRE_first_tail_x15_r0_body.S142 = some (PRE_first_tail_x15_r0_body.s143, PRE_first_tail_x15_r0_body.S143)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA40 from PRE_first_tail_x15_r0_body.s147 to PRE_first_tail_x15_r0_body.s148 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s147).run PRE_first_tail_x15_r0_body.S147 = some (PRE_first_tail_x15_r0_body.s148, PRE_first_tail_x15_r0_body.S148)
end Host.Load.Run.Tpl
