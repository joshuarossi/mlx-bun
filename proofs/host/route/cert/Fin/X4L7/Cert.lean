import host.route.cert.Fin.X4L7.Check
import host.route.cert.Fin.X4L7.Down
import host.route.cert.Fin.X4L7.Below
import host.route.cert.Fin.X4L7.Ins
import host.route.cert.Fin.Step
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.X4L7
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin
open Host.Mlx.SimGraph.Iter

/-! # The X4L7 class's final forward: its certificate -/

/-- **The X4L7 class's final forward, checked.** -/
noncomputable def finCert : FinCert native PRE_fd_x4_L7_r0_body.S451 box vars (-1) 4010 where
  cert := choice.cert
  insT := insT
  tok := 19265
  ps := ps
  hm := check.matches
  hlen := Nat.le_of_ble_eq_true cert_len
  hinp := check.inputs
  hins := fun σ hfix => inputs_at_bound 15235 choice.inputs ps 19265 inputs_ok σ hfix
  hdown := down

theorem finCert_below : ∀ k, k < 4010 → certAt finCert.cert k < native.nnext := fun _ hk => below_at hk

end Host.Route.Cert.Fin.X4L7
