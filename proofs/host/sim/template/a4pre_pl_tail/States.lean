import host.sim.template.a4pre_pl_tail.States0
import host.sim.template.TemplateAbs
import host.sim.template.ReturnLiteral
import host.sim.template.ServerData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- specs/ghosts_tail.json: the memo cells and the trace registry no chain from here reads; the D1 traces' dims v249-v256
bridge_empty PRE_pl_tail0.chooser from PRE_pl_tail0.s0
server_data PRE_pl_tail0.chooserSrv := PRE_pl_tail0.S0
set_option interpreter.prefer_native true in
tpl_abstract PRE_pl_tail from PRE_pl_tail0 : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/ghosts_tail.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
