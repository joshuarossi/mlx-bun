import host.sim.compose.Compact

namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-- Address agreement with the same iteration-start map. -/
def Track {F : Ffi} (extra : List Nat) (x0 x : SegInst F) : Prop :=
  ∀ a ∈ extra, x.M.a a = x0.M.a a

namespace Track
variable {F : Ffi} {extra : List Nat} {x0 x y : SegInst F}

theorem refl (extra : List Nat) (x : SegInst F) : Track extra x x := fun _ _ => rfl

theorem trans (h : Track extra x0 x) (h' : Track extra x y) : Track extra x0 y :=
  fun a ha => (h' a ha).trans (h a ha)

theorem of_ext {n : Nat} (he : Ext x.M y.M n) : Track extra x y :=
  fun a _ => congrFun he.a a

theorem ext (h : Track extra x0 x) {n : Nat} (he : Ext x.M y.M n) : Track extra x0 y :=
  h.trans (of_ext he)

theorem fixed (h : Track extra x0 x) (h0 : ∀ a ∈ extra, x0.M.a a = a) :
    ∀ a ∈ extra, x.M.a a = a := fun a ha => (h a ha).trans (h0 a ha)

theorem of_id (h : Track extra x0 x) (h0 : x0.M = Map.id) :
    ∀ a ∈ extra, x.M.a a = a := h.fixed (fun a _ => by rw [h0]; rfl)

end Track

/-- Refine bookkeeping without changing the cut's source, table or relation. -/
def ICut.withTrack {F : Ffi} (c : ICut F) (extra : List Nat) (x0 : SegInst F) : ICut F :=
  { c with B := fun x => c.B x ∧ Track extra x0 x }

section Ghost
variable {Wd : World} {A : Addr} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA extra : List Nat} {θ : Nat → SymE} {g : GhostP}
  {x0 x : SegInst Wd.F}

theorem IterGhostCW.withTrack (h : IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x)
    (ht : Track extra x0 x) : IterGhostCW Wd A P Fr s0 tab0 (extra ++ fixA) θ g x0 x :=
  { h with fix := fun a ha => (List.mem_append.mp ha).elim (ht a) (h.fix a) }

theorem IterGhostCW.forgetExtra (h : IterGhostCW Wd A P Fr s0 tab0 (extra ++ fixA) θ g x0 x) :
    IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x :=
  { h with fix := fun a ha => h.fix a (List.mem_append.mpr (.inr ha)) }

theorem IterGhostCW.track (h : IterGhostCW Wd A P Fr s0 tab0 (extra ++ fixA) θ g x0 x) :
    Track extra x0 x := fun a ha => h.fix a (List.mem_append.mpr (.inl ha))

theorem IterGhostCW.withTrack_iff :
    IterGhostCW Wd A P Fr s0 tab0 (extra ++ fixA) θ g x0 x ↔
      IterGhostCW Wd A P Fr s0 tab0 fixA θ g x0 x ∧ Track extra x0 x :=
  ⟨fun h => ⟨h.forgetExtra, h.track⟩, fun h => h.1.withTrack h.2⟩

end Ghost

section End
variable {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE}
  {fixA extra : List Nat}

/-- Extend only the checked fixed-address field; every runtime field is unchanged. -/
def IterEndW.withFixed (e : IterEndW Wd A P s0 tab0 fixA) (hσ : ∀ a ∈ extra, e.σ.a a = a) :
    IterEndW Wd A P s0 tab0 (extra ++ fixA) :=
  { e with fix := fun a ha => (List.mem_append.mp ha).elim (hσ a) (e.fix a) }

def IterEndW.forgetExtra (e : IterEndW Wd A P s0 tab0 (extra ++ fixA)) :
    IterEndW Wd A P s0 tab0 fixA :=
  { e with fix := fun a ha => e.fix a (List.mem_append.mpr (.inr ha)) }

variable (e : IterEndW Wd A P s0 tab0 fixA) (hσ : ∀ a ∈ extra, e.σ.a a = a)

theorem IterEndW.withFixed_s1 : (e.withFixed hσ).s1 = e.s1 := rfl
theorem IterEndW.withFixed_S1 : (e.withFixed hσ).S1 = e.S1 := rfl
theorem IterEndW.withFixed_σ : (e.withFixed hσ).σ = e.σ := rfl
theorem IterEndW.withFixed_θ : (e.withFixed hσ).θ = e.θ := rfl
theorem IterEndW.withFixed_grow : (e.withFixed hσ).grow = e.grow := rfl
theorem IterEndW.withFixed_xs : (e.withFixed hσ).xs = e.xs := rfl
theorem IterEndW.withFixed_eR : (e.withFixed hσ).eR = e.eR := rfl
theorem IterEndW.withFixed_rmap (M : Map) (v : NumV) (t : St Wd.F.S) :
    (e.withFixed hσ).rmap M v t = e.rmap M v t := rfl

theorem IterEndW.withFixed_shiftFW (Fr : LoopFramesA A) (W : Nat → Option WFrame) :
    (e.withFixed hσ).ShiftFW Fr W ↔ e.ShiftFW Fr W := Iff.rfl

theorem IterEndW.withFixed_within (g : GhostP) (ΔJ ΔH ΔN : Nat) :
    (e.withFixed hσ).Within g ΔJ ΔH ΔN ↔ e.Within g ΔJ ΔH ΔN := Iff.rfl

/-- The old graph obligation applies after projecting the stronger ghost, at the same restart map. -/
theorem LoopGStepGW.withFixed {Gx : Nat → Map → St Wd.F.S → CSrv → Prop}
    {W : Nat → Option WFrame} {Fr : LoopFramesA A} {g : GhostP} {V : LoopVals}
    {toks : List NumV} {i : Nat} (h : LoopGStepGW Gx W Fr e g V toks i) :
    LoopGStepGW Gx W Fr (e.withFixed hσ) g V toks i := by
  intro hlen nx M K t C n x1 hG hR hfr hlo hhi hrun hghost hR1
  exact h hlen nx M K t C n x1 hG hR hfr hlo hhi hrun hghost.forgetExtra hR1

/-- Repackage the refined endpoint into the stronger ghost without choosing a new pair. -/
theorem iterEndCW_withTrack (W : Nat → Option WFrame) (Fr : LoopFramesA A)
    (toks : List NumV) (g : GhostP) (i : Nat) (x0 : SegInst Wd.F) :
    CutConv ((iterEndCW Wd A W P Fr s0 tab0 fixA toks e g i x0).withTrack extra x0)
      (iterEndCW Wd A W P Fr s0 tab0 (extra ++ fixA) toks (e.withFixed hσ) g i x0) := by
  intro x hR hB
  exact ⟨x, rfl, rfl, hR, hB.1.withTrack hB.2⟩

end End
end Host.Ts.Sim.Prefill

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Load.Layers

/-- The actual compacted pair keeps tracked addresses when its chosen map fixes them. -/
theorem Track.compactPair {extra : List Nat} {x0 x : SegInst FF}
    {sm sc : St FF.S} {κ : Map} {θk : Nat → SymE} {P : LoadP}
    (h : Track extra x0 x) (hκ : ∀ a ∈ extra, κ.a a = a) :
    Track extra x0 (compactPair sm sc κ θk P x) := by
  intro a ha
  change x.M.a (κ.a a) = x0.M.a a
  rw [hκ a ha]
  exact h a ha

end Host.Ts.Sim.Compose
