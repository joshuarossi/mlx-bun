import host.sim.template.a4pre_setup_native32.H0
import host.sim.template.BridgePrefixes
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

set_option interpreter.prefer_native true in
tpl_chain PREBridgeParts from PRENative32.s0, PRENative32.S0 : "{\"stop\":\"steps:1\",\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665],\"wide\":[[4910,\".memo []\"]],\"baseVals\":[[9,4]],\"accept\":\"jsjxs\",\"D0\":4096}" («world» := bridgePrefixes)

end Host.Load.Run.Tpl
