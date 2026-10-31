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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA238 from PRE_first_tail_x15_r0_body.s878 to PRE_first_tail_x15_r0_body.s879 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s878).run PRE_first_tail_x15_r0_body.S878 = some (PRE_first_tail_x15_r0_body.s879, PRE_first_tail_x15_r0_body.S879)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA239 from PRE_first_tail_x15_r0_body.s882 to PRE_first_tail_x15_r0_body.s883 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s882).run PRE_first_tail_x15_r0_body.S882 = some (PRE_first_tail_x15_r0_body.s883, PRE_first_tail_x15_r0_body.S883)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB239 from PRE_first_tail_x15_r0_body.s883 to PRE_first_tail_x15_r0_body.s884 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s883).run PRE_first_tail_x15_r0_body.S883 = some (PRE_first_tail_x15_r0_body.s884, PRE_first_tail_x15_r0_body.S884)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA240 from PRE_first_tail_x15_r0_body.s886 to PRE_first_tail_x15_r0_body.s887 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s886).run PRE_first_tail_x15_r0_body.S886 = some (PRE_first_tail_x15_r0_body.s887, PRE_first_tail_x15_r0_body.S887)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA241 from PRE_first_tail_x15_r0_body.s890 to PRE_first_tail_x15_r0_body.s891 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s890).run PRE_first_tail_x15_r0_body.S890 = some (PRE_first_tail_x15_r0_body.s891, PRE_first_tail_x15_r0_body.S891)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA242 from PRE_first_tail_x15_r0_body.s895 to PRE_first_tail_x15_r0_body.s896 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s895).run PRE_first_tail_x15_r0_body.S895 = some (PRE_first_tail_x15_r0_body.s896, PRE_first_tail_x15_r0_body.S896)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB242 from PRE_first_tail_x15_r0_body.s896 to PRE_first_tail_x15_r0_body.s897 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s896).run PRE_first_tail_x15_r0_body.S896 = some (PRE_first_tail_x15_r0_body.s897, PRE_first_tail_x15_r0_body.S897)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA243 from PRE_first_tail_x15_r0_body.s899 to PRE_first_tail_x15_r0_body.s900 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s899).run PRE_first_tail_x15_r0_body.S899 = some (PRE_first_tail_x15_r0_body.s900, PRE_first_tail_x15_r0_body.S900)
end Host.Load.Run.Tpl
