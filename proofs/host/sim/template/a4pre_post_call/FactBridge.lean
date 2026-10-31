import host.sim.template.a4pre_post_call.Run
import host.sim.full.Rel
import host.load.boot.World
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full
theorem PRE_post_call.selector_inactive : (bridgeOf PRE_post_selector.s0.ffi).active = false :=
  Host.Load.Boot.replay_active _
end Host.Load.Run.Tpl
