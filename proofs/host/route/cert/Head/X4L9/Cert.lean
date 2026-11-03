import host.route.cert.Fin.Head
import host.route.cert.Fin.X4L9.Cert
import host.route.cert.Head.X4L9.Check
import host.route.cert.Head.X4L9.Down
import host.route.cert.Head.X4L9.Facts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Head.X4L9
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The X4L9 class's sampled cut: its certificate -/

simgraph_check_nodes inpH : headInputOk choiceH.cert, Tpl.Ordinary.graph choosing Tpl.Ordinary.graph

-- The forward's nodes the sampled cut names, where the final forward left them.
kernel_rfl kept_fin : (keptOf (certAt choiceH.cert)).all (fun q =>
  Nat.blt q.1 Fin.X4L9.choice.cert.length && Nat.beq (certAt Fin.X4L9.choice.cert q.1) q.2) = true

/-- **The X4L9 class's sampled cut, checked.** -/
noncomputable def headCert : HeadCert nativeH PRE_plx4_L9_common.S1 boxH varsH (-1) where
  cert := choiceH.cert
  hm := checkH.all
  hlen := Nat.le_of_ble_eq_true cert_len
  hinp := inpH.all
  toB := Nat.blt_eq.mp tok_below
  outsB := fun q hq => by
    have h := List.all_eq_true.mp outs_below q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact h
  hdown := downH

theorem kept_at : ∀ q ∈ keptOf (certAt headCert.cert), q.1 < Fin.X4L9.finCert.cert.length ∧
    certAt Fin.X4L9.finCert.cert q.1 = q.2 := fun q hq => by
  have h := List.all_eq_true.mp kept_fin q hq
  simp only [Bool.and_eq_true, Nat.blt_eq, Nat.beq_eq] at h
  exact h

end Host.Route.Cert.Head.X4L9
