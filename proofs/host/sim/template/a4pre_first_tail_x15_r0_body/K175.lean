import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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
boot_rfl PRE_first_tail_x15_r0_body.patchB189 from PRE_first_tail_x15_r0_body.s700 to PRE_first_tail_x15_r0_body.s701 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s700).run PRE_first_tail_x15_r0_body.S700 = some (PRE_first_tail_x15_r0_body.s701, PRE_first_tail_x15_r0_body.S701)
boot_rfl PRE_first_tail_x15_r0_body.k701 from PRE_first_tail_x15_r0_body.s701 to PRE_first_tail_x15_r0_body.s702 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB189 ((nth? PRE_first_tail_x15_r0_body.ks 701).getD 0) PRE_first_tail_x15_r0_body.s701 PRE_first_tail_x15_r0_body.S701 = some (PRE_first_tail_x15_r0_body.s702, PRE_first_tail_x15_r0_body.S702)
boot_rfl PRE_first_tail_x15_r0_body.stepA190 from PRE_first_tail_x15_r0_body.s702 to PRE_first_tail_x15_r0_body.s703 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s702).run PRE_first_tail_x15_r0_body.S702 = some (PRE_first_tail_x15_r0_body.s703, PRE_first_tail_x15_r0_body.S703)
boot_rfl PRE_first_tail_x15_r0_body.patchB190 from PRE_first_tail_x15_r0_body.s703 to PRE_first_tail_x15_r0_body.s704 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s703).run PRE_first_tail_x15_r0_body.S703 = some (PRE_first_tail_x15_r0_body.s704, PRE_first_tail_x15_r0_body.S704)
end Host.Load.Run.Tpl
