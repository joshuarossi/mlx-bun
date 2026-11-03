import host.route.cert.Head.VW.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Head.VW
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The VW class's sampled cut: nodes 20000 to 21458's inputs below them -/

kernel_rfl down5 : (List.range' 20000 1459).all (downB (exactTplDom 15235 15235 [5554869888] nativeH) nativeH) = true

end Host.Route.Cert.Head.VW
