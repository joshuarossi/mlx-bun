import host.sim.world.Loop
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # Loop cases composed of pieces (G7)

A regenerated decode iteration is not one checked run: it is a chain of pieces (checked segments
of the glue, last steps, bridges; `SegChain`) between the loop template start and the case's end,
followed by the restart into the loop template (the case restarts into its own start). Over a
world `Wd`:

* `AccSimG`: an acceptance's simulation facts under the frames (`AccSimW` over `Wd`);
* `loopLawsW`: the laws of a loop chain (the context kept, the target's mlx state growing);
* `LoopSegW`: a loop case composed of pieces: its template facts (`LoopCaseW`) and, for every list
  of remaining readbacks, the chain from the start under `relQW` with the entry predicate `QA` to
  the case's end; `LoopSegW.iterF` is its iteration theorem (`IterFW`) from the chain and the
  world's restart (`LoopCaseW.restartW`), so it discharges the per-iteration contract by
  `loop_stepW` (`decodeIter_seg`, Seam.lean);
* `LoopRunW.toSeg`: a case checked as one run is a one-piece chain, and its iteration theorem is
  `iterF_relFW`'s (`LoopRunW.toSeg_iterF`). -/

/-- The simulation facts of an acceptance function `ok` under the frames `W` over `Wd`, framing the
arrays `framed` (`AccSimW`). -/
structure AccSimG (Wd : World) (P : Wd.Par) (W : Nat → Option WFrame) (VBOk : (Nat → F64) → Prop)
    (ok : St Wd.F.S → SSrv → Bool) (framed : List Nat) where
  jsP : Disp.JSP Wd.F
  hj : jsP.lo = Wd.lo P ∧ jsP.hi = Wd.E P ∧ ∀ a, a ∈ jsP.framed ↔ a ∈ framed
  sim : ∀ r, Disp.StepSimXVW Wd.F (Wd.R P r) ok (Disp.Kp jsP) W VBOk
  simL : ∀ r, Disp.StepSimXLW Wd.F (Wd.R P r) ok (Disp.Kp jsP) W VBOk
  ng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St Wd.F.S) (S S1 : SSrv)
    (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → RelF Wd.F (Wd.R P r) W M ν K s S t C → ok s S = true →
    runOk Wd.F ok n s S = some (s1, S1) → runC Wd.F n t C = some (t1, C1) → Wd.Grows t t1
  ngL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St Wd.F.S) (S S1 : SSrv) (C C1 : CSrv),
    Disp.Kp jsP K → VBOk ν → RelXF Wd.F (Wd.R P r) W M ν K s S t C → isHalt s.ctl = false → ok s S = true →
    interpS (step Wd.F s).run S = some (s1, S1) → interpC (step Wd.F t).run C = some (t1, C1) → Wd.Grows t t1

/-- The laws of a loop chain over `Wd`: the context is kept; the target's mlx state grows. -/
def loopLawsW (Wd : World) : SegLaws Wd.F where
  KR K K' := K' = K
  TR t t' := Wd.Grows t t'
  krefl _ := rfl
  ktrans h1 h2 := h2.trans h1
  trefl t := World.Grows.refl Wd t
  ttrans h1 h2 := World.Grows.trans Wd h1 h2

/-- **A loop case composed of pieces** at `A` over `Wd` under the frames `W` (see the module doc). -/
structure LoopSegW (Wd : World) (A : Addr) (P : Wd.Par) (W : Nat → Option WFrame) (s0 : St Wd.F.S)
    (tab0 : List SymE) (fixA : List Nat) extends LoopCaseW Wd A P s0 tab0 fixA where
  QA : (Nat → F64) → Ctx → Prop
  QF : (Nat → F64) → Ctx → Prop
  chain : ∀ r, SegChain (loopLawsW Wd) (relQW Wd.F (Wd.R P r) W QA) s0 S0 (relQW Wd.F (Wd.R P r) W QF) s1 S1
  steps : ∀ r, (chain r).n = n

section
variable {Wd : World} {A : Addr} {P : Wd.Par} {W : Nat → Option WFrame} {s0 : St Wd.F.S} {tab0 : List SymE}
  {fixA : List Nat}

/-- The entry condition of a loop segment: at every loop context and accepted valuation the
chain's entry predicate holds. -/
def LoopSegW.Entry (c : LoopSegW Wd A P W s0 tab0 fixA) (Fr : LoopFramesA A) (VBOk : (Nat → F64) → Prop) : Prop :=
  ∀ (ν : Nat → F64) (K : Ctx) (p1 p2 : List Val), VBOk ν → K.fr = frA A s0 Fr.X p1 p2 → K.lo = Wd.lo P →
    K.hi = Wd.E P → c.QA ν K

