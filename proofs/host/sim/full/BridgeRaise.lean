import host.sim.full.BridgeA
import host.sim.full.Raise

/-! # The full world's relation with the bridge at a raise

`FullRXD`: `FullRX` (the bridge inactive and equal, or active under the map) at a raise of `P`, with
its laws, reads and native facts, from `FullRB`'s at the raise. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim

/-- `FullRB` at the band of a band-free `P` raised to at most the template's node counter. -/
theorem FullRB.raise {BR : Map → FF.S → FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S}
    (hr : FullRB BR P NB M n x y) (hb : P.NL = P.N0) {k : Nat} (hk0 : P.N0 ≤ k) (hk : k ≤ (mlxOf x).nnext) :
    FullRB BR (P.raise k) NB M n x y :=
  ⟨hr.load.raise hb hk0 hk, hr.bridge, hr.live, hr.kern, hr.pend⟩

/-- **`FullRX` at a raise of `P`.** -/
def FullRXD (P : LoadP) (NB : Nat) (M : Map) (n : Nat) (x y : FF.S) : Prop :=
  ∃ P', Raised P P' ∧ FullRX P' NB M n x y

theorem FullRX.toXD {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRX P NB M n x y) :
    FullRXD P NB M n x y := ⟨P, .inl rfl, h⟩

theorem FullRD.toXD {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRD P NB M n x y) :
    FullRXD P NB M n x y := by
  obtain ⟨P', hP, h⟩ := h
  exact ⟨P', hP, h.toX⟩

/-- A band-free `P`'s raise to the template's node counter, from any raise of it. -/
theorem FullRXD.top {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRXD P NB M n x y)
    (hb : P.NL = P.N0) : FullRX (P.raise (mlxOf x).nnext) NB M n x y ∧ Raised P (P.raise (mlxOf x).nnext) := by
  obtain ⟨P', hP, hr⟩ := h
  have hP' : P'.NL = P'.N0 ∧ P.N0 ≤ P'.N0 ∧ P'.raise (mlxOf x).nnext = P.raise (mlxOf x).nnext := by
    rcases hP with rfl | ⟨k, -, hk, rfl⟩
    · exact ⟨hb, Nat.le_refl _, rfl⟩
    · exact ⟨rfl, hk, rfl⟩
  obtain ⟨hb1, hb2, hb3⟩ := hP'
  have hn : P'.N0 ≤ (mlxOf x).nnext := hr.load.mlx.nband.2
  refine ⟨?_, .inr ⟨(mlxOf x).nnext, hb, Nat.le_trans hb2 hn, rfl⟩⟩
  rw [← hb3]
  exact hr.raise hb1 hn (Nat.le_refl _)

/-- Without a band-free `P`, its only raise is itself. -/
theorem FullRXD.self {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRXD P NB M n x y)
    (hb : P.NL ≠ P.N0) : FullRX P NB M n x y := by
  obtain ⟨P', hP, hr⟩ := h
  rcases hP with rfl | ⟨k, hb', -, -⟩
  · exact hr
  · exact absurd hb' hb

theorem fullRXD_laws (P : LoadP) (NB : Nat) : FRLaws (F := FF) (FullRXD P NB) :=
  ⟨fun M M' n x y hr he => by
      obtain ⟨P', hP, hr⟩ := hr
      exact ⟨P', hP, (fullRX_laws P' NB).stable M M' n x y hr he⟩,
   fun M n n' x y hr hn => by
      obtain ⟨P', hP, hr⟩ := hr
      exact ⟨P', hP, (fullRX_laws P' NB).mono M n n' x y hr hn⟩⟩

/-- The native interface's reads at a raise. -/
theorem fullFfiSimXD (P : LoadP) (NB : Nat) :
    FfiSim FF (FullRXD P NB) (fun _ _ _ => false) (fun _ _ => false) where
  call := fun _ _ _ _ _ _ _ _ _ _ h => absurd h (by simp)
  back := fun _ _ _ _ _ _ _ _ _ h => absurd h (by simp)
  read := fun M n x y r off k bs hr hx => by
    obtain ⟨P', -, hr⟩ := hr
    exact (fullFfiSim (BR := BridgeX) P' NB).read M n x y r off k bs hr hx

theorem fullNativeFactsXD (P : LoadP) (NB : Nat) (J : Disp.JSP FF) (hlo : J.lo = P.lo)
    (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion) : Disp.NativeFacts FF (FullRXD P NB) J where
  zero := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeX) P' NB J (hlo.trans hP.lo.symm) hh hg).zero M n x y hr
  inj := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeX) P' NB J (hlo.trans hP.lo.symm) hh hg).inj M n x y hr
  region := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeX) P' NB J (hlo.trans hP.lo.symm) hh hg).region M n x y hr
  range := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeX) P' NB J (hlo.trans hP.lo.symm) hh hg).range M n x y hr
  host := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeX) P' NB J (hlo.trans hP.lo.symm) hh hg).host M n x y hr
  cb := fun M n x y hr => by
    obtain ⟨P', hP, hr⟩ := hr
    exact (fullNativeFacts (BR := BridgeX) P' NB J (hlo.trans hP.lo.symm) hh hg).cb M n x y hr

end Host.Ts.Sim.Full
