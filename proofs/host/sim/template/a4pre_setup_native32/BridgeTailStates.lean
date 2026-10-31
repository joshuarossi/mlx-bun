import host.sim.template.a4pre_setup_native32.BridgePartsData
import host.sim.template.BridgePrefixes
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Host.Ts Host.Mlx

def serBridgeTail (p : FS) : Stream.GenM Lean.Expr := do
  let b := bridgePrefixCandidate p.1.1.bridge 1918
  let _ ← Stream.named (mkConst ``FfiAne.St) "bridge1918" b (fun x => pure (toExpr x))
  serFull p

def bridgeTailWorld : TWorld Host.Load.Layers.full :=
  { fullWorld with ser := serBridgeTail }

end Host.Ts.Sim.Template
namespace Host.Load.Run.Tpl

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
tpl_chain PREBridgeTail from PRENative32.s0, PRENative32.S0 : "{\"stop\":\"steps:1\",\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9]],\"baseVals\":[[9,4]],\"vars\":[[9,\"L\"]],\"bridges\":[],\"accept\":\"jsjxs\",\"D0\":4096}" («world» := Host.Ts.Sim.Template.bridgeTailWorld)

end Host.Load.Run.Tpl
