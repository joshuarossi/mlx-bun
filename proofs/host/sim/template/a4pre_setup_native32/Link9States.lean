import host.sim.template.a4pre_setup_native32.Link8
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

noncomputable def PRENative320.chooserSrv : Host.Ts.SSrv := ⟨PRENative288.S1.tab, []⟩
kernel_rfl PRENative320.chooser_tab : PRENative320.chooserSrv.tab = PRENative288.originalS1.tab

set_option interpreter.prefer_native true in
tpl_chain PRENative320 from PRENative288.s1, PRENative320.chooserSrv : "{\"stop\":\"steps:32\",\"stages\":[],\"compact\":false,\"isolate\":false,\"bridges\":[],\"frames\":[2665],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9]],\"baseVals\":[[9,4]],\"vars\":[[9,\"L\"]],\"accept\":\"jsjxs\",\"D0\":4096}" («world» := full)

end Host.Load.Run.Tpl
