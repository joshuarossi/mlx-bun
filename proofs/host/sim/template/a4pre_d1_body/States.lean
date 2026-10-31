import host.sim.template.a4pre_d1_body.Source
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

noncomputable def D1Body.chooserSrv : Host.Ts.SSrv := ⟨D1Call.S1.tab, []⟩

set_option interpreter.prefer_native true in
tpl_chain D1Body from D1Call.s1, D1Body.chooserSrv : "{\"stop\":\"ret\",\"stuckStop\":true,\"cap\":4000000,\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665,2673479,2673484,2673485],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9],[2673479,9]],\"baseVals\":[[9,1]],\"vars\":[[9,\"L\"]],\"bridges\":[],\"accept\":\"jsjxs\",\"D0\":4096,\"loadP\":[18151,131072,1099511627776,15235,15235]}" («world» := full)

end Host.Load.Run.Tpl
