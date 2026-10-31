import host.sim.template.a4pre_first_tail_x15_r0_body.H23
import host.sim.template.a4pre_first_tail_x15_r0_body.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.k756 from PRE_first_tail_x15_r0_body.s756 to PRE_first_tail_x15_r0_body.s757 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB204 ((nth? PRE_first_tail_x15_r0_body.ks 756).getD 0) PRE_first_tail_x15_r0_body.s756 PRE_first_tail_x15_r0_body.S756 = some (PRE_first_tail_x15_r0_body.s757, PRE_first_tail_x15_r0_body.S757)
boot_rfl PRE_first_tail_x15_r0_body.stepA205 from PRE_first_tail_x15_r0_body.s757 to PRE_first_tail_x15_r0_body.s758 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s757).run PRE_first_tail_x15_r0_body.S757 = some (PRE_first_tail_x15_r0_body.s758, PRE_first_tail_x15_r0_body.S758)
boot_rfl PRE_first_tail_x15_r0_body.patchB205 from PRE_first_tail_x15_r0_body.s758 to PRE_first_tail_x15_r0_body.s759 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s758).run PRE_first_tail_x15_r0_body.S758 = some (PRE_first_tail_x15_r0_body.s759, PRE_first_tail_x15_r0_body.S759)
boot_rfl PRE_first_tail_x15_r0_body.k759 from PRE_first_tail_x15_r0_body.s759 to PRE_first_tail_x15_r0_body.s760 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB205 ((nth? PRE_first_tail_x15_r0_body.ks 759).getD 0) PRE_first_tail_x15_r0_body.s759 PRE_first_tail_x15_r0_body.S759 = some (PRE_first_tail_x15_r0_body.s760, PRE_first_tail_x15_r0_body.S760)
end Host.Load.Run.Tpl
