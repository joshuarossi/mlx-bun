import host.sim.compose.a4b.PrefillFirstTailX15
import host.sim.compose.a4b.VWStart
import host.sim.template.a4pre_first_tail_x15_r0.SiteR1
import host.sim.template.a4pre_first_tail_x15_r0.SiteZ1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl
kernel_rfl npsBridge : bridgeOf PRE_first_tail_x15_r0.s17.ffi =
  Host.Load.Boot.replay Host.Load.Run.Prompt.P.oblog2818
kernel_rfl returnBridge : bridgeOf PRE_first_tail_x15_r0.s19.ffi =
  Host.Load.Boot.replay Host.Load.Run.Prompt.P.oblog2818
kernel_rfl npsWsLow : PRE_first_tail_x15_r0.ws1.all (Nat.ble 9) = true
kernel_rfl npsCwsDisjoint : PRE_first_tail_x15_r0.cws1.all (fun c => !PRE_first_tail_x15_r0.ws1.contains c) = true
kernel_rfl npsPromptEmpty : arrOf PRE_first_tail_x15_r0.s0 2665 = []
end Host.Ts.Sim.Compose.VWFirst
