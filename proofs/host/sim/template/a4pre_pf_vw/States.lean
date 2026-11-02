import host.sim.template.a4pre_pf_vw.States0
import host.sim.template.TemplateAbs
import host.sim.template.ReturnLiteral
import host.sim.template.ServerData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts
-- specs/ghosts_pf.json: the kernels only some classes' first forwards create, the memo's mask
bridge_empty PRE_pf_vw0.chooser from PRE_pf_vw0.s0
server_data PRE_pf_vw0.chooserSrv := PRE_pf_vw0.S0
set_option interpreter.prefer_native true in
tpl_abstract PRE_pf_vw from PRE_pf_vw0 : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/specs/ghosts_pf.json" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)
end Host.Load.Run.Tpl
