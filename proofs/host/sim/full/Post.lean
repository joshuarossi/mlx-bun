import host.sim.world.Book
import host.sim.full.World
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Load.Layers

/-! # The prefill chain's restart dropping frames, in the full world

`full_loadPost_drop`: `loadPost_drop` (`host.sim.PrefillDrop`) for `fullWorld`: the restart dropping
frames (`full_restart_drop`) packaged as the world's restart facts `LoadPostW`. -/

/-- **`LoadPostW` from the full world's restart dropping frames.** -/
theorem full_loadPost_drop (NB k w : Nat) {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {W W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {aP : Nat} {frsB fixA : List Nat}
    {s0 s1 t t1 : St FF.S} {S0 S1 : SSrv} {C C1 : CSrv} {n : Nat}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hst : fullStart P k s0) (h : RelF FF (FLR P NB r0) W M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hrc : runC FF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length)
    (h1 : RelF FF (FLR P NB r0) W1 M1 ν K1 s1 S1 t1 C1)
    (hKD : K1.D = K.D) (hKlo : K1.lo = K.lo) (hKhi : K1.hi = K.hi)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD FF (fun σ x y => x = s0.ffi ∧ FullShift P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, ((mlxOf s0.ffi).next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : (mlxOf s1.ffi).next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : (mlxOf t.ffi).next + ((mlxOf s1.ffi).next - (mlxOf s0.ffi).next) + (P.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hroomN : (mlxOf t.ffi).nnext + ((mlxOf s1.ffi).nnext - (mlxOf s0.ffi).nnext) + (P.NE - (mlxOf s0.ffi).nnext) <
      2 ^ 62)
    (hframed : ∀ a, (kp a = true ∨ (W0 a).isSome = true) ↔ a ∈ frsB)
    (hkP : kp aP = true) (hK1P : K1.fr aP = K.fr aP)
    (hpx : ∀ pre pre' o es, K1.fr aP = some (pre, pre') → s1.heap.get aP = some (.obj o) → o.kind = .array es →
      es.drop pre.length = [])
    (hfixσ : ∀ a ∈ fixA, σ.a a = a) :
    ∃ x' : SegInst FF, x'.t = t1 ∧ x'.C = C1 ∧ RelF FF (FLR P NB r) W0 x'.M x'.ν x'.K s0 ⟨S0.tab, []⟩ t1 C1 ∧
      x'.ν = Shift.valuation θ (upd ν w x) ∧
      LoadPostW (fullWorld NB) s0 s1 s0 aP frsB fixA ⟨M, ν, K, t, C⟩ ⟨M1, ν, K1, t1, C1⟩ x' := by
  have hns := hshift.ffi.2.load
  obtain ⟨hoff, hH1, hN1, hrel⟩ := full_restart_drop NB k w hst h hr0 hrc hext h1 hKD hKlo hKhi htab hor hshift hW
    hσ hk hband hx hE hD hroomH hroomN
  refine ⟨⟨((M1.setNum S1.tab.length v).after σ).rebig (mlxOf s0.ffi).next P.E (mlxOf t1.ffi).next,
    Shift.valuation θ (upd ν w x),
    ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩, t1, C1⟩,
    rfl, rfl, hrel, rfl, {
    off := h.offset
    grows := hshift.grows
    mgrows := hns.mlx.hnext.2
    ngrows := hns.mlx.nle
    next := hoff
    mnext := hH1
    mnnext := hN1
    t := rfl
    D := rfl
    lo := rfl
    hi := rfl
    base := rfl
    prompt := ?_
    framed := fun a => (dropNext_framed (fun a ha => ?_) (fun a w hw => (hshift.wide a w hw).2.2.1) a).trans
      (hframed a)
    fix := fun a ha hM => ?_ }⟩
  · show dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1 aP = K.fr aP
    rw [dropNext_eq hkP, ← hK1P]
    unfold Shift.framedNext
    cases hf : K1.fr aP with
    | none => rfl
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      simp only
      cases hg : s1.heap.get aP with
      | none => rfl
      | some y =>
        cases y with
        | cell _ => rfl
        | obj o =>
          simp only
          split
          · rename_i es hes
            rw [hpx pre pre' o es hf hg hes]
            simp [Map.vals]
          · rfl
  · obtain ⟨-, pre, pre', -, -, hf, -⟩ := hshift.framed a ha
    rw [hf]
    simp
  · show M1.a (σ.a a) = a
    rw [hfixσ a ha, hext.a]
    exact hM

end Host.Ts.Sim.Full
