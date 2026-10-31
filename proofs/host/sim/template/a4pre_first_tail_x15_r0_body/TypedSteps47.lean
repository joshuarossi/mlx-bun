import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA234 from PRE_first_tail_x15_r0_body.s866 to PRE_first_tail_x15_r0_body.s867 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s866).run PRE_first_tail_x15_r0_body.S866 = some (PRE_first_tail_x15_r0_body.s867, PRE_first_tail_x15_r0_body.S867)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB234 from PRE_first_tail_x15_r0_body.s867 to PRE_first_tail_x15_r0_body.s868 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s867).run PRE_first_tail_x15_r0_body.S867 = some (PRE_first_tail_x15_r0_body.s868, PRE_first_tail_x15_r0_body.S868)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA235 from PRE_first_tail_x15_r0_body.s869 to PRE_first_tail_x15_r0_body.s870 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s869).run PRE_first_tail_x15_r0_body.S869 = some (PRE_first_tail_x15_r0_body.s870, PRE_first_tail_x15_r0_body.S870)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB235 from PRE_first_tail_x15_r0_body.s870 to PRE_first_tail_x15_r0_body.s871 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s870).run PRE_first_tail_x15_r0_body.S870 = some (PRE_first_tail_x15_r0_body.s871, PRE_first_tail_x15_r0_body.S871)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA236 from PRE_first_tail_x15_r0_body.s872 to PRE_first_tail_x15_r0_body.s873 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s872).run PRE_first_tail_x15_r0_body.S872 = some (PRE_first_tail_x15_r0_body.s873, PRE_first_tail_x15_r0_body.S873)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB236 from PRE_first_tail_x15_r0_body.s873 to PRE_first_tail_x15_r0_body.s874 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s873).run PRE_first_tail_x15_r0_body.S873 = some (PRE_first_tail_x15_r0_body.s874, PRE_first_tail_x15_r0_body.S874)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA237 from PRE_first_tail_x15_r0_body.s875 to PRE_first_tail_x15_r0_body.s876 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s875).run PRE_first_tail_x15_r0_body.S875 = some (PRE_first_tail_x15_r0_body.s876, PRE_first_tail_x15_r0_body.S876)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB237 from PRE_first_tail_x15_r0_body.s876 to PRE_first_tail_x15_r0_body.s877 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s876).run PRE_first_tail_x15_r0_body.S876 = some (PRE_first_tail_x15_r0_body.s877, PRE_first_tail_x15_r0_body.S877)
end Host.Load.Run.Tpl
