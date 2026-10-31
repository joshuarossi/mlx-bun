import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.a4pre_first_tail_x15_r0_body.H25
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB213 from PRE_first_tail_x15_r0_body.s788 to PRE_first_tail_x15_r0_body.s789 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s788).run PRE_first_tail_x15_r0_body.S788 = some (PRE_first_tail_x15_r0_body.s789, PRE_first_tail_x15_r0_body.S789)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA214 from PRE_first_tail_x15_r0_body.s791 to PRE_first_tail_x15_r0_body.s792 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s791).run PRE_first_tail_x15_r0_body.S791 = some (PRE_first_tail_x15_r0_body.s792, PRE_first_tail_x15_r0_body.S792)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA215 from PRE_first_tail_x15_r0_body.s795 to PRE_first_tail_x15_r0_body.s796 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s795).run PRE_first_tail_x15_r0_body.S795 = some (PRE_first_tail_x15_r0_body.s796, PRE_first_tail_x15_r0_body.S796)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB215 from PRE_first_tail_x15_r0_body.s796 to PRE_first_tail_x15_r0_body.s797 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s796).run PRE_first_tail_x15_r0_body.S796 = some (PRE_first_tail_x15_r0_body.s797, PRE_first_tail_x15_r0_body.S797)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA216 from PRE_first_tail_x15_r0_body.s799 to PRE_first_tail_x15_r0_body.s800 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s799).run PRE_first_tail_x15_r0_body.S799 = some (PRE_first_tail_x15_r0_body.s800, PRE_first_tail_x15_r0_body.S800)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA217 from PRE_first_tail_x15_r0_body.s803 to PRE_first_tail_x15_r0_body.s804 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s803).run PRE_first_tail_x15_r0_body.S803 = some (PRE_first_tail_x15_r0_body.s804, PRE_first_tail_x15_r0_body.S804)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA218 from PRE_first_tail_x15_r0_body.s808 to PRE_first_tail_x15_r0_body.s809 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s808).run PRE_first_tail_x15_r0_body.S808 = some (PRE_first_tail_x15_r0_body.s809, PRE_first_tail_x15_r0_body.S809)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB218 from PRE_first_tail_x15_r0_body.s809 to PRE_first_tail_x15_r0_body.s810 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s809).run PRE_first_tail_x15_r0_body.S809 = some (PRE_first_tail_x15_r0_body.s810, PRE_first_tail_x15_r0_body.S810)
end Host.Load.Run.Tpl
