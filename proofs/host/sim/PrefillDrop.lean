import host.sim.Prefill
import host.sim.RestartDrop
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim

/-! # The prefill chain's restart dropping frames

A drain ends under the end context `K1` and frames `W1` (`RelF`) holding frames the next cut
does not (the chunk's buffer and typed array, the sliced chunk). `load_restart_drop`
(`RestartDrop.lean`) restarts into the cut keeping the framed arrays `kp` and the frames `W0`;
`loadPost_drop` packages its facts as `LoadPost`: the kept addresses are the next cut's framed set
`frsB`, the prompt's frame is kept (no element appended to it in the segment), and the addresses
the shift fixes stay fixed. -/

/-- **`LoadPost` from the restart dropping frames.** -/
theorem loadPost_drop {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {W W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {aP : Nat} {frsB fixA : List Nat}
    {s0 s1 t t1 : St LF.S} {S0 S1 : SSrv} {C C1 : CSrv} {n : Nat}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (h : RelF LF (LR P r0) W M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hrc : runC LF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length)
    (h1 : RelF LF (LR P r0) W1 M1 ν K1 s1 S1 t1 C1)
    (hKD : K1.D = K.D) (hKlo : K1.lo = K.lo) (hKhi : K1.hi = K.hi)
    (htab : ∀ e ∈ S1.tab, e.noVar 17 = true) (hor : ∀ q ∈ S1.oracle, q.noVar 17 = true)
    (hshift : ShiftD LF (FSn { P with rest := r0 } S0.tab.length s0.ffi) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var 17], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hσ : σ.num 79 = .ref S1.tab.length) (htok : s0.ffi.mlx.tokens = [.ref 79]) (h79 : 79 < S0.tab.length)
    (hbig : bigsOutB s0.ffi.mlx.next P.E s0.ffi.mlx = true)
    (hfree : NoBigSt (fun i => (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : s1.ffi.mlx.next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hroomN : t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hframed : ∀ a, (kp a = true ∨ (W0 a).isSome = true) ↔ a ∈ frsB)
    (hkP : kp aP = true) (hK1P : K1.fr aP = K.fr aP)
    (hpx : ∀ pre pre' o es, K1.fr aP = some (pre, pre') → s1.heap.get aP = some (.obj o) → o.kind = .array es →
      es.drop pre.length = [])
    (hfixσ : ∀ a ∈ fixA, σ.a a = a) :
    ∃ x' : SegInst LF, x'.t = t1 ∧ x'.C = C1 ∧ RelF LF (LR P r) W0 x'.M x'.ν x'.K s0 ⟨S0.tab, []⟩ t1 C1 ∧
      x'.ν = Shift.valuation θ (upd ν 17 x) ∧
      LoadPost s0 s1 s0 aP frsB fixA ⟨M, ν, K, t, C⟩ ⟨M1, ν, K1, t1, C1⟩ x' := by
  have hns : NShift { P with rest := r0 } S0.tab.length σ s0.ffi s1.ffi := hshift.ffi.2
  obtain ⟨hoff, hH1, hN1, hrel⟩ := load_restart_drop h hr0 hrc hext h1 hKD hKlo hKhi htab hor hshift hW hσ htok
    h79 hbig hfree hband hx hE hD hroomH hroomN
  refine ⟨⟨((M1.setNum S1.tab.length v).after σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next,
    Shift.valuation θ (upd ν 17 x),
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

end Host.Ts.Sim.Prefill
