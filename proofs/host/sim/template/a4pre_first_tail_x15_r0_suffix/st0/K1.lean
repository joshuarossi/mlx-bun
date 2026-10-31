import host.sim.template.a4pre_first_tail_x15_r0_suffix.st0.H0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.st0.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_suffix.st0.last from PRE_first_tail_x15_r0_suffix.st0.s4 to PRE_first_tail_x15_r0_suffix.st0.s5 : interpS (step PRE_first_tail_x15_r0_suffix.st0.F PRE_first_tail_x15_r0_suffix.st0.s4).run PRE_first_tail_x15_r0_suffix.st0.S4 = some (PRE_first_tail_x15_r0_suffix.st0.s5, PRE_first_tail_x15_r0_suffix.st0.S5)
end Host.Load.Run.Tpl
