import host.route.cert.Row.Step
import host.route.cert.Row.R1.Check
import host.route.cert.Row.R1.Inputs
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row.R1
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Mlx.SimGraph.Iter Host.Load Host.Load.Run.Tpl
open Host.Ts.Sim.Full (mlxOf)

/-! # POST row `r1`'s checked certificate -/

kernel_rfl token_node : Gs 17777 = some ⟨.reshape [.lit 1, .lit 1], [17776]⟩
kernel_rfl token_input : insT .tokenIds = some 17777
kernel_rfl outputs_check : choice.outputs = Tpl.Ordinary.cacheOutputs.map (certifiedCachePair choice.cert)
kernel_rfl cert_len : Nat.ble Tpl.Ordinary.graph.length choice.cert.length = true
kernel_rfl fed_below : Nat.blt (17776) 17777 = true
kernel_rfl out_below : Nat.blt (certAt choice.cert Tpl.Ordinary.tokenNode) native.nnext = true
kernel_rfl outs_below : choice.outputs.all (fun p => (p.1.all fun j => Nat.blt j native.nnext) &&
  (p.2.all fun j => Nat.blt j native.nnext)) = true

kernel_rfl down : (List.range native.nnext).all (downB (exactTplDom 15235 15235 [5554869888] native) native) = true

/-- The row's certificate. -/
noncomputable def cert : RowCert native PRE_pl_r1.S448 0 where
  cert := choice.cert
  insT := insT
  tokenNode := 17777
  fed := 17776
  ps := ps
  outs := choice.outputs
  hm := check.matches
  hinp := check.inputs
  hlen := Nat.le_of_ble_eq_true cert_len
  htn := token_node
  htk := token_input
  hfl := Nat.blt_eq.mp fed_below
  hins := fun σ hσ => inputs_at_bound 15235 choice.inputs ps 17777 inputs_prefix σ hσ
  houts := outputs_check
  hdown := down

theorem outN : certAt choice.cert Tpl.Ordinary.tokenNode < (mlxOf PRE_pl_r1.s448.ffi).nnext := Nat.blt_eq.mp out_below

theorem outsN : ∀ p ∈ choice.outputs, ∀ j, (p.1 = some j ∨ p.2 = some j) → j < (mlxOf PRE_pl_r1.s448.ffi).nnext := by
  intro p hp j hj
  have h := List.all_eq_true.mp outs_below p hp
  simp only [Bool.and_eq_true, Option.all_eq_true] at h
  rcases hj with hj | hj
  · exact Nat.blt_eq.mp (h.1 j hj)
  · exact Nat.blt_eq.mp (h.2 j hj)

end Host.Route.Cert.Row.R1
