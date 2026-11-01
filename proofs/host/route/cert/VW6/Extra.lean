import host.route.cert.VW6.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.VW6
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam

/-! # The x6 forward's certificate: each kernel node plain, each dimension input held -/

simgraph_check_nodes extra : extraOk Gs choice.cert 10 PRE_first_tail_x6_r0_suffix.inputSrv box [5554869888] native ins, Ec choosing Ecn

end Host.Route.Cert.VW6