/-- **A loop segment's iteration theorem**: the chain from the related start, the world's restart at
its end. -/
theorem LoopSegW.iterF (st : LoopStartW Wd A P s0 tab0) (c : LoopSegW Wd A P W s0 tab0 fixA) {Fr : LoopFramesA A}
    {VBOk : (Nat → F64) → Prop} (hQ : c.Entry Fr VBOk) (hsh : c.ShiftFWW Fr W) :
    c.IterFW (relW Wd P W) Fr VBOk := by
  intro r v M ν K t C x p1 p2 hν hfr hlo hhi h hx hD hroomH hroomN
  obtain ⟨x1, hst, hend, -⟩ := (c.chain (v :: r)).sim ⟨M, ν, K, t, C⟩ ⟨h, hQ ν K p1 p2 hν hfr hlo hhi⟩
  obtain ⟨M1, ν1, K1, t1, C1⟩ := x1
  obtain ⟨hrun, hval, hext, hkr, htr⟩ := hst
  change ν1 = ν at hval
  change K1 = K at hkr
  subst hval hkr
  rw [c.steps] at hrun
  change runC Wd.F c.n t C = some (t1, C1) at hrun
  obtain ⟨hoff, hH1, hN1, hrel⟩ := c.restartW st hsh hfr hlo hhi h hrun hext hend hx hD hroomH hroomN
  exact ⟨M1, t1, C1, hrun, hext, hoff, hH1, hN1, hrel, hend, htr⟩

/-- **A case checked as one run is a loop segment** of one piece, under its acceptance's
simulation under the frames. -/
noncomputable def LoopRunW.toSeg {ok : St Wd.F.S → SSrv → Bool} {VBOk : (Nat → F64) → Prop} {framed : List Nat}
    (c : LoopRunW Wd A ok P s0 tab0 fixA) (S : AccSimG Wd P W VBOk ok framed) : LoopSegW Wd A P W s0 tab0 fixA :=
  { c.toLoopCaseW with
    QA := fun ν K => Disp.Kp S.jsP K ∧ VBOk ν
    QF := fun ν K => Disp.Kp S.jsP K ∧ VBOk ν
    chain := fun r => .cons c.n (PieceSim.ofRunOkRelW (S.sim r) (fun _ _ h => h)
        (fun M ν K n s t s1 t1 S' S1 C C1 hq hr hok hrun hrc => S.ng r M ν K n s t s1 t1 S' S1 C C1 hq.1 hq.2 hr hok hrun hrc)
        c.ok0 c.run c.ctl) (interpS_runOk_len c.run) (.nil _ _ _)
    steps := fun _ => Nat.add_zero _ }

/-- The one-piece segment's entry: the acceptance's context and value predicates at every loop
context framing exactly `forwarded`, `emitted` and `Fr`. -/
theorem LoopRunW.toSeg_entry {ok : St Wd.F.S → SSrv → Bool} {VBOk : (Nat → F64) → Prop} {Fr : LoopFramesA A}
    (c : LoopRunW Wd A ok P s0 tab0 fixA) (S : AccSimG Wd P W VBOk ok (A.fwd :: A.emit :: Fr.xs)) :
    (c.toSeg S).Entry Fr VBOk := fun ν K p1 p2 hν hfr hlo hhi =>
  ⟨⟨hlo.trans S.hj.1.symm, hhi.trans S.hj.2.1.symm, fun a => by rw [S.hj.2.2, hfr]; exact frA_ne_none A s0 Fr p1 p2 a⟩,
    hν⟩

/-- The one-piece segment's iteration theorem (`iterF_relFW` through the chain). -/
theorem LoopRunW.toSeg_iterF {ok : St Wd.F.S → SSrv → Bool} {VBOk : (Nat → F64) → Prop} {Fr : LoopFramesA A}
    (st : LoopStartW Wd A P s0 tab0) (c : LoopRunW Wd A ok P s0 tab0 fixA)
    (S : AccSimG Wd P W VBOk ok (A.fwd :: A.emit :: Fr.xs)) (hsh : c.ShiftFWW Fr W) :
    (c.toSeg S).IterFW (relW Wd P W) Fr VBOk :=
  (c.toSeg S).iterF st (c.toSeg_entry S) hsh

end

end Host.Ts.Sim
