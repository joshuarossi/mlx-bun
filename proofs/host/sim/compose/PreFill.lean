import host.sim.compose.Glue
import host.sim.compose.Shape
import host.sim.compose.ChainFill
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full

/-! # A prefill chain's links from its template run

A prefill chain (`tpl_chain` of a prefill row, A4's `PRE_<row>`) fills the prefill bundle's pieces
(`host.sim.compose.Bundle`: `GlueP`, `StageR`, `FwdP` over the rows that use them) at its template boundaries
`(s<b>, S<b>)`, over a native relation `FR` and an acceptance `ok` under the frames `W`:

* the cuts: `pbCut … m s S`, the relation at the template state, the run's predicate `PQ` (the valuation within the
  acceptance's bounds, the context the acceptance's `J`, the variables at the row's quantities `m`); no iteration's
  bookkeeping (a prefill step is not a loop iteration);
* a glue piece `glueP` (its checked run, `cut_glue`), `glueCallP` (its run and the step into the next call,
  `cut_glueCall`);
* `pbConv`: a cut whose relation and bookkeeping give the chain's at its start (the loadDone cut's) into the
  chain's first cut. -/

section
variable (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)

/-- The run's predicate at a prefill chain's cut (see the module doc). -/
def PQ (m : List (Nat × Q)) (i : Cls.Inst) (x : SegInst FF) : Prop :=
  VBOkF loopVB x.ν ∧ Disp.Kp J x.K ∧ MapOk x.ν i m

/-- **A prefill chain's cut at a template boundary** `(s, S)` (see the module doc). -/
def pbCut (m : List (Nat × Q)) (s : St FF.S) (S : SSrv) (i : Cls.Inst) : ICut FF :=
  (Cut.mk s S.tab (Conv.relB FF FR W [] (PQ J m i))).with fun _ => True

end

section
variable {FR : Map → Nat → FF.S → FF.S → Prop} {J : Disp.JSP FF} {W : Nat → Option WFrame}
  {ok : St FF.S → SSrv → Bool} {uses : List Row}

