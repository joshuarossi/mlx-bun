import host.sim.template.a4pre_g0b.H0
import host.sim.template.a4pre_g0b.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_g0b.stepA2 from PRE_g0b.s4 to PRE_g0b.s5 : interpS (step PRE_g0b.F PRE_g0b.s4).run PRE_g0b.S4 = some (PRE_g0b.s5, PRE_g0b.S5)
boot_rfl PRE_g0b.patchB2 from PRE_g0b.s5 to PRE_g0b.s6 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_g0b.s5 PRE_g0b.S5 (.var 9)) = some (PRE_g0b.s6, PRE_g0b.S6)
boot_rfl PRE_g0b.k6 from PRE_g0b.s6 to PRE_g0b.s7 : runOk PRE_g0b.F PRE_g0b.okB2 ((nth? PRE_g0b.ks 6).getD 0) PRE_g0b.s6 PRE_g0b.S6 = some (PRE_g0b.s7, PRE_g0b.S7)
boot_rfl PRE_g0b.stepA3 from PRE_g0b.s7 to PRE_g0b.s8 : interpS (step PRE_g0b.F PRE_g0b.s7).run PRE_g0b.S7 = some (PRE_g0b.s8, PRE_g0b.S8)
end Host.Load.Run.Tpl
