import host.sim.conv.HandOff
import host.sim.full.LogRel

/-! # The prefill → decode hand-off from a cut with a log base

The target of a prefill's last cut carries a log base and programs up to lock flags (`FRL L`). A hand-off reads neither:
the frame `BridgeF` is the target's activity, schedule and aliases (`bridgeF_fF`), and the rest of the state relation
does not read the target's native state. So the hand-off runs at the frame's underlying target (`relF_swapT`), and
the result moves back to the real one (`full_handoffTbL`, `full_handoffTb`'s statement at `FRL L`). -/

namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers
open Host.Mlx.FfiAne (Effect Program)

theorem bridgeF_fF {L : List Effect} {ps : List Program} {M : Map} {x y : FF.S} (h : BridgeF M x y) :
    BridgeF M x (fF L ps y) := by
  refine ⟨h.1, ?_⟩
  rcases h.2 with h | h
  · exact .inl h
  · exact .inr { unscheduled := h.unscheduled, running := h.running, img := h.img, bound := h.bound }

/-- A state relation at another target native state. -/
theorem relF_swapT {FR FR' : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64}
    {K : Ctx} {s t : St FF.S} {S : SSrv} {C : CSrv} {f : FF.S} (h : RelF FF FR W M ν K s S t C)
    (hf : FR' M S.tab.length s.ffi f) : RelF FF FR' W M ν K s S (t.setFfi f) C :=
  { h with ffi := hf }

/-- **The hand-off from a cut with a log base.** -/
theorem full_handoffTbL (L : List Effect) (NB : Nat) {Pp P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64}
    {K1 : Ctx} {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    {tk : NumV} {τ : List NumV}
    (hb : Pp.NL = Pp.N0) (hlo : P0.lo = Pp.lo) (hE : P0.E = Pp.E) (hNE : P0.NE = Pp.NE) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FRL L (FullRXD { Pp with rest := r } NB)) W M1 ν K1 s1 S1 t1 C1)
    (hx : (mlxOf s1.ffi).tokens = [tk] ++ τ)
    (hne : (s1.setFfi (fullSetTokens s1.ffi [tk])).ffi ≠ s0.ffi)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftH P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 (s1.setFfi (fullSetTokens s1.ffi [tk])) S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P0.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P0 (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRFb (bridgeOf t1.ffi) { P0 with rest := τ.map M1.nv ++ r } NB) W
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next) (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 (s1.setFfi (fullSetTokens s1.ffi [tk])), s0.trace, t1.trace, t1.next - s0.next,
        K1.lo, K1.hi⟩ s0 S0 t1 C1 := by
  obtain ⟨y0, ps, e, -, hr⟩ := h1.ffi
  have hl : toLoad t1.ffi = toLoad y0 := by rw [e]; rfl
  rw [hl] at hroomN
  have hn : (mlxOf t1.ffi).next = (mlxOf y0).next := by rw [e]; rfl
  have h1' : RelF FF (FullRXD { Pp with rest := r } NB) W M1 ν K1 s1 S1 (t1.setFfi y0) C1 := relF_swapT h1 hr
  have h := full_handoffT NB hb hlo hE hNE hNB h1' hx hne hshift hbig hfree hband hg hroom hroomN
  rw [hn]
  have hf : FullRFb (bridgeOf t1.ffi) { P0 with rest := τ.map M1.nv ++ r } NB
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf y0).next) S0.tab.length s0.ffi t1.ffi := by
    rw [e]
    have hb0 := h.ffi
    exact ⟨hb0.load, ⟨bridgeF_fF hb0.bridge, rfl⟩, hb0.live, hb0.kern, hb0.pend⟩
  exact { h with ffi := hf }

end Host.Ts.Sim.Conv
