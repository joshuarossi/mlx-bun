import host.sim.conv.CompactBridge
import host.sim.full.BridgeFrameCall
import host.sim.full.DropTokens

/-! # The prefill → decode hand-off

The prefill's last cut relates its template's end `s1` to the target at a band-free `Pp`
(`FullRXD`, the bridge inactive and equal or active under the map). The decode template's start `s0`
(`DT.s0'`, from a short prompt: its bridge inactive) runs at the banded decode parameters `P0` against
the target with its bridge framed (`FullRF`). The hand-off is a compaction from `s0` to `s1` at `P0`
(`full_handoff`): the shift's native part at `P0` composes with the end relation at any raise of `Pp`
across the bands (`G.loadRw_restartR`: every node of `P0` is fully corresponding at a band-free raise,
the bounds equal, the start's recorded traces below `P0.NL` by the shift's `traced`); its bridge part
(`BH`) is the start's inactive bridge with the end's equal to it, or active with nothing scheduled or
running and no alias at the shift's images of the start's nodes, so the target's bridge, related to the
end's, is quiet for the start (`bridgeF_of_handoffX`). The template's abstract readback suffix moves
into the target's remaining readbacks first (`FullRXD.dropTokens`, `full_handoffT`). -/

namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers

/-! ## The token suffix at the bridge relation -/

theorem bridgeX_setTokens {M : Map} {x y : FF.S} (h : BridgeX M x y) (ts : List NumV) :
    BridgeX M (fullSetTokens x ts) y := by
  rcases h with h | ⟨ha, hA⟩
  · exact .inl h
  · exact .inr ⟨ha, ⟨hA.rel, hA.dense⟩⟩

theorem _root_.Host.Ts.Sim.Full.FullRX.dropTokens {P : LoadP} {NB : Nat} {r : List NumV} {M : Map} {n : Nat}
    {x y : FF.S} {live τ : List NumV} (hr : FullRX { P with rest := r } NB M n x y)
    (hx : (mlxOf x).tokens = live ++ τ) :
    FullRX { P with rest := τ.map M.nv ++ r } NB M n (fullSetTokens x live) y :=
  ⟨G.LoadR.dropTokens hr.load hx, bridgeX_setTokens hr.bridge live, hr.live.ofObjs rfl, hr.kern.ofObjs rfl,
    hr.pend.congr rfl rfl⟩

theorem _root_.Host.Ts.Sim.Full.FullRXD.dropTokens {P : LoadP} {NB : Nat} {r : List NumV} {M : Map} {n : Nat}
    {x y : FF.S} {live τ : List NumV} (hr : FullRXD { P with rest := r } NB M n x y)
    (hx : (mlxOf x).tokens = live ++ τ) :
    FullRXD { P with rest := τ.map M.nv ++ r } NB M n (fullSetTokens x live) y := by
  obtain ⟨P', hP, hr'⟩ := hr
  have hrest : P'.rest = r := hP.rest
  have h2 := FullRX.dropTokens (P := P') (r := P'.rest) hr' hx
  rw [hrest] at h2
  exact ⟨_, hP.withRest _, h2⟩

/-- `FullRXD.dropTokens` at a state relation. -/
theorem RelF.dropTokensX {P : LoadP} {NB : Nat} {r : List NumV} {W : Nat → Option WFrame} {M : Map}
    {ν : Nat → F64} {K : Ctx} {s t : St FF.S} {S : SSrv} {C : CSrv} {live τ : List NumV}
    (h : RelF FF (FullRXD { P with rest := r } NB) W M ν K s S t C) (hx : (mlxOf s.ffi).tokens = live ++ τ) :
    RelF FF (FullRXD { P with rest := τ.map M.nv ++ r } NB) W M ν K (s.setFfi (fullSetTokens s.ffi live)) S t C :=
  { h with ffi := FullRXD.dropTokens h.ffi hx }

/-! ## The hand-off shift -/

/-- **The hand-off's bridge part**: the start's bridge inactive, the end's equal to it, or active with
nothing scheduled or running and no alias at the shift's images of the start's nodes. -/
def BH (σ : Map) (x0 x1 : FF.S) : Prop :=
  (bridgeOf x0).active = false ∧
    (bridgeOf x1 = bridgeOf x0 ∨ ((bridgeOf x1).active = true ∧ (bridgeOf x1).unscheduled = [] ∧
      (bridgeOf x1).running = [] ∧ ∀ j, j < (mlxOf x0).nnext → (bridgeOf x1).aliases.get (σ.node j) = none))

