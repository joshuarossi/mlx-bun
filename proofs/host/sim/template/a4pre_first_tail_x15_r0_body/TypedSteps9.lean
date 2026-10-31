import host.sim.template.a4pre_first_tail_x15_r0_body.H4
import host.sim.template.a4pre_first_tail_x15_r0_body.H5
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA45 from PRE_first_tail_x15_r0_body.s149 to PRE_first_tail_x15_r0_body.s150 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s149).run PRE_first_tail_x15_r0_body.S149 = some (PRE_first_tail_x15_r0_body.s150, PRE_first_tail_x15_r0_body.S150)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB45 from PRE_first_tail_x15_r0_body.s150 to PRE_first_tail_x15_r0_body.s151 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s150).run PRE_first_tail_x15_r0_body.S150 = some (PRE_first_tail_x15_r0_body.s151, PRE_first_tail_x15_r0_body.S151)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA46 from PRE_first_tail_x15_r0_body.s152 to PRE_first_tail_x15_r0_body.s153 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s152).run PRE_first_tail_x15_r0_body.S152 = some (PRE_first_tail_x15_r0_body.s153, PRE_first_tail_x15_r0_body.S153)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA47 from PRE_first_tail_x15_r0_body.s156 to PRE_first_tail_x15_r0_body.s157 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s156).run PRE_first_tail_x15_r0_body.S156 = some (PRE_first_tail_x15_r0_body.s157, PRE_first_tail_x15_r0_body.S157)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA48 from PRE_first_tail_x15_r0_body.s160 to PRE_first_tail_x15_r0_body.s161 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s160).run PRE_first_tail_x15_r0_body.S160 = some (PRE_first_tail_x15_r0_body.s161, PRE_first_tail_x15_r0_body.S161)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB48 from PRE_first_tail_x15_r0_body.s161 to PRE_first_tail_x15_r0_body.s162 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s161).run PRE_first_tail_x15_r0_body.S161 = some (PRE_first_tail_x15_r0_body.s162, PRE_first_tail_x15_r0_body.S162)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA49 from PRE_first_tail_x15_r0_body.s163 to PRE_first_tail_x15_r0_body.s164 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s163).run PRE_first_tail_x15_r0_body.S163 = some (PRE_first_tail_x15_r0_body.s164, PRE_first_tail_x15_r0_body.S164)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB49 from PRE_first_tail_x15_r0_body.s164 to PRE_first_tail_x15_r0_body.s165 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s164).run PRE_first_tail_x15_r0_body.S164 = some (PRE_first_tail_x15_r0_body.s165, PRE_first_tail_x15_r0_body.S165)
end Host.Load.Run.Tpl
