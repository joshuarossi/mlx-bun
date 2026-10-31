import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA238 from PRE_first_tail_x15_r0_body.s802 to PRE_first_tail_x15_r0_body.s803 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s802).run PRE_first_tail_x15_r0_body.S802 = some (PRE_first_tail_x15_r0_body.s803, PRE_first_tail_x15_r0_body.S803)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA239 from PRE_first_tail_x15_r0_body.s806 to PRE_first_tail_x15_r0_body.s807 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s806).run PRE_first_tail_x15_r0_body.S806 = some (PRE_first_tail_x15_r0_body.s807, PRE_first_tail_x15_r0_body.S807)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB239 from PRE_first_tail_x15_r0_body.s807 to PRE_first_tail_x15_r0_body.s808 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s807).run PRE_first_tail_x15_r0_body.S807 = some (PRE_first_tail_x15_r0_body.s808, PRE_first_tail_x15_r0_body.S808)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA240 from PRE_first_tail_x15_r0_body.s809 to PRE_first_tail_x15_r0_body.s810 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s809).run PRE_first_tail_x15_r0_body.S809 = some (PRE_first_tail_x15_r0_body.s810, PRE_first_tail_x15_r0_body.S810)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA241 from PRE_first_tail_x15_r0_body.s813 to PRE_first_tail_x15_r0_body.s814 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s813).run PRE_first_tail_x15_r0_body.S813 = some (PRE_first_tail_x15_r0_body.s814, PRE_first_tail_x15_r0_body.S814)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA242 from PRE_first_tail_x15_r0_body.s817 to PRE_first_tail_x15_r0_body.s818 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s817).run PRE_first_tail_x15_r0_body.S817 = some (PRE_first_tail_x15_r0_body.s818, PRE_first_tail_x15_r0_body.S818)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB242 from PRE_first_tail_x15_r0_body.s818 to PRE_first_tail_x15_r0_body.s819 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s818).run PRE_first_tail_x15_r0_body.S818 = some (PRE_first_tail_x15_r0_body.s819, PRE_first_tail_x15_r0_body.S819)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA243 from PRE_first_tail_x15_r0_body.s820 to PRE_first_tail_x15_r0_body.s821 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s820).run PRE_first_tail_x15_r0_body.S820 = some (PRE_first_tail_x15_r0_body.s821, PRE_first_tail_x15_r0_body.S821)
end Host.Load.Run.Tpl
