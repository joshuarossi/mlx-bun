import host.sim.footprint.Core
import host.sim.footprint.Full
import host.sim.conv.NativeMerge

namespace Host.Mlx.Ffi.Footprint
open Host.Ts Host.Ts.Sim Host.Ts.Sim.G

/-- A native node of an isolated state is present at its caller image. -/
theorem iso_node_present {P0 P1 : LoadP} {n0 : Nat} {σ : Map} {x0 x1 : NSt}
    (iso : MIso P0 P1 n0 σ x0 x1) {i : Nat} (hi : PN x0 i) : PN x1 (σ.node i) := by
  cases hn : x0.nodes.get i with
  | none => unfold PN at hi; rw [hn] at hi; cases hi
  | some nd =>
    obtain ⟨nd', he, _⟩ := iso.nodes i nd hn
    show (x1.nodes.get (σ.node i)).isSome = true
    rw [he]; rfl

/-- Writes supported on images of the isolated start cannot touch caller-only entries.
The caller's current native relation provides bounds and injectivity; the actual footprint
provides preservation, including all old nodes. No endpoint-frozen premise is required. -/
theorem Writes.nfrozen {H I : Nat → Prop} {P0 P1 : LoadP} {NB n0 n1 : Nat}
    {M σ : Map} {x0 x1 y y' : NSt} (w : Writes H I y y')
    (hr : MRw P1 NB M n1 x1 y) (iso : MIso P0 P1 n0 σ x0 x1)
    (hh : ∀ h, h < y.next → H h → ∃ h0, PH x0 h0 ∧ h = M.handle (σ.handle h0))
    (hi : ∀ i, i < y.nnext → I i → ∃ i0, PN x0 i0 ∧ i = M.node (σ.node i0)) :
    NFrozen M σ x0 x1 y y' := by
  have hH : ∀ h, PH x1 h → (∀ h0, PH x0 h0 → σ.handle h0 ≠ h) → ¬ H (M.handle h) := by
    intro h hp hout hw
    obtain ⟨h0, hp0, he⟩ := hh _ (hr.himg h hp).2 hw
    exact hout h0 hp0 (hr.hinj _ _ (iso.present h0 hp0).2 hp he.symm)
  have hI : ∀ i, PN x1 i → (∀ i0, PN x0 i0 → σ.node i0 ≠ i) → ¬ I (M.node i) := by
    intro i hp hout hw
    obtain ⟨i0, hp0, he⟩ := hi _ (hr.nimg i hp) hw
    exact hout i0 hp0 (hr.ninj _ _ (iso_node_present iso hp0) hp he.symm)
  exact ⟨fun h hp hout => w.arrs _ (hr.himg h hp).2 (hH h hp hout),
    fun h hp hout => w.objs _ (hr.himg h hp).2 (hH h hp hout), w.nodes,
    fun i hp hout => w.items _ (hI i hp hout)⟩

/-- An actual full-world array call supplies `NFrozen` when its old output support belongs
to the isolated start. Fresh writes are harmless and readback items are not written. -/
theorem fullCall_array_nfrozen {P0 P1 : LoadP} {NB n0 n1 : Nat} {M σ : Map} {x0 x1 : NSt}
    (p q : Host.Ts.Sim.Full.FF.S) (name : Name) (args : List Arg)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name FfiAne.payloadName = false)
    (ha : (symOf name).any ArraySym = true)
    (hr : MRw P1 NB M n1 x1 (Host.Ts.Sim.Full.mlxOf p)) (iso : MIso P0 P1 n0 σ x0 x1)
    (hout : ∀ h, h < (Host.Ts.Sim.Full.mlxOf p).next → Output args h →
      ∃ h0, PH x0 h0 ∧ h = M.handle (σ.handle h0))
    {C C' : CSrv} {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (hc : interpC (Host.Ts.Sim.Full.FF.call p name args).run C = some (some (q, r, ws), C')) :
    NFrozen M σ x0 x1 (Host.Ts.Sim.Full.mlxOf p) (Host.Ts.Sim.Full.mlxOf q) := by
  have w := (fullCall_array_w p name args hm hp ha).2 C _ C' hc q r ws rfl
  exact w.nfrozen hr iso hout (fun _ _ hi => hi.elim)

end Host.Mlx.Ffi.Footprint