/-- **A glue piece as a prefill piece**: the checked run of its template from `(sa, Sa)` to `(sb, Sb)` under the
simulation `hsim`, at the variables `m`, into the cut at its end at the variables `m'` within them. -/
def glueP {m m' : List (Nat × Q)} {sa sb : St FF.S} {Sa Sb : SSrv} {n : Nat}
    (hsim : Disp.StepSimXLB FF FR ok (Disp.Kp J) W [] (VBOkF loopVB)) (O : List Ans)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true) (hO : Sa.oracle = O) (hok : ok sa Sa = true)
    (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (htop : noRetBlock sb = true) (hsub : ∀ p ∈ m', p ∈ m) :
    GlueP FF uses m (pbCut FR J W m sa Sa) (pbCut FR J W m' sb Sb) where
  n := n
  O := O
  chk := hchk
  ok _ _ i _ hobl := cut_glue hsim hok hrun htop (fun _ hq _ => ⟨hq.2.1, hq.1⟩)
    (fun c hq _ => by rw [hO]; exact hobl.1 c.ν hq.2.2)
    (fun _ _ _ _ hq _ _ _ _ h2 => ⟨⟨h2.withOracle (fun q hq => nomatch hq), hq.1, hq.2.1, MapOk.sub hq.2.2 hsub⟩,
      trivial⟩)

/-- **A glue piece into the next call as a prefill piece**: its run, then the step from its accepted end into the
call state `(sc, Sc)`. -/
def glueCallP {m m' : List (Nat × Q)} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv} {n : Nat}
    (hsim : Disp.StepSimXLB FF FR ok (Disp.Kp J) W [] (VBOkF loopVB)) (O : List Ans)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true) (hO : Sa.oracle = O) (hok : ok sa Sa = true)
    (hrun : runOk FF ok n sa Sa = some (sb, Sb)) (hokb : ok sb Sb = true) (hhalt : isHalt sb.ctl = false)
    (hstep : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true) (hsub : ∀ p ∈ m', p ∈ m) :
    GlueP FF uses m (pbCut FR J W m sa Sa) (pbCut FR J W m' sc Sc) where
  n := n + 1
  O := O
  chk := hchk
  ok _ _ i _ hobl := cut_glueCall hsim hok hrun hokb hhalt hstep htop (fun _ hq _ => ⟨hq.2.1, hq.1⟩)
    (fun c hq _ => by rw [hO]; exact hobl.1 c.ν hq.2.2)
    (fun _ _ _ _ hq _ _ _ _ h2 => ⟨⟨h2.withOracle (fun q hq => nomatch hq), hq.1, hq.2.1, MapOk.sub hq.2.2 hsub⟩,
      trivial⟩)

/-- **Into a prefill chain's first cut**: a cut at the chain's start state and table whose relation is the chain's
(`hR`) and whose bookkeeping gives the run's predicate (`hB`). -/
theorem pbConv {I0 : ICut FF} {m : List (Nat × Q)} {S : SSrv} {i : Cls.Inst} (hS : S.tab = I0.tab0)
    (hR : ∀ x, I0.R x I0.s0 ⟨I0.tab0, []⟩ → I0.B x → RelB FF FR W [] x.M x.ν x.K I0.s0 ⟨I0.tab0, []⟩ x.t x.C)
    (hB : ∀ x, I0.R x I0.s0 ⟨I0.tab0, []⟩ → I0.B x → PQ J m i x) :
    CutConv I0 (pbCut FR J W m I0.s0 S i) := by
  intro x hx hb
  refine ⟨x, rfl, rfl, ⟨?_, hB x hx hb⟩, trivial⟩
  show RelB FF FR W [] x.M x.ν x.K I0.s0 ⟨S.tab, []⟩ x.t x.C
  rw [hS]; exact hR x hx hb

end

section
variable {uses : List Row} {m : List (Nat × Q)} {obls : List Obl}
  {A B C : Cls.Inst → ICut FF} {n np nb : Nat}

/-- Package a checked site run and its canonical conversion as a generated stage. -/
def stageP (O : List Ans) (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hstep : PieceOk FF uses [⟨m, O⟩] (fun X Y => CutStep X Y n) A C)
    (hpost : ∀ r ∈ uses, ∀ i, InRow r i → OblOk i [⟨m, O⟩] → CutConv (C i) (B i)) :
    StageP FF uses m A B where
  n := n
  O := O
  chk := hchk
  ok r hr i hi ho := StageCall.intro (CutConv.refl _) (hstep r hr i hi ho) (hpost r hr i hi ho)

/-- Existing stage oracles may justify the same site run without introducing another oracle. -/
def stageR (hstep : PieceOk FF uses obls (fun X Y => CutStep X Y n) A C)
    (hpost : ∀ r ∈ uses, ∀ i, InRow r i → OblOk i obls → CutConv (C i) (B i)) :
    StageR FF uses obls A B where
  n := n
  ok r hr i hi ho := StageCall.intro (CutConv.refl _) (hstep r hr i hi ho) (hpost r hr i hi ho)

/-- A generated forward can contain its prefix in the checked site run.  A shared body
can instead supply the two runs and the conversion between their cuts. -/
def fwdP {D E : Cls.Inst → ICut FF} (O : List Ans)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hp : PieceOk FF uses (⟨m, O⟩ :: obls) (fun X Y => CutStep X Y np) A C)
    (hc : ∀ r ∈ uses, ∀ i, InRow r i → OblOk i (⟨m, O⟩ :: obls) → CutConv (C i) (D i))
    (hb : PieceOk FF uses (⟨m, O⟩ :: obls) (fun X Y => CutStep X Y nb) D E)
    (hm : ∀ r ∈ uses, ∀ i, InRow r i → OblOk i (⟨m, O⟩ :: obls) → CutConv (E i) (B i)) :
    FwdP FF uses m obls A B where
  np := np
  nb := nb
  O := O
  chk := hchk
  ok r hr i hi ho := FwdCall.intro (CutConv.refl _) (hp r hr i hi ho) (hc r hr i hi ho)
    (hb r hr i hi ho) (hm r hr i hi ho)

end

end Host.Ts.Sim.Compose
