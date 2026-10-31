import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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
boot_rfl PRE_first_tail_x15_r0_body.k876 from PRE_first_tail_x15_r0_body.s876 to PRE_first_tail_x15_r0_body.s877 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB259 ((nth? PRE_first_tail_x15_r0_body.ks 876).getD 0) PRE_first_tail_x15_r0_body.s876 PRE_first_tail_x15_r0_body.S876 = some (PRE_first_tail_x15_r0_body.s877, PRE_first_tail_x15_r0_body.S877)
boot_rfl PRE_first_tail_x15_r0_body.stepA260 from PRE_first_tail_x15_r0_body.s877 to PRE_first_tail_x15_r0_body.s878 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s877).run PRE_first_tail_x15_r0_body.S877 = some (PRE_first_tail_x15_r0_body.s878, PRE_first_tail_x15_r0_body.S878)
boot_rfl PRE_first_tail_x15_r0_body.patchB260 from PRE_first_tail_x15_r0_body.s878 to PRE_first_tail_x15_r0_body.s879 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s878).run PRE_first_tail_x15_r0_body.S878 = some (PRE_first_tail_x15_r0_body.s879, PRE_first_tail_x15_r0_body.S879)
boot_rfl PRE_first_tail_x15_r0_body.k879 from PRE_first_tail_x15_r0_body.s879 to PRE_first_tail_x15_r0_body.s880 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB260 ((nth? PRE_first_tail_x15_r0_body.ks 879).getD 0) PRE_first_tail_x15_r0_body.s879 PRE_first_tail_x15_r0_body.S879 = some (PRE_first_tail_x15_r0_body.s880, PRE_first_tail_x15_r0_body.S880)
end Host.Load.Run.Tpl
