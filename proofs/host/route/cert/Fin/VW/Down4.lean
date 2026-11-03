import host.route.cert.Fin.VW.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.VW
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl

/-! # The VW class's final forward: nodes 16000 to 19999's inputs below them -/

kernel_rfl down4 : (List.range' 16000 4000).all (downB (exactTplDom 15235 15235 [5554869888] native) native) = true

end Host.Route.Cert.Fin.VW
