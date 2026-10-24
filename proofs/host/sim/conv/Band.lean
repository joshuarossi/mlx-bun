import host.sim.conv.Iso
import host.sim.conv.RegFree
import host.sim.template.Sigma
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The heap clause of a call morphism from the stage footprint only

`Iso.heap` asks, for every present address of the stage template's start `s0`, the caller's entry
at its image. Most of `s0` is the static band (the program's objects since load: modules,
classes, functions, weights), which the call morphism `σ` fixes. `Iso.heap_of_band` derives the
clause from

* once per stage template: the band `Stat`'s entries are closed in the band (`Supp`), free of the
  bigints `I` and regions `R` `σ` may rename (`NoBig`, `NoReg`); the template's other present
  addresses are listed (`foot`);
* per call: the caller holds the template's band entries (`hstat`: the same entries; with the
  stream's shared pages a comparison of page constants), `σ` fixes the band's addresses and
  references and is the identity outside `I` and `R` (checks of `σ`'s exception tables), and the
  footprint's images (`HeapImg σ s0 s foot`, the per-call kernel check proportional to the
  footprint). -/

section
variable {S : Type} {σ : Map} {s0 s : St S} {Stat : Nat → Prop} {n0 : Nat} {I : Int → Prop} {R : Nat → Prop}

/-- **The heap clause from the band and the footprint.** -/
theorem Iso.heap_of_band (hstat : ∀ a, Stat a → s.heap.get a = s0.heap.get a)
    (ha : ∀ x, Stat x → σ.a x = x) (hn : ∀ i, i < n0 → σ.num i = .ref i)
    (hb : ∀ i, ¬ I i → σ.big i = i) (hr : ∀ r, ¬ R r → σ.region r = r)
    (hband : ∀ a h, s0.heap.get a = some h → Stat a → Supp.hobj Stat n0 h ∧ NoBig.hobj I h ∧ NoReg.hobj R h)
    (hfoot : ∀ a h, s0.heap.get a = some h → ¬ Stat a → s.heap.get (σ.a a) = some (σ.hobj h)) :
    ∀ a h, s0.heap.get a = some h → s.heap.get (σ.a a) = some (σ.hobj h) := by
  intro a h hg
  by_cases hs : Stat a
  · obtain ⟨h1, h2, h3⟩ := hband a h hg hs
    rw [ha a hs, hstat a hs, hg, Map.hobj_fix ha hn hb hr h1 h2 h3]
  · exact hfoot a h hg hs

/-- The footprint's images from the per-call `HeapImg` check over the listed footprint. -/
theorem Iso.foot_of_img {foot : List Nat} (himg : HeapImg σ s0 s foot)
    (hcover : ∀ a h, s0.heap.get a = some h → ¬ Stat a → a ∈ foot) :
    ∀ a h, s0.heap.get a = some h → ¬ Stat a → s.heap.get (σ.a a) = some (σ.hobj h) := by
  intro a h hg hs
  rw [himg.mem (hcover a h hg hs), hg]
  rfl

end

end Host.Ts.Sim.Conv
