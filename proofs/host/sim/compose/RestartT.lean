import host.sim.compose.RestartW
import host.sim.conv.TraceCompact
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false

/-! # `full_compactW` for a shift renaming nodes above `NB`

The link from a class whose compiled traces sit at other node numbers than the template's (`Conv.FullShiftTX`). -/

namespace Host.Ts.Sim
open Host.Ts
namespace Conv
open Host.Ts.Sim.Full Host.Load.Layers

theorem full_compactWT (NB : Nat) {P P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W1 W0 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv}
    {θ : Nat → SymE} (hP0 : Raised P P0)
    (h1 : RelF FF (FullRXD { P with rest := r } NB) W1 M1 ν K1 s1 S1 t1 C1)
    (hshift : ShiftW FF (fun σ x y => x = s0.ffi ∧ FullShiftTX P0 NB S0.tab.length σ x y) κ θ kp W0 W1 K1 s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound) (hge : s0.next ≤ t1.next)
    (hroomN : NRoom P (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRXD { P with rest := r } NB) W0 ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next)
      (Shift.valuation θ ν)
      ⟨frW M1 K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 := by
  have hn := bridgeX_names
  have hc := shiftComp_X
  have hsh : FullShiftTB BridgeX { P0 with rest := r } NB S0.tab.length κ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  obtain ⟨P1, hP1, h1f⟩ := h1.ffi
  obtain ⟨-, hE1, hNE1, -⟩ := Raised.restart (.inl rfl) hP1
  have hroomN1 : NRoom P1 (toLoad s0.ffi) (toLoad t1.ffi) := by
    unfold NRoom at hroomN ⊢; rw [hE1, hNE1]; exact hroomN
  have hf : FRrFBD BridgeX { P with rest := r } NB s0.ffi M1 S1.tab.length s1.ffi t1.ffi :=
    ⟨P1, hP1, ⟨h1f.load.weak.clear, hroomN1⟩, h1f.bridge, h1f.live, h1f.kern, h1f.pend⟩
  have h2 := h1.mapFR' (FR' := FRrFBD BridgeX { P with rest := r } NB s0.ffi) hf
  have hshift' : ShiftW FF (FSnTB BridgeX { P0 with rest := r } NB S0.tab.length s0.ffi) κ θ kp W0 W1 K1 s0 S0 s1 S1 :=
    { hshift with ffi := ⟨hshift.ffi.1, hsh⟩ }
  have hrel := restartW (FS := FSnTB BridgeX { P0 with rest := r } NB S0.tab.length s0.ffi)
    (fun x y z hxy hyz => fsnTBD_compose hc (hP0.withRest r) _ x y z hxy hyz) h2 hshift' hg hroom hge
  obtain ⟨P2, hP2, ⟨hw0, -⟩, hb0, hl0, hk0, hp0⟩ := hrel.ffi
  obtain ⟨-, hE2, -, -⟩ := Raised.restart (.inl rfl) hP2
  have hz : (toLoad t1.ffi).mlx.tokens = (toLoad s0.ffi).mlx.tokens.map (M1.after κ).nv ++ r := by
    have h' : (mlxOf t1.ffi).tokens = (mlxOf s1.ffi).tokens.map M1.nv ++ P1.rest := h1f.load.mlx.tokensX
    rw [show P1.rest = r from hP1.rest, hsh.tokens, List.map_map] at h'
    show (mlxOf t1.ffi).tokens = (mlxOf s0.ffi).tokens.map (M1.after κ).nv ++ r
    rw [h']
    congr 1
    exact List.map_congr_left fun t _ => Map.nv_after M1 κ t
  have hld : G.LoadR { P2 with rest := r } NB
      ((M1.after κ).rebig (mlxOf s0.ffi).next P2.E (mlxOf t1.ffi).next) S0.tab.length (toLoad s0.ffi)
      (toLoad t1.ffi) := G.LoadRw.rebig hw0 (by rw [hE2]; exact hbig) hsh.tokSupp hz
  have hmap : (M1.after κ).rebig (mlxOf s0.ffi).next P2.E (mlxOf t1.ffi).next =
      (M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next := by rw [hE2]
  rw [hmap] at hld
  have hobj : ∀ h, ((mlxOf s0.ffi).objs.get h).isSome = true →
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next).handle h = (M1.after κ).handle h :=
    fun h hh => rebig_handle _ _ _ _ (hw0.mlx.hlt h (.inr hh))
  have hffi : FullRXD { P with rest := r } NB
      ((M1.after κ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next) S0.tab.length s0.ffi t1.ffi :=
    ⟨{ P2 with rest := r }, hP2.withRest r, hld, hn _ _ _ _ hb0 rfl, hl0.rebig hobj, hk0.rebig hobj rfl,
      hp0.rebig _ _⟩
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

end Conv
end Host.Ts.Sim
