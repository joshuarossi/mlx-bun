import host.sim.conv.CompactFull
import host.sim.conv.Call
import host.sim.full.World
import host.sim.full.BridgeFrame
import host.sim.world.IterCut
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers Host.Ts.Sim.Prefill Host.Ts.Sim.Template

/-! # A compaction as a conversion of the decode iteration's cuts

A decode case's chain compacts its merged state after a stage call (`host.sim.conv.CompactFull`:
`full_compact`, the full world's compaction). `cut_compact`: **the compaction as a `CutConv`** from a
cut at the merged state `sm` to a cut at the canonical state `sc`, both with the iteration's ghost
(`IterGhostCW`, `host.sim.world.IterCut`): the related pair moves to the compacted map
`(M.after κ).rebig …`, the compaction's valuation `Shift.valuation θk ν` and `full_compact`'s context,
and the ghost to the compacted data `GhostP.compact g sm sc eN` (`IterGhostCW.compact`). The
compaction map `κ` keeps the loop table's numbers, the addresses `fixA` and the template start's
nodes; `θk` changes only variables `V` that the loop table and its restart substitution `θ` do not
read. The caller's predicate `Q` goes to `Q'` (`hQ`). `cut_compactQ`: the decode chains' compaction carrying the
readback queue, in the decode world with the target's bridge pinned (`fullWorldFb b0`, the relation `FLRb b0`). -/

section
variable {NB : Nat} {P : LoadP} {r : List NumV} {W : Nat → Option WFrame} {A : Addr} {Fr : LoopFramesA A}
  {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {θ : Nat → SymE} {g : GhostP} {x0 : SegInst FF}
  {sm sc : St FF.S} {tabm tabc : List SymE} {κ : Map} {θk : Nat → SymE} {V : Nat → Prop} {f eN : List Val}
  {Q Q' : SegInst FF → Prop}

/-- The pinned decode world's relation (`Full.FullRFb`, the target's bridge `b0`) at the target's remaining readbacks
`r`. -/
abbrev FLRb (b0 : BSt) (P : LoadP) (NB : Nat) (r : List NumV) : Map → Nat → FF.S → FF.S → Prop :=
  FullRFb b0 { P with rest := r } NB

/-- The compacted pair of `x` (`full_compact`'s map, valuation and context). -/
def compactPair (sm sc : St FF.S) (κ : Map) (θk : Nat → SymE) (P : LoadP) (x : SegInst FF) : SegInst FF :=
  ⟨(x.M.after κ).rebig (mlxOf sc.ffi).next P.E (mlxOf x.t.ffi).next, Shift.valuation θk x.ν,
    ⟨Shift.framedNext x.M x.K sm, sc.trace, x.t.trace, x.t.next - sc.next, x.K.lo, x.K.hi⟩, x.t, x.C⟩

/-- **A compaction is a conversion of the iteration's cuts** (see the module doc). -/
theorem cut_compact
    (hshift : ∀ x, Q x → IterGhostCW (fullWorld NB) A P Fr s0 tab0 fixA θ g x0 x →
      ShiftD FF (fun σ x y => x = sc.ffi ∧ FullShift P tabc.length σ x y) κ θk (kpOf x.K W) W x.K sc ⟨tabc, []⟩ sm
        ⟨tabm, []⟩)
    (htok : (mlxOf sc.ffi).tokens = []) (hbig : bigsOutB (mlxOf sc.ffi).next P.E (mlxOf sc.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < P.E) sc.trace sc)
    (hband : ∀ x, Q x → IterGhostCW (fullWorld NB) A P Fr s0 tab0 fixA θ g x0 x →
      ∀ i : Int, ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hroom : ∀ x, Q x → IterGhostCW (fullWorld NB) A P Fr s0 tab0 fixA θ g x0 x → x.t.next - sc.next < Sim.bound)
    (hroomN : ∀ x, Q x → IterGhostCW (fullWorld NB) A P Fr s0 tab0 fixA θ g x0 x →
      NRoom P (toLoad sc.ffi) (toLoad x.t.ffi))
    (hκn : ∀ j, j < tab0.length → κ.num j = .ref j) (hκa : ∀ a ∈ fixA, κ.a a = a)
    (hκv : ∀ j, j < (mlxOf s0.ffi).nnext → κ.node j = j) (hθk : ∀ v, ¬ V v → θk v = .var v)
    (htab : ∀ j e, nth? tab0 j = some e → ∀ w, V w → e.noVar w = true)
    (hθ : ∀ j e, nth? tab0 j = some e → ∀ w, V w → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (hfwd : ∃ o, sm.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ f))
    (hemit : ∃ o, sm.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ eN))
    (hkeep : KeepsAtW Fr sm) (heN : NumRefs tab0.length eN)
    (hJ : g.vJ ≤ sm.next) (hJc : sc.next ≤ sm.next) (hH : g.vH ≤ (mlxOf sm.ffi).next)
    (hHE : (mlxOf sm.ffi).next < P.E) (hN : g.vN ≤ (mlxOf sm.ffi).nnext)
    (hQ : ∀ x, Q x → IterGhostCW (fullWorld NB) A P Fr s0 tab0 fixA θ g x0 x → Q' (compactPair sm sc κ θk P x)) :
    CutConv ((Cut.mk sm tabm (Host.Ts.Sim.Conv.relB FF (FLR P NB r) W [] Q)).with
        (IterGhostCW (fullWorld NB) A P Fr s0 tab0 fixA θ g x0))
      ((Cut.mk sc tabc (Host.Ts.Sim.Conv.relB FF (FLR P NB r) W [] Q')).with
        (IterGhostCW (fullWorld NB) A P Fr s0 tab0 fixA θ (GhostP.compact (fullWorld NB) g sm sc eN) x0)) := by
  rintro x ⟨h1, hq⟩ hB
  have hc := Conv.full_compact NB (s0 := sc) (S0 := ⟨tabc, []⟩) (s1 := sm) (S1 := ⟨tabm, []⟩) (κ := κ) (θ := θk) h1
    (hshift x hq hB) htok hbig hfree (hband x hq hB) (fun q hq => nomatch hq)
    (hroom x hq hB) (hroomN x hq hB)
  have hg := IterGhostCW.compact (fullWorld_end NB) hB (r := r) (n' := tabc.length) h1.ffi h1.offset hc.ffi
    (fun j hj => by show x.M.nv (κ.num j) = _; rw [hκn j hj]; rfl)
    (fun a ha => by show x.M.a (κ.a a) = _; rw [hκa a ha])
    (fun j hj => by show x.M.node (κ.node j) = _; rw [hκv j hj])
    (fun v hv => by show (θk v).eval x.ν = x.ν v; rw [hθk v hv]; rfl) htab hθ hfwd hemit hkeep heN hJ hJc hH hHE hN
  exact ⟨compactPair sm sc κ θk P x, rfl, rfl, ⟨hc, hQ x hq hB⟩, hg⟩

/-- **A compaction carrying the readback queue is a conversion of the iteration's cuts** in the decode world with the
target's bridge pinned to `b0` (`fullWorldFb`; A3's `Conv.full_compactQB` at `BridgeFb b0`: the merged state's
readback tokens kept, under the compaction map, in the canonical state; the decode chains'). -/
theorem cut_compactQ (b0 : BSt)
    (hshift : ∀ x, Q x → IterGhostCW (fullWorldFb b0 NB) A P Fr s0 tab0 fixA θ g x0 x →
      ShiftD FF (fun σ x y => x = sc.ffi ∧ Conv.FullShiftQ P tabc.length σ x y) κ θk (kpOf x.K W) W x.K sc ⟨tabc, []⟩ sm
        ⟨tabm, []⟩)
    (hbig : bigsOutB (mlxOf sc.ffi).next P.E (mlxOf sc.ffi) = true)
    (hfree : NoBigSt (fun i => ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < P.E) sc.trace sc)
    (hband : ∀ x, Q x → IterGhostCW (fullWorldFb b0 NB) A P Fr s0 tab0 fixA θ g x0 x →
      ∀ i : Int, ((mlxOf sc.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed x.K.lo x.K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hroom : ∀ x, Q x → IterGhostCW (fullWorldFb b0 NB) A P Fr s0 tab0 fixA θ g x0 x → x.t.next - sc.next < Sim.bound)
    (hroomN : ∀ x, Q x → IterGhostCW (fullWorldFb b0 NB) A P Fr s0 tab0 fixA θ g x0 x →
      NRoom P (toLoad sc.ffi) (toLoad x.t.ffi))
    (hκn : ∀ j, j < tab0.length → κ.num j = .ref j) (hκa : ∀ a ∈ fixA, κ.a a = a)
    (hκv : ∀ j, j < (mlxOf s0.ffi).nnext → κ.node j = j) (hθk : ∀ v, ¬ V v → θk v = .var v)
    (htab : ∀ j e, nth? tab0 j = some e → ∀ w, V w → e.noVar w = true)
    (hθ : ∀ j e, nth? tab0 j = some e → ∀ w, V w → w ≠ A.nxt → (e.subst θ).noVar w = true)
    (hfwd : ∃ o, sm.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ f))
    (hemit : ∃ o, sm.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ eN))
    (hkeep : KeepsAtW Fr sm) (heN : NumRefs tab0.length eN)
    (hJ : g.vJ ≤ sm.next) (hJc : sc.next ≤ sm.next) (hH : g.vH ≤ (mlxOf sm.ffi).next)
    (hHE : (mlxOf sm.ffi).next < P.E) (hN : g.vN ≤ (mlxOf sm.ffi).nnext)
    (hQ : ∀ x, Q x → IterGhostCW (fullWorldFb b0 NB) A P Fr s0 tab0 fixA θ g x0 x → Q' (compactPair sm sc κ θk P x)) :
    CutConv ((Cut.mk sm tabm (Host.Ts.Sim.Conv.relB FF (FLRb b0 P NB r) W [] Q)).with
        (IterGhostCW (fullWorldFb b0 NB) A P Fr s0 tab0 fixA θ g x0))
      ((Cut.mk sc tabc (Host.Ts.Sim.Conv.relB FF (FLRb b0 P NB r) W [] Q')).with
        (IterGhostCW (fullWorldFb b0 NB) A P Fr s0 tab0 fixA θ (GhostP.compact (fullWorldFb b0 NB) g sm sc eN) x0)) := by
  rintro x ⟨h1, hq⟩ hB
  have hs := hshift x hq hB
  have hc := Conv.full_compactQB (bridgeFb_names b0) (shiftComp_Fb b0) NB (s0 := sc) (S0 := ⟨tabc, []⟩) (s1 := sm)
    (S1 := ⟨tabm, []⟩) (κ := κ) (θ := θk) h1 { hs with ffi := ⟨hs.ffi.1, hs.ffi.2.toB⟩ } hbig hfree (hband x hq hB) (fun q hq => nomatch hq)
    (hroom x hq hB) (hroomN x hq hB)
  have hg := IterGhostCW.compact (fullWorldFb_end b0 NB) hB (r := r) (n' := tabc.length) h1.ffi h1.offset hc.ffi
    (fun j hj => by show x.M.nv (κ.num j) = _; rw [hκn j hj]; rfl)
    (fun a ha => by show x.M.a (κ.a a) = _; rw [hκa a ha])
    (fun j hj => by show x.M.node (κ.node j) = _; rw [hκv j hj])
    (fun v hv => by show (θk v).eval x.ν = x.ν v; rw [hθk v hv]; rfl) htab hθ hfwd hemit hkeep heN hJ hJc hH hHE hN
  exact ⟨compactPair sm sc κ θk P x, rfl, rfl, ⟨hc, hQ x hq hB⟩, hg⟩

end

end Host.Ts.Sim.Compose
