import host.sim.compose.Seg
import host.sim.compose.Iter
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin.Cls (DecKind)

/-! The six decode cases and the short-path halts. Exact terminal-frame entries
extend DecodeCasesW in host.sim.compose.LoopFramed. -/

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
/-- The six decode chains and their cache-growth flags, independent of the halting pieces. -/
structure DecodeCasesW (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (L : Nat) (toks : List NumV) (E0 : List Val)
    (B : LoopBase) (ΔJ ΔH ΔN : Nat) where
  cs : (k : DecKind) → IterCaseW Wd A W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (DecSel T L tk k)
  gr : ∀ k, (cs k).e.grow = k.grows

variable (Wd A P W fixA) in
/-- **The short paths' halts** from their cuts: token 1 EOS (`T ≥ 2`); `T = 2`: token 2 EOS, no EOS; `T = 1`:
EOS, not. -/
structure PathPiecesW (tk : Nat → Nat) (cA cB cC : ICut Wd.F) where
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
