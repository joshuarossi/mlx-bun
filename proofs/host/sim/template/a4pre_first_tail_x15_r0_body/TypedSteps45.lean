import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.a4pre_first_tail_x15_r0_body.H26
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB223 from PRE_first_tail_x15_r0_body.s825 to PRE_first_tail_x15_r0_body.s826 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s825).run PRE_first_tail_x15_r0_body.S825 = some (PRE_first_tail_x15_r0_body.s826, PRE_first_tail_x15_r0_body.S826)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA224 from PRE_first_tail_x15_r0_body.s828 to PRE_first_tail_x15_r0_body.s829 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s828).run PRE_first_tail_x15_r0_body.S828 = some (PRE_first_tail_x15_r0_body.s829, PRE_first_tail_x15_r0_body.S829)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA225 from PRE_first_tail_x15_r0_body.s832 to PRE_first_tail_x15_r0_body.s833 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s832).run PRE_first_tail_x15_r0_body.S832 = some (PRE_first_tail_x15_r0_body.s833, PRE_first_tail_x15_r0_body.S833)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA226 from PRE_first_tail_x15_r0_body.s837 to PRE_first_tail_x15_r0_body.s838 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s837).run PRE_first_tail_x15_r0_body.S837 = some (PRE_first_tail_x15_r0_body.s838, PRE_first_tail_x15_r0_body.S838)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB226 from PRE_first_tail_x15_r0_body.s838 to PRE_first_tail_x15_r0_body.s839 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s838).run PRE_first_tail_x15_r0_body.S838 = some (PRE_first_tail_x15_r0_body.s839, PRE_first_tail_x15_r0_body.S839)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA227 from PRE_first_tail_x15_r0_body.s840 to PRE_first_tail_x15_r0_body.s841 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s840).run PRE_first_tail_x15_r0_body.S840 = some (PRE_first_tail_x15_r0_body.s841, PRE_first_tail_x15_r0_body.S841)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB227 from PRE_first_tail_x15_r0_body.s841 to PRE_first_tail_x15_r0_body.s842 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s841).run PRE_first_tail_x15_r0_body.S841 = some (PRE_first_tail_x15_r0_body.s842, PRE_first_tail_x15_r0_body.S842)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA228 from PRE_first_tail_x15_r0_body.s843 to PRE_first_tail_x15_r0_body.s844 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s843).run PRE_first_tail_x15_r0_body.S843 = some (PRE_first_tail_x15_r0_body.s844, PRE_first_tail_x15_r0_body.S844)
end Host.Load.Run.Tpl
