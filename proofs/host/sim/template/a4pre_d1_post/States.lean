import host.sim.template.a4pre_d1_body.D4
-- stream revision 1793591500
-- revision: literal chunk length
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

/-! Untrusted candidate continuation from the exact cold D1 hidden-state return.
The subsequent lm-head and sampler execute before the next actual D1 call.
Execution and source/endpoint correspondence require separate kernel checks. -/
noncomputable def D1Post.chooserSrv : Host.Ts.SSrv := ⟨D1Body.S155.tab, []⟩

set_option interpreter.prefer_native true in
tpl_chain D1Post from D1Body.s155, D1Post.chooserSrv : "{\"stop\":\"call:#2671709\",\"stuckStop\":true,\"cap\":50000,\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665,2673479,2673484,2673485],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9],[2673479,9]],\"baseVals\":[[9,1]],\"vars\":[[0,\"T\"],[9,\"L\"]],\"bridges\":[\"size\",\"len\"],\"accept\":\"jsjxs\",\"D0\":4096,\"loadP\":[18151,131072,1099511627776,15235,15235]}" («world» := full)

end Host.Load.Run.Tpl
