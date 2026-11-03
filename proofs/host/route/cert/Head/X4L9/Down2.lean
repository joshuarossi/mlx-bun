import host.route.cert.Head.X4L9.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Head.X4L9
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # Nodes 8000 to 11999's inputs below them -/

kernel_rfl down2 : (List.range' 8000 4000).all (downB (exactTplDom 15235 15235 [5554869888] nativeH) nativeH) = true

end Host.Route.Cert.Head.X4L9
