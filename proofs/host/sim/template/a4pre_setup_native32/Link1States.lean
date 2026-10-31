import host.sim.template.a4pre_setup_native32.Check32
set_option Elab.async false
namespace Host.Load.Run.Tpl

noncomputable def PRENative64.chooserSrv : Host.Ts.SSrv := ⟨PRENative32.S1.tab, []⟩
kernel_rfl PRENative64.chooser_tab : PRENative64.chooserSrv.tab = PRENative32.originalS1.tab

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
tpl_chain PRENative64 from PRENative32.s1, PRENative64.chooserSrv : "{\"stop\":\"steps:32\",\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9]],\"baseVals\":[[9,4]],\"vars\":[[9,\"L\"]],\"bridges\":[],\"accept\":\"jsjxs\",\"D0\":4096}" («world» := full)

end Host.Load.Run.Tpl
