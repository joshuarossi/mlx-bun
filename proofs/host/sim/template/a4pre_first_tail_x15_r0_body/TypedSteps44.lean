import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA219 from PRE_first_tail_x15_r0_body.s811 to PRE_first_tail_x15_r0_body.s812 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s811).run PRE_first_tail_x15_r0_body.S811 = some (PRE_first_tail_x15_r0_body.s812, PRE_first_tail_x15_r0_body.S812)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB219 from PRE_first_tail_x15_r0_body.s812 to PRE_first_tail_x15_r0_body.s813 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s812).run PRE_first_tail_x15_r0_body.S812 = some (PRE_first_tail_x15_r0_body.s813, PRE_first_tail_x15_r0_body.S813)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA220 from PRE_first_tail_x15_r0_body.s814 to PRE_first_tail_x15_r0_body.s815 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s814).run PRE_first_tail_x15_r0_body.S814 = some (PRE_first_tail_x15_r0_body.s815, PRE_first_tail_x15_r0_body.S815)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB220 from PRE_first_tail_x15_r0_body.s815 to PRE_first_tail_x15_r0_body.s816 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s815).run PRE_first_tail_x15_r0_body.S815 = some (PRE_first_tail_x15_r0_body.s816, PRE_first_tail_x15_r0_body.S816)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA221 from PRE_first_tail_x15_r0_body.s817 to PRE_first_tail_x15_r0_body.s818 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s817).run PRE_first_tail_x15_r0_body.S817 = some (PRE_first_tail_x15_r0_body.s818, PRE_first_tail_x15_r0_body.S818)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB221 from PRE_first_tail_x15_r0_body.s818 to PRE_first_tail_x15_r0_body.s819 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s818).run PRE_first_tail_x15_r0_body.S818 = some (PRE_first_tail_x15_r0_body.s819, PRE_first_tail_x15_r0_body.S819)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA222 from PRE_first_tail_x15_r0_body.s820 to PRE_first_tail_x15_r0_body.s821 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s820).run PRE_first_tail_x15_r0_body.S820 = some (PRE_first_tail_x15_r0_body.s821, PRE_first_tail_x15_r0_body.S821)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA223 from PRE_first_tail_x15_r0_body.s824 to PRE_first_tail_x15_r0_body.s825 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s824).run PRE_first_tail_x15_r0_body.S824 = some (PRE_first_tail_x15_r0_body.s825, PRE_first_tail_x15_r0_body.S825)
end Host.Load.Run.Tpl