/-- **The hand-off's native shift**: a compaction's (`FullShiftQB`) with the bridge part `BH`. -/
abbrev FullShiftH (P : LoadP) (n0 : Nat) (σ : Map) (x0 x1 : FF.S) : Prop := FullShiftQB BH P n0 σ x0 x1

/-- The hand-off's native shift from the decode start `x0`. -/
def FSnH (P : LoadP) (n0 : Nat) (x0 : FF.S) : Map → FF.S → FF.S → Prop :=
  fun σ x y => x = x0 ∧ FullShiftH P n0 σ x y

/-- The hand-off's restart relation: at the start the frame at `P0`, elsewhere the end's at a raise of `Pp`. -/
def FRrH (Pp P0 : LoadP) (NB : Nat) (x0 : FF.S) : Map → Nat → FF.S → FF.S → Prop :=
  fun M n x z => (x = x0 → FRrFB BridgeF P0 NB x0 M n x z) ∧ (x ≠ x0 → FRrFXD Pp NB x0 M n x z)

/-- **The target's bridge, related to the end's, is quiet for the start.** -/
theorem bridgeF_of_handoffX {σ M : Map} {x0 x1 z : FF.S} (hs : BH σ x0 x1) (hb : BridgeX M x1 z)
    (hall : ∀ j, j < (mlxOf x0).nnext → σ.node j < (mlxOf x1).nnext) : BridgeF (M.after σ) x0 z := by
  refine ⟨hs.1, ?_⟩
  rcases hs.2 with he | ⟨ha, hu, hrun, hal⟩
  · rcases hb with hb | ⟨ha', -⟩
    · left; rw [hb.1, he]; exact hs.1
    · rw [he, hs.1] at ha'; cases ha'
  · rcases hb with hb | ⟨-, hA⟩
    · rw [hb.2] at ha; cases ha
    · right
      exact
        { unscheduled := by rw [hA.rel.unscheduled, hu]; rfl
          running := by rw [hA.rel.running, hrun]; rfl
          img := fun j hj => by
            show (bridgeOf z).aliases.get (M.node (σ.node j)) = none
            rw [hA.rel.aliases _ (hall j hj)]; exact hal j hj
          bound := fun m hm => hA.rel.aliasY m hm }

/-- The frame at the start composes with a hand-off shift from the start to itself. -/
theorem bridgeF_of_handoffF {σ M : Map} {x0 x1 z : FF.S} (hs : BH σ x0 x1) (hb : BridgeF M x1 z)
    (hall : ∀ j, j < (mlxOf x0).nnext → σ.node j < (mlxOf x1).nnext) : BridgeF (M.after σ) x0 z := by
  rcases hs.2 with he | ⟨ha, -⟩
  · exact shiftComp_F σ M x0 x1 z he hall hb
  · rw [hb.1] at ha; cases ha

