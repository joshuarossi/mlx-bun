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
boot_rfl PRE_g0b.patchB3 from PRE_g0b.s8 to PRE_g0b.s9 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_g0b.s8 PRE_g0b.S8 (.var 9)) = some (PRE_g0b.s9, PRE_g0b.S9)
boot_rfl PRE_g0b.k9 from PRE_g0b.s9 to PRE_g0b.s10 : runOk PRE_g0b.F PRE_g0b.okB3 ((nth? PRE_g0b.ks 9).getD 0) PRE_g0b.s9 PRE_g0b.S9 = some (PRE_g0b.s10, PRE_g0b.S10)
end Host.Load.Run.Tpl
