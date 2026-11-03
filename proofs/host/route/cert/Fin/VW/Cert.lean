import host.route.cert.Fin.VW.Check
import host.route.cert.Fin.Step
import host.simgraph.iter.InputsPrefix
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.VW
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Mlx.SimGraph.Iter Host.Load Host.Load.Extract Host.Load.Run.Tpl

/-! # The VW class's final forward: its certificate -/

/-- The caches the forward reads, at their carriers. -/
def ps : List (Option Nat × Option Nat) :=
  (List.range 64).map fun p => (inputsOf choice.inputs (.stage p (.cache 0)), inputsOf choice.inputs (.stage p (.cache 1)))

kernel_rfl inputs_ok : InputsOkAt 15235 choice.inputs ps 19057 = true
kernel_rfl down : (List.range native.nnext).all (downB (exactTplDom 15235 15235 [5554869888] native) native) = true
kernel_rfl cert_len : Nat.ble 4010 choice.cert.length = true
kernel_rfl below : ((List.range 4010).all fun k => Nat.blt (certAt choice.cert k) native.nnext) = true

/-- **The VW class's final forward, checked.** -/
noncomputable def finCert : FinCert native PRE_fd_vw_r0_body.S900 box vars (-1) 4010 where
  cert := choice.cert
  insT := insT
  tok := 19057
  ps := ps
  hm := check.matches
  hlen := Nat.le_of_ble_eq_true cert_len
  hinp := check.inputs
  hins := fun σ hfix => inputs_at_bound 15235 choice.inputs ps 19057 inputs_ok σ hfix
  hdown := down

theorem finCert_below : ∀ k, k < 4010 → certAt finCert.cert k < native.nnext := fun k hk =>
  Nat.lt_of_blt_eq_true (List.all_eq_true.mp below k (List.mem_range.mpr hk))

end Host.Route.Cert.Fin.VW
