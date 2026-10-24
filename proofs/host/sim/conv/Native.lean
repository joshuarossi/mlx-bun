import host.sim.native.gen.Rel
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # The abstract-node band at a merge

The gen relation (`G.MR`) already knows nodes in `[P.NL, P.N0)` by shape and dtype only (their
primitives and inputs are free: `NodeR`'s full clause applies to `Full P i = i < P.NL ∨ P.N0 ≤ i`).
At a stage's return the caller must know the nodes the stage created by shape and dtype only, so
that the caller's later code (and its template) does not depend on the stage's class. With every
node created before the merge counted as history, that is the same band, raised to the merged
state's node counter: `MRw.abstractTo`, `MR.abstractTo`, `LoadR.abstractTo` raise `P.N0` to any
`N0' ≤ x.nnext` (a weakening: the full-correspondence obligations shrink). The nodes the caller
creates after the merge are again fully corresponding (`Full` from `N0'` on), which is what the
next piece's graph certificate reads; the graph facts of the nodes before the merge are the earlier
pieces' and the stage's certificates (composed through their carriers).

`abstractTo_full`: with `N0' = P.N0` nothing changes. -/

/-- `P` with its band of abstract nodes extended to `N0'`. -/
def _root_.Host.Ts.Sim.LoadP.abstractTo (P : LoadP) (N0' : Nat) : LoadP := { P with N0 := N0' }

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} {N0' : Nat}

theorem Full.ofAbstractTo (h0 : P.N0 ≤ N0') {i : Nat} (h : Full (P.abstractTo N0') i) : Full P i := by
  rcases h with h | h
  · exact .inl h
  · exact .inr (Nat.le_trans h0 h)

theorem NodeR.abstractTo (h0 : P.N0 ≤ N0') {i : Nat} {nd nd' : Node} (h : NodeR P M i nd nd') :
    NodeR (P.abstractTo N0') M i nd nd' :=
  ⟨h.1, h.2.1, h.2.2.1, fun hf => h.2.2.2 (Full.ofAbstractTo h0 hf)⟩

/-- **The abstract-node band**: every node below `N0'` (above the pre-loop band) is known by
shape and dtype only. -/
theorem MRw.abstractTo (hr : MRw P NB M n x y) (h0 : P.N0 ≤ N0') (h1 : N0' ≤ x.nnext) :
    MRw (P.abstractTo N0') NB M n x y :=
  { hr with
    norder := fun i hi hf j hj => hr.norder i hi (Full.ofAbstractTo h0 hf) j hj
    nodes := fun i nd hn => by
      obtain ⟨nd', h1', h2⟩ := hr.nodes i nd hn
      exact ⟨nd', h1', h2.abstractTo h0⟩
    nband := ⟨Nat.le_trans hr.nband.1 h0, h1⟩ }

theorem MR.abstractTo (hr : MR P NB M n x y) (h0 : P.N0 ≤ N0') (h1 : N0' ≤ x.nnext) :
    MR (P.abstractTo N0') NB M n x y :=
  { hr.toMRw.abstractTo h0 h1 with hfreshB := hr.hfreshB, tokensX := hr.tokensX }

theorem LoadR.abstractTo {x y : Host.Load.LSt} (hr : LoadR P NB M n x y) (h0 : P.N0 ≤ N0')
    (h1 : N0' ≤ x.mlx.nnext) : LoadR (P.abstractTo N0') NB M n x y :=
  ⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr, hr.mlx.abstractTo h0 h1⟩

theorem LoadRw.abstractTo {x y : Host.Load.LSt} (hr : LoadRw P NB M n x y) (h0 : P.N0 ≤ N0')
    (h1 : N0' ≤ x.mlx.nnext) : LoadRw (P.abstractTo N0') NB M n x y :=
  ⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr, hr.mlx.abstractTo h0 h1⟩

/-- Raising the band to its own bound changes nothing. -/
theorem abstractTo_full (P : LoadP) : P.abstractTo P.N0 = P := rfl

end

end Host.Ts.Sim.G
