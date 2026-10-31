import host.sim.template.a4pre_setup_native32.Link20
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

noncomputable def PRENative704.chooserSrv : Host.Ts.SSrv := ⟨PRENative672.S1.tab, []⟩
kernel_rfl PRENative704.chooser_tab : PRENative704.chooserSrv.tab = PRENative672.originalS1.tab

set_option interpreter.prefer_native true in
tpl_chain PRENative704 from PRENative672.s1, PRENative704.chooserSrv : "{\"stop\":\"steps:32\",\"stages\":[],\"compact\":false,\"isolate\":false,\"bridges\":[],\"frames\":[2665],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9]],\"baseVals\":[[9,4]],\"vars\":[[9,\"L\"]],\"accept\":\"jsjxs\",\"D0\":4096}" («world» := full)

end Host.Load.Run.Tpl
