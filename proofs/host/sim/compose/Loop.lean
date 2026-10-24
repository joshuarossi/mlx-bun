import host.sim.compose.Seg
import host.sim.compose.Iter
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin.Cls (DecKind)

/-! # The decode route's pieces after the prefill

`DecodePiecesW`: what A2's route theorems (`source_tokens_prompt_routeW`,
`source_tokens_prompt_allW`, `host.sim.world.Route`) take of the decode loop and the halts, as
pieces:

* the six loop cases (`DecKind`: `ord`, `clear` with the forward's KV decode class `DFit`; `grow`,
  `clearGrow` with `DGrow`; `fill`, `clearFill` with `DFill`), each a chain of cut steps
  (`IterCaseW`, `host.sim.compose.Iter`) with its growth flag; the route's iterations from them:
  `itersW`;
* the final chains without EOS (`f0`, `f1`, `f2`: neither clear, the clear after token `T - 1`,
  after token `T`), the EOS exit at a loop cut (`x`, for every `2 ≤ k < T`), the EOS final chains
  (`e0`, `e1`), each a halting chain of pieces (`host.sim.compose.Seg`) with its oracle decided over
  its class's boxes (`FinalOk`, `ExitOk`, `FinalEOk`) and its entry at the route's valuations;
* the short paths' halts (`PathHaltW`) from their cuts `cA`, `cB`, `cC` (the ends of the route
  pieces' prefixes, `host.sim.compose.RouteSteps`), with the finish reason at the EOS stops.

`PathHaltW.path`: a path from a prefix and a halt. -/

section
variable {Wd : World} {A : Addr} {P : Wd.Par} {W : Nat → Option WFrame} {s0 : St Wd.F.S} {tab0 : List SymE}
  {fixA : List Nat} {Fr : LoopFramesA A}

variable (Wd A P W fixA) in
/-- **A short path's halt from its cut `I`**: the halting chain of two pieces from `I`'s template
(the readback, the stop or the loop's end), its entry from `I`'s invariant, the emitted numbers'
values `vs` (`PathW` without its prefix). -/
structure PathHaltW (I : ICut Wd.F) (vs : List F64) where
  r : List NumV
  xs : List Val
  h : Halt2W Wd A P W I.s0 I.s0 I.tab0 xs
  entry : ∀ x, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x →
    RelF Wd.F (Wd.R P r) W x.M x.ν x.K I.s0 ⟨I.tab0, []⟩ x.t x.C ∧ Good x.ν h.O ∧ h.QA x.ν x.K ∧
      x.K.fr A.emit = none ∧ ∀ a ∈ fixA, x.M.a a = a
  vals : ∀ x, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x →
    (arrOf I.s0 A.emit ++ xs).mapM (symValW (h.seg r).case.SF x.ν) = some vs

/-- **A path** from the prefix `pre` and the halt. -/
def PathHaltW.path {I I0 : ICut Wd.F} {vs : List F64} (ph : PathHaltW Wd A P W fixA I vs) {n : Nat}
    (pre : CutStep I0 I n) : PathW Wd A W P fixA I0 vs :=
  ⟨I, n, pre, ph.r, ph.xs, ph.h.seg ph.r, ph.entry, ph.vals⟩

/-- A path's graph obligation from its halt alone (`PathW.Goal`; the prefix does not enter it). -/
def PathHaltW.Goal {I : ICut Wd.F} {vs : List F64} (ph : PathHaltW Wd A P W fixA I vs) (Gf : St Wd.F.S → CSrv → Prop) :
    Prop :=
  ∀ x xF, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x → runC Wd.F (ph.h.seg ph.r).case.n x.t x.C = some (xF.t, xF.C) →
    Wd.Grows x.t xF.t → Ext x.M xF.M I.tab0.length → xF.ν = x.ν →
    (ph.h.seg ph.r).case.Rend xF (ph.h.seg ph.r).case.sF (ph.h.seg ph.r).case.SF → Gf xF.t xF.C

variable (Wd A P W s0 tab0 fixA Fr) in
/-- **The decode route's pieces** at the route's valuation `valL ρ T tk L`, readbacks `toks` (see the
module doc). -/
structure DecodePiecesW (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (L : Nat) (toks : List NumV) (E0 : List Val)
    (B : LoopBase) (ΔJ ΔH ΔN : Nat) (cA cB cC : ICut Wd.F) where
  -- the six loop cases as chains of cut steps
  cs : (k : DecKind) → IterCaseW Wd A W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (DecSel T L tk k)
  gr : ∀ k, (cs k).e.grow = k.grows
  -- the final chains without EOS
  f0 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok), .num (.ref tab0.length)]
  f1 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok), .num (.ref tab0.length)]
  f2 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok), .num (.ref tab0.length)]
  c0 : FinalOk false false f0.O
  c1 : FinalOk true false f1.O
  c2 : FinalOk false true f2.O
  qF : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
    f0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ f1.QA (valL ρ T tk L (T - 2) (tk T)) K ∧
      f2.QA (valL ρ T tk L (T - 2) (tk T)) K
  -- the EOS exit at a loop cut
  x : Halt2W Wd A P W s0 s0 tab0 []
  cX : ExitOk x.O
  qX : ∀ k, 2 ≤ k → k < T → ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) →
    K.lo = Wd.lo P → K.hi = Wd.E P → x.QA (valL ρ T tk L (k - 1) nx) K
  sX : StopAtW W A x.sE
  -- the EOS final chains
  e0 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok)]
  e1 : Halt4W Wd A P W s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) [.num (.ref A.tok)]
  c0E : FinalEOk false e0.O
  c1E : FinalEOk true e1.O
  qE : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
    e0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ e1.QA (valL ρ T tk L (T - 2) (tk T)) K
  s0E : StopAtW W A e0.sE
  s1E : StopAtW W A e1.sE
  -- the short paths' halts: token 1 EOS (`T ≥ 2`); `T = 2`: token 2 EOS, no EOS; `T = 1`: EOS, not
  pA : PathHaltW Wd A P W fixA cA []
  pB2 : PathHaltW Wd A P W fixA cB (tokVals tk 1)
  pB0 : PathHaltW Wd A P W fixA cB (tokVals tk 2)
  pC1 : PathHaltW Wd A P W fixA cC []
  pC0 : PathHaltW Wd A P W fixA cC (tokVals tk 1)
  sA : StopAtW W A pA.h.sE
  sB2 : StopAtW W A pB2.h.sE
  sC1 : StopAtW W A pC1.h.sE

end

end Host.Ts.Sim.Compose
