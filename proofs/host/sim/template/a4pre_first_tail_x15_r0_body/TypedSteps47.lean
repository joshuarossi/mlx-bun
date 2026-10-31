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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA234 from PRE_first_tail_x15_r0_body.s790 to PRE_first_tail_x15_r0_body.s791 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s790).run PRE_first_tail_x15_r0_body.S790 = some (PRE_first_tail_x15_r0_body.s791, PRE_first_tail_x15_r0_body.S791)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB234 from PRE_first_tail_x15_r0_body.s791 to PRE_first_tail_x15_r0_body.s792 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s791).run PRE_first_tail_x15_r0_body.S791 = some (PRE_first_tail_x15_r0_body.s792, PRE_first_tail_x15_r0_body.S792)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA235 from PRE_first_tail_x15_r0_body.s793 to PRE_first_tail_x15_r0_body.s794 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s793).run PRE_first_tail_x15_r0_body.S793 = some (PRE_first_tail_x15_r0_body.s794, PRE_first_tail_x15_r0_body.S794)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB235 from PRE_first_tail_x15_r0_body.s794 to PRE_first_tail_x15_r0_body.s795 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s794).run PRE_first_tail_x15_r0_body.S794 = some (PRE_first_tail_x15_r0_body.s795, PRE_first_tail_x15_r0_body.S795)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA236 from PRE_first_tail_x15_r0_body.s796 to PRE_first_tail_x15_r0_body.s797 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s796).run PRE_first_tail_x15_r0_body.S796 = some (PRE_first_tail_x15_r0_body.s797, PRE_first_tail_x15_r0_body.S797)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB236 from PRE_first_tail_x15_r0_body.s797 to PRE_first_tail_x15_r0_body.s798 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s797).run PRE_first_tail_x15_r0_body.S797 = some (PRE_first_tail_x15_r0_body.s798, PRE_first_tail_x15_r0_body.S798)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA237 from PRE_first_tail_x15_r0_body.s799 to PRE_first_tail_x15_r0_body.s800 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s799).run PRE_first_tail_x15_r0_body.S799 = some (PRE_first_tail_x15_r0_body.s800, PRE_first_tail_x15_r0_body.S800)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB237 from PRE_first_tail_x15_r0_body.s800 to PRE_first_tail_x15_r0_body.s801 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s800).run PRE_first_tail_x15_r0_body.S800 = some (PRE_first_tail_x15_r0_body.s801, PRE_first_tail_x15_r0_body.S801)
end Host.Load.Run.Tpl
