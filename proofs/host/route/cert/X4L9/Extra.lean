import host.route.cert.X4L9.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.X4L9
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam

/-! # The x4_L9 forward's certificate: each kernel node plain, each dimension input held -/

simgraph_check_nodes extra : extraOkR Gs choice.cert (litAt (Ref.refNu 0 8)) PRE_first_tail_x4_L9_r0_suffix.inputSrv box [5554869888] native ins, Ec choosing Ecn

end Host.Route.Cert.X4L9
