import host.sim.template.a4pre_first_tail_x15_r0_body.H23
import host.sim.template.a4pre_first_tail_x15_r0_body.H24
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA204 from PRE_first_tail_x15_r0_body.s754 to PRE_first_tail_x15_r0_body.s755 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s754).run PRE_first_tail_x15_r0_body.S754 = some (PRE_first_tail_x15_r0_body.s755, PRE_first_tail_x15_r0_body.S755)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB204 from PRE_first_tail_x15_r0_body.s755 to PRE_first_tail_x15_r0_body.s756 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s755).run PRE_first_tail_x15_r0_body.S755 = some (PRE_first_tail_x15_r0_body.s756, PRE_first_tail_x15_r0_body.S756)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA205 from PRE_first_tail_x15_r0_body.s757 to PRE_first_tail_x15_r0_body.s758 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s757).run PRE_first_tail_x15_r0_body.S757 = some (PRE_first_tail_x15_r0_body.s758, PRE_first_tail_x15_r0_body.S758)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB205 from PRE_first_tail_x15_r0_body.s758 to PRE_first_tail_x15_r0_body.s759 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s758).run PRE_first_tail_x15_r0_body.S758 = some (PRE_first_tail_x15_r0_body.s759, PRE_first_tail_x15_r0_body.S759)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA206 from PRE_first_tail_x15_r0_body.s760 to PRE_first_tail_x15_r0_body.s761 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s760).run PRE_first_tail_x15_r0_body.S760 = some (PRE_first_tail_x15_r0_body.s761, PRE_first_tail_x15_r0_body.S761)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB206 from PRE_first_tail_x15_r0_body.s761 to PRE_first_tail_x15_r0_body.s762 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s761).run PRE_first_tail_x15_r0_body.S761 = some (PRE_first_tail_x15_r0_body.s762, PRE_first_tail_x15_r0_body.S762)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA207 from PRE_first_tail_x15_r0_body.s763 to PRE_first_tail_x15_r0_body.s764 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s763).run PRE_first_tail_x15_r0_body.S763 = some (PRE_first_tail_x15_r0_body.s764, PRE_first_tail_x15_r0_body.S764)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA208 from PRE_first_tail_x15_r0_body.s767 to PRE_first_tail_x15_r0_body.s768 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s767).run PRE_first_tail_x15_r0_body.S767 = some (PRE_first_tail_x15_r0_body.s768, PRE_first_tail_x15_r0_body.S768)
end Host.Load.Run.Tpl
