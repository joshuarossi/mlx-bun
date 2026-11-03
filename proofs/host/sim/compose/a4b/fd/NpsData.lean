import host.sim.compose.a4b.PrefillFirstTailX15
import host.sim.compose.a4b.VWStart
import host.sim.template.a4pre_fd_vw_r0.SiteR0
import host.sim.template.a4pre_fd_vw_r0.SiteZ0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl
kernel_rfl npsBridge : bridgeOf PRE_fd_vw_r0.s0.ffi =
  Host.Load.Boot.replay Host.Load.Run.Prompt.P.oblog2818
kernel_rfl returnBridge : bridgeOf PRE_fd_vw_r0.s2.ffi =
  Host.Load.Boot.replay Host.Load.Run.Prompt.P.oblog2818
kernel_rfl npsWsLow : PRE_fd_vw_r0.ws0.all (Nat.ble 9) = true
kernel_rfl npsCwsDisjoint : PRE_fd_vw_r0.cws0.all (fun c => !PRE_fd_vw_r0.ws0.contains c) = true
kernel_rfl npsPromptEmpty : arrOf PRE_fd_vw_r0.s0 2665 = []
end Host.Ts.Sim.Compose.FDVW
