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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA35 from PRE_first_tail_x15_r0_body.s115 to PRE_first_tail_x15_r0_body.s116 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s115).run PRE_first_tail_x15_r0_body.S115 = some (PRE_first_tail_x15_r0_body.s116, PRE_first_tail_x15_r0_body.S116)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB35 from PRE_first_tail_x15_r0_body.s116 to PRE_first_tail_x15_r0_body.s117 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s116).run PRE_first_tail_x15_r0_body.S116 = some (PRE_first_tail_x15_r0_body.s117, PRE_first_tail_x15_r0_body.S117)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA36 from PRE_first_tail_x15_r0_body.s118 to PRE_first_tail_x15_r0_body.s119 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s118).run PRE_first_tail_x15_r0_body.S118 = some (PRE_first_tail_x15_r0_body.s119, PRE_first_tail_x15_r0_body.S119)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA37 from PRE_first_tail_x15_r0_body.s122 to PRE_first_tail_x15_r0_body.s123 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s122).run PRE_first_tail_x15_r0_body.S122 = some (PRE_first_tail_x15_r0_body.s123, PRE_first_tail_x15_r0_body.S123)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB37 from PRE_first_tail_x15_r0_body.s123 to PRE_first_tail_x15_r0_body.s124 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s123).run PRE_first_tail_x15_r0_body.S123 = some (PRE_first_tail_x15_r0_body.s124, PRE_first_tail_x15_r0_body.S124)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA38 from PRE_first_tail_x15_r0_body.s125 to PRE_first_tail_x15_r0_body.s126 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s125).run PRE_first_tail_x15_r0_body.S125 = some (PRE_first_tail_x15_r0_body.s126, PRE_first_tail_x15_r0_body.S126)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA39 from PRE_first_tail_x15_r0_body.s129 to PRE_first_tail_x15_r0_body.s130 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s129).run PRE_first_tail_x15_r0_body.S129 = some (PRE_first_tail_x15_r0_body.s130, PRE_first_tail_x15_r0_body.S130)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA40 from PRE_first_tail_x15_r0_body.s133 to PRE_first_tail_x15_r0_body.s134 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s133).run PRE_first_tail_x15_r0_body.S133 = some (PRE_first_tail_x15_r0_body.s134, PRE_first_tail_x15_r0_body.S134)
end Host.Load.Run.Tpl
