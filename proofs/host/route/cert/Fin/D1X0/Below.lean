import host.route.cert.Fin.D1X0.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.D1X0
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

kernel_rfl cert_len : Nat.ble 4010 choice.cert.length = true
kernel_rfl below : ((choice.cert.take 4010).all fun c => Nat.blt c native.nnext) = true

theorem below_at {k : Nat} (hk : k < 4010) : certAt choice.cert k < native.nnext := by
  have hl : 4010 ≤ choice.cert.length := Nat.le_of_ble_eq_true cert_len
  have hm : choice.cert[k]'(by omega) ∈ choice.cert.take 4010 :=
    List.mem_iff_getElem.mpr ⟨k, by simp; omega, by simp⟩
  have h := Nat.blt_eq.mp (List.all_eq_true.mp below _ hm)
  unfold certAt
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega), Option.getD_some]
  exact h

end Host.Route.Cert.Fin.D1X0
