import host.sim.template.a4pre_first_tail_x15_r0_body.st147.TypedSplitK0Data0
import host.sim.template.ReturnLiteral
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim

bridge_empty PRE_first_tail_x15_r0_body.st147.typedSplitK0.p1.input from PRE_first_tail_x15_r0_body.st147.typedSplitK0.p0.s1
server_literal PRE_first_tail_x15_r0_body.st147.typedSplitK0.p1.inputSrv := (⟨PRE_first_tail_x15_r0_body.st147.typedSplitK0.originalS1.tab, []⟩ : SSrv)
set_option interpreter.prefer_native true in
tpl_chain PRE_first_tail_x15_r0_body.st147.typedSplitK0.p1 from PRE_first_tail_x15_r0_body.st147.typedSplitK0.p1.input, PRE_first_tail_x15_r0_body.st147.typedSplitK0.p1.inputSrv : "{\"stop\":\"steps:3333\",\"cap\":3433,\"stuckStop\":false,\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665,2673467,2673472,2673473],\"wide\":[[4910,\".memo []\"]],\"baseVals\":[[9,125],[10,124]],\"vars\":[[9,\"L\"],[10,\"n\"]],\"bridges\":[],\"accept\":\"jsjxs\",\"D0\":131072,\"loadP\":[18151,131072,1099511627776,15235,15235]}" («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)

end Host.Load.Run.Tpl
