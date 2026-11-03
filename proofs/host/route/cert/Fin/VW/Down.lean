import host.route.cert.Fin.VW.Down0
import host.route.cert.Fin.VW.Down1
import host.route.cert.Fin.VW.Down2
import host.route.cert.Fin.VW.Down3
import host.route.cert.Fin.VW.Down4
import host.route.cert.Fin.VW.Down5
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.VW
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl

/-! # The VW class's final forward: every node's inputs below it -/

kernel_rfl nnext_eq : native.nnext = 21446

theorem all_range'_append (f : Nat → Bool) (s m n : Nat) (h1 : (List.range' s m).all f = true)
    (h2 : (List.range' (s + m) n).all f = true) : (List.range' s (m + n)).all f = true := by
  rw [List.all_eq_true] at h1 h2 ⊢
  intro k hk
  rw [List.mem_range'_1] at hk
  by_cases h : k < s + m
  · exact h1 k (List.mem_range'_1.mpr ⟨hk.1, h⟩)
  · exact h2 k (List.mem_range'_1.mpr ⟨by omega, by omega⟩)

theorem down : (List.range native.nnext).all (downB (exactTplDom 15235 15235 [5554869888] native) native) = true := by
  rw [nnext_eq, List.range_eq_range']
  have h1 := all_range'_append _ 0 4000 4000 down0 down1
  have h2 := all_range'_append _ 0 8000 4000 h1 down2
  have h3 := all_range'_append _ 0 12000 4000 h2 down3
  have h4 := all_range'_append _ 0 16000 4000 h3 down4
  have h5 := all_range'_append _ 0 20000 1446 h4 down5
  exact h5

end Host.Route.Cert.Fin.VW
