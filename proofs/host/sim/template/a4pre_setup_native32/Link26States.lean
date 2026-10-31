import host.sim.template.a4pre_setup_native32.Link25
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

noncomputable def PRENative864.chooserSrv : Host.Ts.SSrv := ⟨PRENative832.S1.tab, []⟩
kernel_rfl PRENative864.chooser_tab : PRENative864.chooserSrv.tab = PRENative832.originalS1.tab

set_option interpreter.prefer_native true in
tpl_chain PRENative864 from PRENative832.s1, PRENative864.chooserSrv : "{\"stop\":\"steps:32\",\"stages\":[],\"compact\":false,\"isolate\":false,\"bridges\":[],\"frames\":[2665],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9]],\"baseVals\":[[9,4]],\"vars\":[[9,\"L\"]],\"accept\":\"jsjxs\",\"D0\":4096}" («world» := full)

end Host.Load.Run.Tpl
