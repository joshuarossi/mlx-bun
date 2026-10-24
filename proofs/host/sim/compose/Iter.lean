import host.sim.world.Route
import host.sim.world.IterCut
import host.sim.lin.Classes
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin.Cls (DecKind)

/-! # The decode cases as chains of cut steps

A decode iteration runs through cuts (`host.sim.world.IterCut`): from the iteration's start cut
`iterStartW … i x0`, the first conversion establishes the iteration's ghost (`iterStart_ghost`:
`IterGhostCW.start` into `iterGhostW`), then the case's chain (`IterChainW`) of cut steps in
`tpl_chain`'s order (`chain.json`'s pieces): glue piece `0`, call `0`, glue piece `1`, …, the last glue
piece, into the end cut `iterEndCW … e g i x0` at the case's end template `e` and ghost data `g`
(`CutChain`: consecutive cut steps). A glue piece is its segment (`X.runSeg<k>`), a call A3's
`cut_site` (the ghost across it: `IterGhostCW.site`) followed by its compaction (`cut_compact`,
`host.sim.compose.Compact`: the ghost data `g ↦ GhostP.compact g sm sc eN`).

`IterCaseW`: a decode case as such a chain with its end facts (`decodeIter_piecesCW`'s: the end's
shift under the frames, its kept frames, its emitted elements, its counter deltas from the ghost);
`IterCaseW.iter`: its iteration at every `i` it is selected for, from its graph obligation
(`LoopGStepGW`). `itersW`: the route's iterations (`DecodeItersW`) from a chain per case of
`DecKind` (`host.sim.lin.Classes`: the six cases, `loopSelLW`'s selection). -/

/-- **Consecutive cut steps** from `a` through the cuts `cs` to `b`, of lengths `ns`. -/
def CutChain {F : Ffi} : ICut F → List (ICut F) → ICut F → List Nat → Prop
  | a, [], b, [n] => CutStep a b n
  | a, c :: cs, b, n :: ns => CutStep a c n ∧ CutChain c cs b ns
  | _, _, _, _ => False

theorem CutChain.run {F : Ffi} : ∀ {a : ICut F} {cs : List (ICut F)} {b : ICut F} {ns : List Nat},
    CutChain a cs b ns → CutStep a b ns.sum
  | _, [], _, [_], h => by rw [List.sum_singleton]; exact h
  | _, _ :: _, _, _ :: _, ⟨h, t⟩ => by rw [List.sum_cons]; exact h.trans (CutChain.run t)
  | _, [], _, [], h => h.elim
  | _, [], _, _ :: _ :: _, h => h.elim
  | _, _ :: _, _, [], h => h.elim

section
variable (Wd : World) (A : Addr) (W : Nat → Option WFrame) (P : Wd.Par) (Fr : LoopFramesA A) (s0 : St Wd.F.S)
  (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat) (toks : List NumV) (E0 : List Val)
  (B : LoopBase) (ΔJ ΔH ΔN : Nat)

/-- **The iteration's ghost cut** at `i` from the start pair `x0`: the decode cut's template and
relation, the pair reached from `x0` (`IterGhostCW` at the template start's data, the case's restart
substitution `θ`) at `x0`'s valuation and context, `x0` at the decode cut (its bookkeeping without the graph
invariant). -/
def iterGhostW (θ : Nat → SymE) (i : Nat) (x0 : SegInst Wd.F) : ICut Wd.F where
  s0 := s0
  tab0 := tab0
  R := fun x s S => relW Wd P W (toks.drop i) x.M x.ν x.K s S x.t x.C
  B := fun x => IterGhostCW Wd A P Fr s0 tab0 fixA θ (GhostP.init Wd s0) x0 x ∧ x.ν = x0.ν ∧ x.K = x0.K ∧
    (decCutW Wd A (fun _ _ _ _ => True) W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i).B x0

/-- **A decode case's chain of cut steps** at the iterations `Sel` selects (see the module doc): the
cuts between its links at iteration `i` from the start pair `x0`, the links' lengths, the links. -/
structure IterChainW (e : IterEndW Wd A P s0 tab0 fixA) (g : GhostP) (Sel : Nat → Prop) where
  cuts : List (Nat → SegInst Wd.F → ICut Wd.F)
  lens : List Nat
  links : ∀ i x0, Sel i → CutChain (iterGhostW Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN e.θ i x0)
    (cuts.map fun c => c i x0) (iterEndCW Wd A W P Fr s0 tab0 fixA toks e g i x0) lens

/-- **A decode case as a chain of cut steps**, with the end facts of `decodeIter_piecesCW`. -/
structure IterCaseW (Sel : Nat → Prop) where
  e : IterEndW Wd A P s0 tab0 fixA
  g : GhostP
  chain : IterChainW Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN e g Sel
  sh : e.ShiftFW Fr W
  keep : KeepsAtW Fr e.s1
  emit : g.eA ++ e.eR = [.num (.ref A.tok)]
  within : e.Within g ΔJ ΔH ΔN

end

