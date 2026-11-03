import host.route.cert.Fin.X4L7.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.X4L7
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # Nodes 20000 to 21653's inputs below them -/

kernel_rfl down5 : (List.range' 20000 1654).all (downB (exactTplDom 15235 15235 [5554869888] native) native) = true

end Host.Route.Cert.Fin.X4L7
