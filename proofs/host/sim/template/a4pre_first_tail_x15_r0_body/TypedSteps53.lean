import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.H28
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA263 from PRE_first_tail_x15_r0_body.s887 to PRE_first_tail_x15_r0_body.s888 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s887).run PRE_first_tail_x15_r0_body.S887 = some (PRE_first_tail_x15_r0_body.s888, PRE_first_tail_x15_r0_body.S888)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA264 from PRE_first_tail_x15_r0_body.s891 to PRE_first_tail_x15_r0_body.s892 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s891).run PRE_first_tail_x15_r0_body.S891 = some (PRE_first_tail_x15_r0_body.s892, PRE_first_tail_x15_r0_body.S892)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA265 from PRE_first_tail_x15_r0_body.s895 to PRE_first_tail_x15_r0_body.s896 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s895).run PRE_first_tail_x15_r0_body.S895 = some (PRE_first_tail_x15_r0_body.s896, PRE_first_tail_x15_r0_body.S896)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB265 from PRE_first_tail_x15_r0_body.s896 to PRE_first_tail_x15_r0_body.s897 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s896).run PRE_first_tail_x15_r0_body.S896 = some (PRE_first_tail_x15_r0_body.s897, PRE_first_tail_x15_r0_body.S897)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA266 from PRE_first_tail_x15_r0_body.s898 to PRE_first_tail_x15_r0_body.s899 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s898).run PRE_first_tail_x15_r0_body.S898 = some (PRE_first_tail_x15_r0_body.s899, PRE_first_tail_x15_r0_body.S899)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB266 from PRE_first_tail_x15_r0_body.s899 to PRE_first_tail_x15_r0_body.s900 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s899).run PRE_first_tail_x15_r0_body.S899 = some (PRE_first_tail_x15_r0_body.s900, PRE_first_tail_x15_r0_body.S900)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA267 from PRE_first_tail_x15_r0_body.s901 to PRE_first_tail_x15_r0_body.s902 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s901).run PRE_first_tail_x15_r0_body.S901 = some (PRE_first_tail_x15_r0_body.s902, PRE_first_tail_x15_r0_body.S902)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB267 from PRE_first_tail_x15_r0_body.s902 to PRE_first_tail_x15_r0_body.s903 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s902).run PRE_first_tail_x15_r0_body.S902 = some (PRE_first_tail_x15_r0_body.s903, PRE_first_tail_x15_r0_body.S903)
end Host.Load.Run.Tpl