section
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par}
  {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat}
  {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- The chain's length. -/
def IterChainW.n {e : IterEndW Wd A P s0 tab0 fixA} {g : GhostP} {Sel : Nat → Prop}
    (c : IterChainW Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN e g Sel) : Nat :=
  c.lens.sum

/-- **The chain** from the ghost cut to the end cut. -/
theorem IterChainW.run {e : IterEndW Wd A P s0 tab0 fixA} {g : GhostP} {Sel : Nat → Prop}
    (c : IterChainW Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN e g Sel) {i : Nat} (x0 : SegInst Wd.F)
    (hs : Sel i) :
    CutStep (iterGhostW Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN e.θ i x0)
      (iterEndCW Wd A W P Fr s0 tab0 fixA toks e g i x0) c.n :=
  (c.links i x0 hs).run

/-- **The iteration's first conversion**: the start pair `x0` at the decode cut gives the ghost
cut (`IterGhostCW.start`). -/
theorem iterStart_ghost (hE : Wd.EndLaws) (θ : Nat → SymE) (i : Nat) (x0 : SegInst Wd.F)
    (hB0 : (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i).B x0) :
    CutConv (iterStartW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i x0)
      (iterGhostW Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN θ i x0) := by
  rintro x hR rfl
  obtain ⟨nx, p1, hν, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, -⟩ := hB0
  exact ⟨x, rfl, rfl, hR, IterGhostCW.start hE hR hfr, rfl, rfl,
    ⟨nx, p1, hν, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, trivial⟩⟩

/-- **A decode case's iteration** at every `i` it is selected for: `decodeIter_piecesCW` with the
chain after the first conversion, the next valuation from the end's restart substitution and its
growth flag, the bounds at the budget `T`, and the case's graph obligation. -/
theorem IterCaseW.iter (hE : Wd.EndLaws) (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0) {Sel : Nat → Prop}
    {ρ : Nat → F64} {T L : Nat}
    (c : IterCaseW Wd A W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN Sel)
    (hgr : ∀ i, Sel i → c.e.grow = decide ((L + i + 1) % 256 = 0)) {i : Nat} (hs : Sel i) (hi1 : 1 ≤ i)
    (hiT : i + 2 < T) (hLT : L + T < 2 ^ 29) (hlen : T - 2 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + T * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + T * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : LoopGStepGW Gx W Fr c.e c.g (valL ρ T tk L) toks i) :
    DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) i (0 + c.chain.n) := by
  have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
  exact decodeIter_piecesCW hE st c.e c.g c.sh c.keep c.emit hi1 (by omega)
    (fun _ => by
      rw [hA]
      exact next_valL c.e.grow (fun j => by rw [c.e.theta j, hA]) (by omega)
        (by have := capL_le (L + i + 1); omega) (hgr i hs))
    (htk (i + 2) (by omega)) c.within (by have := hmul ΔJ; omega) (by have := hmul ΔH; omega)
    (by have := hmul ΔN; omega) hG
    (fun x0 _ hB0 => (iterStart_ghost hE c.e.θ i x0 hB0).step.trans (c.chain.run x0 hs))

/-- A case's iterations with the iteration's token in the vocabulary and not EOS (the decode rows'
facts, `host.sim.lin.CoverD`). -/
def DecSel (T L : Nat) (tk : Nat → Nat) (k : DecKind) (i : Nat) : Prop :=
  k.Sel T L i ∧ tk (i + 1) ≤ 248319 ∧ tk (i + 1) ≠ 248044

/-- **The route's iterations from the six cases' chains** (`DecodeItersW`): each iteration's case
(`DecKind.cover`) by `IterCaseW.iter`, its graph obligation `hG`. -/
theorem itersW (hE : Wd.EndLaws) (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0) {ρ : Nat → F64} {T L : Nat}
    (cs : (k : DecKind) → IterCaseW Wd A W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (DecSel T L tk k))
    (hgr : ∀ k, (cs k).e.grow = k.grows) (hLT : L + T < 2 ^ 29) (hlen : T - 2 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (htv : ∀ j, j ≤ T → tk j ≤ 248319) (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + T * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + T * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : ∀ k i, DecSel T L tk k i → (∀ j, 1 ≤ j → j ≤ i + 1 → tk j ≠ 248044) →
      LoopGStepGW Gx W Fr (cs k).e (cs k).g (valL ρ T tk L) toks i) :
    DecodeItersW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) T tk := by
  intro i hi1 hiT hne
  obtain ⟨k, hk⟩ := DecKind.cover L i
  have hs : DecSel T L tk k i := ⟨⟨hi1, hiT, hk⟩, htv (i + 1) (by omega), hne (i + 1) (by omega) le_rfl⟩
  exact ⟨_, (cs k).iter hE hA st (fun _ hs => (hgr k).trans (DecKind.grows_eq hs.1.2.2)) hs hi1 hiT hLT
    hlen htk hJ hH hN (hG k i hs hne)⟩

end

end Host.Ts.Sim.Compose
