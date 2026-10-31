import host.sim.compose.a4b.SetupCommonBase
import host.sim.template.a4pre_g0b.OkB
import host.sim.template.a4pre_g0b.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupCommon
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route

kernel_rfl fuel : PRE_g0b.ks = [1018, 1, 1, 24, 1, 1, 351, 1, 1, 8]
kernel_rfl nextCall : isCallOf PRE_g0b.s10 "nextPrefillStep" none = true
kernel_rfl accepted0 : PRE_g0b.okB0 PRE_g0b.s0 PRE_g0b.S0 = true
kernel_rfl accepted3 : PRE_g0b.okB0 PRE_g0b.s3 PRE_g0b.S3 = true
kernel_rfl accepted6 : PRE_g0b.okB0 PRE_g0b.s6 PRE_g0b.S6 = true
kernel_rfl accepted9 : PRE_g0b.okB0 PRE_g0b.s9 PRE_g0b.S9 = true
end Host.Ts.Sim.Compose.SetupCommon
