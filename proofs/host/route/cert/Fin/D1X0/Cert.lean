import host.route.cert.Fin.D1X0.Check
import host.route.cert.Fin.D1X0.Down
import host.route.cert.Fin.D1X0.Below
import host.route.cert.Fin.D1X0.Ins
import host.route.cert.Fin.D1Fwd
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.D1X0
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin
open Host.Mlx.SimGraph.Iter

/-! # The D1X0 class's first forward: its certificate -/

/-- **The D1X0 class's first forward, checked.** -/
noncomputable def d1Cert : D1Cert native PRE_first_tail_x0_r0_suffix.inputSrv box vars where
  cert := choice.cert
  insT := insT
  tok := 15235
  ps := ps
  hm := check.matches
  hlen := Nat.le_of_ble_eq_true cert_len
  hinp := check.inputs
  hins := fun σ hfix => inputs_at_bound 15235 choice.inputs ps 15235 inputs_ok σ hfix
  hbelow := fun _ hk => below_at hk
  hdown := down

end Host.Route.Cert.Fin.D1X0
