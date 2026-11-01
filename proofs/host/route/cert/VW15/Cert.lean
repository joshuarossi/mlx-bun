import host.route.FamCert
import host.route.cert.VW15.Check
import host.route.cert.VW15.Extra
import host.route.cert.VW15.Facts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.VW15
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam

open Host.Route.PrefGraph

/-! # The x15 forward's certificate -/

theorem Ec_len : Ec.length = 5018 := by
  unfold Ec
  rw [List.length_map]
  exact graph_len

/-- **The certificate of the x15 group's forward.** -/
noncomputable def cert : FamCert .split (.wide 2 ⟨8, 2⟩) .causal Host.Load.Run.Full.Expected.stages where
  n₀ := 124
  x := 10
  s := native
  S := PRE_first_tail_x15_r0_suffix.inputSrv
  B := box
  fixed := [5554869888]
  cert := choice.cert
  kinds := choice.kind
  cells := choice.cells
  E := VW82.graph
  Ec := Ec
  tok := VW82.outNode
  outs := VW82.cacheNodes
  family := VW82.family_eq
  hEc := rfl
  hn₀ := ⟨by decide, by decide⟩
  fixedHi := by
    intro i hi
    obtain rfl := List.mem_singleton.mp hi
    exact ⟨by decide, by decide⟩
  hlen := by rw [graph_len, cert_len]; exact Nat.le_refl _
  hm := by rw [Ec_len]; exact check.matches
  inputs := by rw [Ec_len]; exact check.inputs
  extra := extra.all
  kindsPresent := fun e he => List.all_eq_true.mp kinds_ok e he
  outsLt := fun q hq => by
    have h := List.all_eq_true.mp outs_ok q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact ⟨h.1.1.1, h.1.1.2, h.1.2, h.2⟩
  outs64 := outs_len

end Host.Route.Cert.VW15
