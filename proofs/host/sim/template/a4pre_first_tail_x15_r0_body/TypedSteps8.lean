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
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB40 from PRE_first_tail_x15_r0_body.s148 to PRE_first_tail_x15_r0_body.s149 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s148).run PRE_first_tail_x15_r0_body.S148 = some (PRE_first_tail_x15_r0_body.s149, PRE_first_tail_x15_r0_body.S149)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA41 from PRE_first_tail_x15_r0_body.s150 to PRE_first_tail_x15_r0_body.s151 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s150).run PRE_first_tail_x15_r0_body.S150 = some (PRE_first_tail_x15_r0_body.s151, PRE_first_tail_x15_r0_body.S151)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB41 from PRE_first_tail_x15_r0_body.s151 to PRE_first_tail_x15_r0_body.s152 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s151).run PRE_first_tail_x15_r0_body.S151 = some (PRE_first_tail_x15_r0_body.s152, PRE_first_tail_x15_r0_body.S152)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA42 from PRE_first_tail_x15_r0_body.s153 to PRE_first_tail_x15_r0_body.s154 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s153).run PRE_first_tail_x15_r0_body.S153 = some (PRE_first_tail_x15_r0_body.s154, PRE_first_tail_x15_r0_body.S154)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB42 from PRE_first_tail_x15_r0_body.s154 to PRE_first_tail_x15_r0_body.s155 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s154).run PRE_first_tail_x15_r0_body.S154 = some (PRE_first_tail_x15_r0_body.s155, PRE_first_tail_x15_r0_body.S155)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA43 from PRE_first_tail_x15_r0_body.s156 to PRE_first_tail_x15_r0_body.s157 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s156).run PRE_first_tail_x15_r0_body.S156 = some (PRE_first_tail_x15_r0_body.s157, PRE_first_tail_x15_r0_body.S157)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB43 from PRE_first_tail_x15_r0_body.s157 to PRE_first_tail_x15_r0_body.s158 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s157).run PRE_first_tail_x15_r0_body.S157 = some (PRE_first_tail_x15_r0_body.s158, PRE_first_tail_x15_r0_body.S158)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA44 from PRE_first_tail_x15_r0_body.s159 to PRE_first_tail_x15_r0_body.s160 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s159).run PRE_first_tail_x15_r0_body.S159 = some (PRE_first_tail_x15_r0_body.s160, PRE_first_tail_x15_r0_body.S160)
end Host.Load.Run.Tpl
