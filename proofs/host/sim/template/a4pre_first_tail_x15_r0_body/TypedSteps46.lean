import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB228 from PRE_first_tail_x15_r0_body.s770 to PRE_first_tail_x15_r0_body.s771 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s770).run PRE_first_tail_x15_r0_body.S770 = some (PRE_first_tail_x15_r0_body.s771, PRE_first_tail_x15_r0_body.S771)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA229 from PRE_first_tail_x15_r0_body.s772 to PRE_first_tail_x15_r0_body.s773 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s772).run PRE_first_tail_x15_r0_body.S772 = some (PRE_first_tail_x15_r0_body.s773, PRE_first_tail_x15_r0_body.S773)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB229 from PRE_first_tail_x15_r0_body.s773 to PRE_first_tail_x15_r0_body.s774 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s773).run PRE_first_tail_x15_r0_body.S773 = some (PRE_first_tail_x15_r0_body.s774, PRE_first_tail_x15_r0_body.S774)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA230 from PRE_first_tail_x15_r0_body.s775 to PRE_first_tail_x15_r0_body.s776 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s775).run PRE_first_tail_x15_r0_body.S775 = some (PRE_first_tail_x15_r0_body.s776, PRE_first_tail_x15_r0_body.S776)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA231 from PRE_first_tail_x15_r0_body.s779 to PRE_first_tail_x15_r0_body.s780 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s779).run PRE_first_tail_x15_r0_body.S779 = some (PRE_first_tail_x15_r0_body.s780, PRE_first_tail_x15_r0_body.S780)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB231 from PRE_first_tail_x15_r0_body.s780 to PRE_first_tail_x15_r0_body.s781 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s780).run PRE_first_tail_x15_r0_body.S780 = some (PRE_first_tail_x15_r0_body.s781, PRE_first_tail_x15_r0_body.S781)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA232 from PRE_first_tail_x15_r0_body.s782 to PRE_first_tail_x15_r0_body.s783 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s782).run PRE_first_tail_x15_r0_body.S782 = some (PRE_first_tail_x15_r0_body.s783, PRE_first_tail_x15_r0_body.S783)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA233 from PRE_first_tail_x15_r0_body.s786 to PRE_first_tail_x15_r0_body.s787 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s786).run PRE_first_tail_x15_r0_body.S786 = some (PRE_first_tail_x15_r0_body.s787, PRE_first_tail_x15_r0_body.S787)
end Host.Load.Run.Tpl
