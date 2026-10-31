import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

noncomputable def D1PostOneEos.chooserSrv : Host.Ts.SSrv := ⟨D1Body.S155.tab, []⟩

set_option interpreter.prefer_native true in
tpl_chain D1PostOneEos from D1Body.s155, D1PostOneEos.chooserSrv : "{\"stop\":\"halt\",\"stuckStop\":false,\"cap\":50000,\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665,2673479,2673484,2673485],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9],[2673479,9]],\"baseVals\":[[0,1],[1,248044],[9,1]],\"vars\":[[0,\"T\"],[9,\"L\"]],\"bridges\":[\"size\",\"len\"],\"accept\":\"jsjxs\",\"D0\":4096,\"loadP\":[18151,131072,1099511627776,15235,15235]}" («world» := full)

end Host.Load.Run.Tpl