/-- **The hand-off's composition**: the shift at `P0` with the end relation at a raise of a band-free
`Pp` of the same bounds, or with the frame at `P0`. -/
theorem fsnH_compose {Pp P0 : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map} (hb : Pp.NL = Pp.N0)
    (hlo : P0.lo = Pp.lo) (hE : P0.E = Pp.E) (hNE : P0.NE = Pp.NE) (hNB : NB ≤ P0.NL) :
    ∀ M x y z, FSnH P0 n0 x0 σ x y → FRrH Pp P0 NB x0 M n1 y z → FRrH Pp P0 NB x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨rfl, hs⟩ ⟨hy0, hy1⟩
  refine ⟨fun _ => ?_, fun h => absurd rfl h⟩
  have hm := hs.load.mlx
  have hobj : ∀ h, ((mlxOf x).objs.get h).isSome = true → ((mlxOf y).objs.get (σ.handle h)).isSome = true :=
    fun h hh => obj_shift hm hh
  by_cases hyx : y = x
  · subst hyx
    obtain ⟨⟨hr, hroom⟩, hbr, hl, hk, hp⟩ := hy0 rfl
    refine ⟨⟨?_, hroom⟩, bridgeF_of_handoffF hs.bridge hbr hm.nall, ?_, ?_,
      hp.after hs.pend hm.pending hm.nonneg hr.mlx.hnext.2⟩
    · have := G.loadRw_restart hs.load hr hroom
      rwa [clearTokens_idem] at this
    · intro fx0 e0
      obtain ⟨fx1, e1, hf⟩ := hs.live fx0 e0
      obtain ⟨fz, ez, hfz⟩ := hl fx1 e1
      exact ⟨fz, ez, FreedR.restartC hm.nonneg hobj hf hfz⟩
    · intro k0 e0
      obtain ⟨k1, e1, hk1⟩ := hs.kern k0 e0
      obtain ⟨kz, ez, hkz⟩ := hk k1 e1
      exact ⟨kz, ez, KRecR.restartC hm.nonneg hobj hk1 hkz⟩
  · obtain ⟨P1, hP1, ⟨hr, hroom⟩, hbr, hl, hk, hp⟩ := hy1 hyx
    have hb1 : ∀ {Q : LoadP}, Raised Pp Q → Q.lo = Pp.lo ∧ Q.E = Pp.E ∧ Q.NE = Pp.NE ∧ Q.NL = Q.N0 := by
      intro Q h; rcases h with rfl | ⟨k, -, -, rfl⟩
      · exact ⟨rfl, rfl, rfl, hb⟩
      · exact ⟨rfl, rfl, rfl, rfl⟩
    obtain ⟨l1, e1, n1', b1⟩ := hb1 hP1
    have hF : ∀ j, Full P0 j → Full P1 j := fun j _ => by show j < P1.NL ∨ P1.N0 ≤ j; omega
    have hroom0 : NRoom P0 (toLoad x) (toLoad z) := by
      unfold NRoom at hroom ⊢; rw [hE, hNE, ← e1, ← n1']; exact hroom
    refine ⟨⟨?_, hroom0⟩, bridgeF_of_handoffX hs.bridge hbr hm.nall, ?_, ?_,
      hp.after hs.pend hm.pending hm.nonneg hr.mlx.hnext.2⟩
    · have := G.loadRw_restartR hs.load hr (by rw [l1, hlo]) (by rw [e1, hE]) (by rw [n1', hNE]) hF hNB hroom0
      rwa [clearTokens_idem] at this
    · intro fx0 e0
      obtain ⟨fx1, e1, hf⟩ := hs.live fx0 e0
      obtain ⟨fz, ez, hfz⟩ := hl fx1 e1
      exact ⟨fz, ez, FreedR.restartC hm.nonneg hobj hf hfz⟩
    · intro k0 e0
      obtain ⟨k1, e1, hk1⟩ := hs.kern k0 e0
      obtain ⟨kz, ez, hkz⟩ := hk k1 e1
      exact ⟨kz, ez, KRecR.restartC hm.nonneg hobj hk1 hkz⟩

/-! ## The hand-off -/

/-- **The prefill → decode hand-off**: the prefill's last cut at a raise of the band-free `Pp` (the
template's end `s1`, its token queue the shift's image of the decode start's) gives the decode start
`s0` related at the banded `P0` with the target's bridge framed, under the compaction map. -/
theorem full_handoff (NB : Nat) {Pp P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    (hb : Pp.NL = Pp.N0) (hlo : P0.lo = Pp.lo) (hE : P0.E = Pp.E) (hNE : P0.NE = Pp.NE) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRXD { Pp with rest := r } NB) W M1 ν K1 s1 S1 t1 C1) (hne : s1.ffi ≠ s0.ffi)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftH P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 s1 S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P0.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P0 (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRF { P0 with rest := r } NB) W
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next) (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t1 C1 := by
  have hsh : FullShiftH { P0 with rest := r } S0.tab.length κ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  obtain ⟨P1, hP1, h1f⟩ := h1.ffi
  have hb1 : P1.E = Pp.E ∧ P1.NE = Pp.NE := by
    rcases hP1 with rfl | ⟨k, -, -, rfl⟩ <;> exact ⟨rfl, rfl⟩
  have hroomN1 : NRoom P1 (toLoad s0.ffi) (toLoad t1.ffi) := by
    unfold NRoom at hroomN ⊢; rw [hb1.1, hb1.2, ← hE, ← hNE]; exact hroomN
  have hf : FRrH { Pp with rest := r } { P0 with rest := r } NB s0.ffi M1 S1.tab.length s1.ffi t1.ffi :=
    ⟨fun h => absurd h hne, fun _ => ⟨P1, hP1, ⟨h1f.load.weak.clear, hroomN1⟩, h1f.bridge, h1f.live, h1f.kern,
      h1f.pend⟩⟩
  have h2 := h1.mapFR' (FR' := FRrH { Pp with rest := r } { P0 with rest := r } NB s0.ffi) hf
  have hshift' : ShiftD FF (FSnH { P0 with rest := r } S0.tab.length s0.ffi) κ θ (kpOf K1 W) W K1 s0 S0 s1 S1 :=
    { hshift with ffi := ⟨hshift.ffi.1, hsh⟩ }
  have hrel := compact (FS := FSnH { P0 with rest := r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => fsnH_compose (Pp := { Pp with rest := r }) (P0 := { P0 with rest := r }) hb hlo hE hNE hNB _ x y z hxy hyz) h2
    hshift' hg hroom
  obtain ⟨⟨hw0, -⟩, hb0, hl0, hk0, hp0⟩ := hrel.ffi.1 rfl
  have hz : (toLoad t1.ffi).mlx.tokens = (toLoad s0.ffi).mlx.tokens.map (M1.after κ).nv ++ r := by
    have h' : (mlxOf t1.ffi).tokens = (mlxOf s1.ffi).tokens.map M1.nv ++ P1.rest := h1f.load.mlx.tokensX
    rw [show P1.rest = r from hP1.rest, hsh.tokens, List.map_map] at h'
    show (mlxOf t1.ffi).tokens = (mlxOf s0.ffi).tokens.map (M1.after κ).nv ++ r
    rw [h']
    congr 1
    exact List.map_congr_left fun t _ => Map.nv_after M1 κ t
  have hld := G.LoadRw.rebig hw0 hbig hsh.tokSupp hz
  have hobj : ∀ h, ((mlxOf s0.ffi).objs.get h).isSome = true →
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next).handle h = (M1.after κ).handle h :=
    fun h hh => rebig_handle _ _ _ _ (hw0.mlx.hlt h (.inr hh))
  have hffi : FullRF { P0 with rest := r } NB ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next)
      S0.tab.length s0.ffi t1.ffi :=
    ⟨hld, bridgeF_names _ _ _ _ hb0 rfl, hl0.rebig hobj, hk0.rebig hobj rfl, hp0.rebig _ _⟩
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

/-- **The hand-off from the prefill's last cut with the template's readback suffix**: the suffix `τ`
after the queue's head `tk` moves into the target's remaining readbacks (`RelF.dropTokensX`), then
`full_handoff` from the end with the head alone. -/
theorem full_handoffT (NB : Nat) {Pp P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    {tk : NumV} {τ : List NumV}
    (hb : Pp.NL = Pp.N0) (hlo : P0.lo = Pp.lo) (hE : P0.E = Pp.E) (hNE : P0.NE = Pp.NE) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRXD { Pp with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
    (hx : (mlxOf s1.ffi).tokens = [tk] ++ τ)
    (hne : (s1.setFfi (fullSetTokens s1.ffi [tk])).ffi ≠ s0.ffi)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShiftH P0 S0.tab.length σ x y) κ θ (kpOf K1 W) W K1
      s0 S0 (s1.setFfi (fullSetTokens s1.ffi [tk])) S1)
    (hbig : bigsOutB (mlxOf s0.ffi).next P0.E (mlxOf s0.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E) s0.trace s0)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P0.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t1.next - s0.next < Sim.bound)
    (hroomN : NRoom P0 (toLoad s0.ffi) (toLoad t1.ffi)) :
    RelF FF (FullRF { P0 with rest := τ.map M1.nv ++ r } NB) W
      ((M1.after κ).rebig (mlxOf s0.ffi).next P0.E (mlxOf t1.ffi).next) (Shift.valuation θ ν)
      ⟨Shift.framedNext M1 K1 (s1.setFfi (fullSetTokens s1.ffi [tk])), s0.trace, t1.trace, t1.next - s0.next,
        K1.lo, K1.hi⟩ s0 S0 t1 C1 :=
  full_handoff NB hb hlo hE hNE hNB (RelF.dropTokensX h1 hx) hne hshift hbig hfree hband hg hroom hroomN

/-- `full_handoffT` with the target's bridge pinned to its value at the hand-off (`fullWorldFb`). -/
theorem full_handoffTb (NB : Nat) {Pp P0 : LoadP} {r : List NumV} {M1 κ : Map} {ν : Nat → F64} {K1 : Ctx}
    {W : Nat → Option WFrame} {s0 s1 t1 : St FF.S} {S0 S1 : SSrv} {C1 : CSrv} {θ : Nat → SymE}
    {tk : NumV} {τ : List NumV}
    (hb : Pp.NL = Pp.N0) (hlo : P0.lo = Pp.lo) (hE : P0.E = Pp.E) (hNE : P0.NE = Pp.NE) (hNB : NB ≤ P0.NL)
    (h1 : RelF FF (FullRXD { Pp with rest := r } NB) W M1 ν K1 s1 S1 t1 C1)
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
        K1.lo, K1.hi⟩ s0 S0 t1 C1 :=
  have h := full_handoffT NB hb hlo hE hNE hNB h1 hx hne hshift hbig hfree hband hg hroom hroomN
  { h with ffi := h.ffi.pin }

end Host.Ts.Sim.Conv
