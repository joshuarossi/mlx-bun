import host.sim.full.BridgeRaise

namespace Host.Ts.Sim.G

section
variable {P : LoadP} {NB : Nat} {M : Map} {n lo : Nat} {x y : NSt}

/-- Change only the handle boundary, with its three map and counter obligations supplied. -/
theorem MRw.withLo (h : MRw P NB M n x y) (hlo : 0 < lo)
    (hfix : ∀ i : Int, i < lo → M.big i = i)
    (hband : ∀ k, PH x k → lo ≤ k → lo ≤ M.handle k) (hnext : lo ≤ x.next) :
    MRw { P with lo := lo } NB M n x y :=
  { h with lo := hlo, bigFix := hfix, hband := hband, hnext := ⟨hnext, h.hnext.2⟩ }

theorem MR.withLo (h : MR P NB M n x y) (hlo : 0 < lo)
    (hfix : ∀ i : Int, i < lo → M.big i = i)
    (hband : ∀ k, PH x k → lo ≤ k → lo ≤ M.handle k) (hnext : lo ≤ x.next) :
    MR { P with lo := lo } NB M n x y :=
  { h.toMRw.withLo hlo hfix hband hnext with hfreshB := h.hfreshB, tokensX := h.tokensX }

theorem LoadR.withLo {x y : Host.Load.LSt} (h : LoadR P NB M n x y) (hlo : 0 < lo)
    (hfix : ∀ i : Int, i < lo → M.big i = i)
    (hband : ∀ k, PH x.mlx k → lo ≤ k → lo ≤ M.handle k) (hnext : lo ≤ x.mlx.next) :
    LoadR { P with lo := lo } NB M n x y :=
  ⟨h.host, h.hostReg, h.hostLt, h.cbr, h.mlx.withLo hlo hfix hband hnext⟩

end
end Host.Ts.Sim.G

namespace Host.Ts.Sim.Full

section
variable {P : LoadP} {NB : Nat} {M : Map} {n lo : Nat} {x y : FF.S}

/-- The observer and bridge layers are independent of the handle boundary. -/
theorem FullRB.withLo {BR : Map → FF.S → FF.S → Prop} (h : FullRB BR P NB M n x y) (hlo : 0 < lo)
    (hfix : ∀ i : Int, i < lo → M.big i = i)
    (hband : ∀ k, PH (mlxOf x) k → lo ≤ k → lo ≤ M.handle k) (hnext : lo ≤ (mlxOf x).next) :
    FullRB BR { P with lo := lo } NB M n x y :=
  ⟨h.load.withLo hlo hfix hband hnext, h.bridge, h.live, h.kern, h.pend⟩

/-- Change the handle boundary at any raise, preserving the active bridge and the map. -/
theorem FullRXD.withLo (h : FullRXD P NB M n x y) (hlo : 0 < lo)
    (hfix : ∀ i : Int, i < lo → M.big i = i)
    (hband : ∀ k, PH (mlxOf x) k → lo ≤ k → lo ≤ M.handle k) (hnext : lo ≤ (mlxOf x).next) :
    FullRXD { P with lo := lo } NB M n x y := by
  obtain ⟨P', hP, h⟩ := h
  refine ⟨{ P' with lo := lo }, ?_, h.withLo hlo hfix hband hnext⟩
  rcases hP with rfl | ⟨k, hb, hk, rfl⟩
  · exact .inl rfl
  · exact .inr ⟨k, hb, hk, rfl⟩

end
end Host.Ts.Sim.Full
