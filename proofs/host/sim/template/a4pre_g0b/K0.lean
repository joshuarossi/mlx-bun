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
boot_rfl PRE_g0b.k0 from PRE_g0b.s0 to PRE_g0b.s1 : runOk PRE_g0b.F PRE_g0b.okB0 ((nth? PRE_g0b.ks 0).getD 0) PRE_g0b.s0 PRE_g0b.S0 = some (PRE_g0b.s1, PRE_g0b.S1)
boot_rfl PRE_g0b.stepA1 from PRE_g0b.s1 to PRE_g0b.s2 : interpS (step PRE_g0b.F PRE_g0b.s1).run PRE_g0b.S1 = some (PRE_g0b.s2, PRE_g0b.S2)
boot_rfl PRE_g0b.patchB1 from PRE_g0b.s2 to PRE_g0b.s3 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_g0b.s2 PRE_g0b.S2 (.var 9)) = some (PRE_g0b.s3, PRE_g0b.S3)
boot_rfl PRE_g0b.k3 from PRE_g0b.s3 to PRE_g0b.s4 : runOk PRE_g0b.F PRE_g0b.okB1 ((nth? PRE_g0b.ks 3).getD 0) PRE_g0b.s3 PRE_g0b.S3 = some (PRE_g0b.s4, PRE_g0b.S4)
end Host.Load.Run.Tpl
