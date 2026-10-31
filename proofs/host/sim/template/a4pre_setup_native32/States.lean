import host.sim.template.a4pre_setup_early_r0.States
set_option Elab.async false
namespace Host.Load.Run.Tpl

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
tpl_chain PRENative32 from PRE_setup_early_r0.inputLoad, PRE_setup_early_r0.inputSrv : "{\"stop\":\"steps:32\",\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9]],\"baseVals\":[[9,4]],\"vars\":[[9,\"L\"]],\"bridges\":[],\"accept\":\"jsjxs\",\"D0\":4096}" («world» := full)

end Host.Load.Run.Tpl
