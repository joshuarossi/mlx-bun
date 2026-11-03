import host.route.cert.Fin.VW.Down
import host.route.cert.Fin.D1X0.Down0
import host.route.cert.Fin.D1X0.Down1
import host.route.cert.Fin.D1X0.Down2
import host.route.cert.Fin.D1X0.Down3
import host.route.cert.Fin.D1X0.Down4
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.D1X0
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

kernel_rfl nnext_eq : native.nnext = 17764

theorem down : (List.range native.nnext).all (downB (exactTplDom 15235 15235 [5554869888] native) native) = true := by
  rw [nnext_eq, List.range_eq_range']
  have h1 := Fin.VW.all_range'_append _ 0 4000 4000 down0 down1
  have h2 := Fin.VW.all_range'_append _ 0 8000 4000 h1 down2
  have h3 := Fin.VW.all_range'_append _ 0 12000 4000 h2 down3
  have h4 := Fin.VW.all_range'_append _ 0 16000 1764 h3 down4
  exact h4

end Host.Route.Cert.Fin.D1X0
