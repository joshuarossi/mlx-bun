import host.sim.conv.TraceRestart
import host.sim.conv.CompactBridge
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers

/-! # A compaction that renames nodes above `NB`

`FullShiftQB` over `TraceNShift`, the shift of a class whose compiled traces sit at other node numbers than the template's: nodes below `NB`
keep their numbers, those above follow the map, in order along their inputs. The composition is `fsnQBD_compose`'s. -/

/-- **The compaction's native shift with the bridge part `BS`, renaming nodes above `NB`.** -/
structure FullShiftTB (BS : Map → FF.S → FF.S → Prop) (P : LoadP) (NB n0 : Nat) (σ : Map) (x0 x1 : FF.S) : Prop where
  load : TraceNShift P NB n0 σ (clearTokens (toLoad x0)) (clearTokens (toLoad x1))
  tokens : (mlxOf x1).tokens = (mlxOf x0).tokens.map σ.nv
  tokSupp : ∀ t ∈ (mlxOf x0).tokens, Host.Ts.Sim.SN (· < n0) t
  bridge : BS σ x0 x1
  live : LiveShift σ (mlxOf x0) (mlxOf x1) (freedOf x0) (freedOf x1)
  kern : KernShift σ n0 (mlxOf x0) (mlxOf x1) (krecOf x0) (krecOf x1)
  pend : G.PendReg σ (mlxOf x0) (mlxOf x1)

theorem FullShiftTB.withRest {BS : Map → FF.S → FF.S → Prop} {P : LoadP} {NB n0 : Nat} {σ : Map} {x0 x1 : FF.S}
    (h : FullShiftTB BS P NB n0 σ x0 x1) (r : List NumV) : FullShiftTB BS { P with rest := r } NB n0 σ x0 x1 :=
  { h with load := h.load.withRest r }

/-- The shift with the bridge renamed. -/
abbrev FullShiftTX : LoadP → Nat → Nat → Map → FF.S → FF.S → Prop := FullShiftTB BridgeX

/-- The shift from the canonical start `x0`. -/
def FSnTB (BS : Map → FF.S → FF.S → Prop) (P : LoadP) (NB n0 : Nat) (x0 : FF.S) : Map → FF.S → FF.S → Prop :=
  fun σ x y => x = x0 ∧ FullShiftTB BS P NB n0 σ x y

section
variable {BR BS : Map → FF.S → FF.S → Prop}

/-- `fsnQBD_compose` for a shift renaming nodes above `NB`. -/
theorem fsnTBD_compose (hc : ShiftComp BS BR) {P P0 : LoadP} {NB n0 n1 : Nat} {x0 : FF.S} {σ : Map}
    (hP0 : Raised P P0) :
    ∀ M x y z, FSnTB BS P0 NB n0 x0 σ x y → FRrFBD BR P NB x0 M n1 y z → FRrFBD BR P NB x0 (M.after σ) n0 x z := by
  rintro M x y z ⟨hx, hs⟩ ⟨P1, hP1, ⟨hr, hroom⟩, hb, hl, hk, hp⟩
  obtain ⟨hlo, hE, hNE, hF⟩ := hP0.restart hP1
  have hroom0 : NRoom P0 (toLoad x0) (toLoad z) := by
    unfold NRoom at hroom ⊢; rw [← hE, ← hNE]; exact hroom
  subst x0
  have hm := hs.load.mlx
  have hobj : ∀ h, ((mlxOf x).objs.get h).isSome = true → ((mlxOf y).objs.get (σ.handle h)).isSome = true := fun h hh => by
    have e := hm.objs h (.inr hh)
    show ((mlxOf y).objs.get (σ.handle h)).isSome = true
    have e' : (mlxOf y).objs.get (σ.handle h) = ((mlxOf x).objs.get h).map σ.nobj := e
    rw [e']
    cases hg : (mlxOf x).objs.get h with
    | none => rw [hg] at hh; cases hh
    | some o => rfl
  refine ⟨P0, hP0, ⟨?_, hroom0⟩, hc σ M x y z hs.bridge hm.nall hb, ?_, ?_,
    hp.after hs.pend hm.pending hm.nonneg hr.mlx.hnext.2⟩
  · have := traceNShift_restartR hs.load hr hlo hE hNE hF hroom0
    rwa [clearTokens_idem] at this
  · intro fx0 e0
    obtain ⟨fx1, e1, hf⟩ := hs.live fx0 e0
    obtain ⟨fz, ez, hfz⟩ := hl fx1 e1
    exact ⟨fz, ez, FreedR.restartC hm.nonneg hobj hf hfz⟩
  · intro k0 e0
    obtain ⟨k1, e1, hk1⟩ := hs.kern k0 e0
    obtain ⟨kz, ez, hkz⟩ := hk k1 e1
    exact ⟨kz, ez, KRecR.restartC hm.nonneg hobj hk1 hkz⟩

end

end Host.Ts.Sim.Conv
