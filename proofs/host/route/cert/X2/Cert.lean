import host.route.FamCert
import host.route.cert.X2.Check
import host.route.cert.X2.Extra
import host.route.cert.X2.Facts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.X2
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam
open Host.Route.PrefGraph

/-! # The x2 forward's certificate -/

theorem Ec_len : Ec.length = 5018 := by
  unfold Ec
  rw [List.length_map]
  exact graph_len

kernel_rfl down : (List.range native.nnext).all (downB (routeDom 15235 15235 [5554869888] native) native) = true

/-- **The certificate of the x2 group's forward.** -/
noncomputable def cert : FamCert .split .codebook .causal Host.Load.Run.Full.Expected.stages where
  n₀ := 124
  r := rowsAt 10
  s := native
  S := PRE_first_tail_x2_r0_suffix.inputSrv
  B := box
  fixed := [5554869888]
  cert := choice.cert
  kinds := choice.kind
  cells := choice.cells
  E := V4.graph
  Ec := Ec
  tok := V4.outNode
  outs := V4.cacheNodes
  family := V4.family_eq
  hEc := rfl
  hn₀ := ⟨by decide, by decide⟩
  fixedHi := by
    intro i hi
    obtain rfl := List.mem_singleton.mp hi
    exact ⟨by decide, by decide⟩
  hdown := down
  hlen := by rw [graph_len, cert_len]
  hm := by rw [Ec_len]; exact check.matches
  inputs := by rw [Ec_len]; exact check.inputs
  extra := checkNodesD_mono (fun _ _ h => extraOkR_of h) 0 _ extra.all
  kindsPresent := fun e he => List.all_eq_true.mp kinds_ok e he
  outsLt := fun q hq => by
    have h := List.all_eq_true.mp outs_ok q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact ⟨h.1.1.1, h.1.1.2, h.1.2, h.2⟩
  outs64 := outs_len

end Host.Route.Cert.X2
