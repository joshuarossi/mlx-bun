import host.sim.template.a4pre_post_head.H0
import host.sim.full.DropTokens
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
kernel_rfl PRE_post_head.old_tokens : (Full.mlxOf D1Body.s155.ffi).tokens = [.ref 1, .ref 2]
end Host.Load.Run.Tpl
