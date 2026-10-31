import host.sim.template.a4pre_setup_native32.OriginalK0
import host.sim.template.a4pre_setup_early_r0.H0
import host.sim.template.a4pre_setup_early_r0.OkB
import host.sim.Chunk
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
kernel_rfl PRE_setup_early_r0.stepA1 : interpS (step PRE_setup_early_r0.F PRE_setup_early_r0.s1).run PRE_setup_early_r0.S1 = some (PRE_setup_early_r0.s2, PRE_setup_early_r0.S2)
kernel_rfl PRE_setup_early_r0.patchB1 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_setup_early_r0.s2 PRE_setup_early_r0.S2 (.var 9)) = some (PRE_setup_early_r0.s3, PRE_setup_early_r0.S3)
kernel_rfl PRE_setup_early_r0.stepA2 : interpS (step PRE_setup_early_r0.F PRE_setup_early_r0.s3).run PRE_setup_early_r0.S3 = some (PRE_setup_early_r0.s4, PRE_setup_early_r0.S4)
end Host.Load.Run.Tpl
