import host.sim.world.World
import host.sim.Prefill
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The prefill chain over a world

`Cut`, `ICut`, `CutStep`, `XCase` (Prefill.lean) are generic in the FFI. Over a world `Wd` this
module states the load world's bookkeeping and the prefill chain:

* conversions (`CutConv`): a 0-step cut step whose related pair may change its map, valuation
  and context (the target and its server are kept), e.g. a stage conversion (isolate at a stage
  call, merge at its return); `CutConv.step`, `CutStep.convL`, `CutStep.convR`, `CutConv.trans`,
  and `CutStep.congr` (cut steps between cuts with equivalent bookkeeping);
* `PrefPW`, `CutBookW`, `LoadPostW`, `CutBookW.restart`, `bookBW`, `BCaseW`, `BCaseW.Ok`,
  `book_stepW`: `PrefP` … `book_step` with the counters read through `Wd.toMlx` and the band
  from `Wd.lo`, `Wd.E`;
* the drains (`prefCutW`, `PrefillInvW`, `DrainOkW`, `prefill_stepW`, `prefill_allW`), the tail
  and the final step (`preFinalCutW`, `tail_stepW`, `final_d1_stepW`);
* `PrefInvsW`, `PrefStepsW`, `prefill_midW`, `prefill_reachW`, `DecodeRouteW`, `source_promptW`:
  `PrefInvs` … `source_prompt` over the world's FFI; `PrefStepsPW`, `prefill_reach_psW`: the chain up to
  its exit cut `ps` (an EOS as the first sampled token halts from there, before POST). -/

/-! ## Conversions -/

section Conv
variable {F : Ffi}

/-- **A conversion** from cut `I` to cut `J`: every pair related at `I` with its bookkeeping is,
with the same target and server, a pair related at `J` with its bookkeeping (the map, the
valuation and the context may change). -/
def CutConv (I J : ICut F) : Prop :=
  ∀ x, I.R x I.s0 ⟨I.tab0, []⟩ → I.B x → ∃ x', x'.t = x.t ∧ x'.C = x.C ∧ J.R x' J.s0 ⟨J.tab0, []⟩ ∧ J.B x'

theorem CutConv.refl (I : ICut F) : CutConv I I := fun x hR hB => ⟨x, rfl, rfl, hR, hB⟩

theorem CutConv.trans {I J K : ICut F} (h1 : CutConv I J) (h2 : CutConv J K) : CutConv I K := by
  intro x hR hB
  obtain ⟨x1, ht1, hC1, hR1, hB1⟩ := h1 x hR hB
  obtain ⟨x2, ht2, hC2, hR2, hB2⟩ := h2 x1 hR1 hB1
  exact ⟨x2, ht2.trans ht1, hC2.trans hC1, hR2, hB2⟩

/-- **A conversion is a 0-step cut step.** -/
theorem CutConv.step {I J : ICut F} (h : CutConv I J) : CutStep I J 0 := by
  rintro t C ⟨x, rfl, rfl, hR, hB⟩
  obtain ⟨x', ht, hC, hR', hB'⟩ := h x hR hB
  exact ⟨x.t, x.C, rfl, x', ht, hC, hR', hB'⟩

/-- A conversion before a cut step. -/
theorem CutStep.convL {I J K : ICut F} {n : Nat} (hc : CutConv I J) (h : CutStep J K n) : CutStep I K n :=
  (hc.step.trans h).cast rfl rfl (Nat.zero_add n).symm

/-- A conversion after a cut step. -/
theorem CutStep.convR {I J K : ICut F} {n : Nat} (h : CutStep I J n) (hc : CutConv J K) : CutStep I K n :=
  h.trans hc.step

/-- Cut steps between cuts with the same start and relation and equivalent bookkeeping. -/
theorem CutStep.congr {I J I' J' : ICut F} {n : Nat} (h : CutStep I J n) (hI : I'.toCut = I.toCut)
    (hJ : J'.toCut = J.toCut) (hBI : ∀ x, I'.B x → I.B x) (hBJ : ∀ x, J.B x → J'.B x) : CutStep I' J' n := by
  rintro t C ⟨x, ht, hC, hR, hB⟩
  have hR0 : I.R x I.s0 ⟨I.tab0, []⟩ := by
    have e1 : I'.R = I.R := congrArg Cut.R hI
    have e2 : I'.s0 = I.s0 := congrArg Cut.s0 hI
    have e3 : I'.tab0 = I.tab0 := congrArg Cut.tab0 hI
    rw [← e1, ← e2, ← e3]; exact hR
  obtain ⟨t', C', hr, x', ht', hC', hR', hB'⟩ := h t C ⟨x, ht, hC, hR0, hBI x hB⟩
  refine ⟨t', C', hr, x', ht', hC', ?_, hBJ x' hB'⟩
  have e1 : J'.R = J.R := congrArg Cut.R hJ
  have e2 : J'.s0 = J.s0 := congrArg Cut.s0 hJ
  have e3 : J'.tab0 = J.tab0 := congrArg Cut.tab0 hJ
  rw [e1, e2, e3]; exact hR'

end Conv

/-! ## The bookkeeping over a world -/

section Book
variable (Wd : World)

/-- The fixed parameters of the prefill bookkeeping over `Wd` (`PrefP`). -/
structure PrefPW where
  P : Wd.Par
  aP : Nat
  π : List Nat
  fixA : List Nat

/-- **The bookkeeping at a cut** over `Wd` (`CutBook`). -/
structure CutBookW (Q : PrefPW Wd) (s0 : St Wd.F.S) (frs : List Nat) (D H N : Nat) (x : SegInst Wd.F) : Prop where
  prompt : x.K.fr Q.aP = some ([], Q.π.map natV)
  framed : ∀ a, x.K.fr a ≠ none ↔ a ∈ frs
  lo : x.K.lo = Wd.lo Q.P
  hi : x.K.hi = Wd.E Q.P
  base : x.K.base = s0.trace
  D : x.K.D ≤ D
  H : (Wd.toMlx x.t.ffi).next ≤ (Wd.toMlx s0.ffi).next + H
  N : (Wd.toMlx x.t.ffi).nnext ≤ (Wd.toMlx s0.ffi).nnext + N
  fix : ∀ a ∈ Q.fixA, x.M.a a = a

variable {Wd}

theorem CutBookW.mono {Q : PrefPW Wd} {s0 : St Wd.F.S} {frs : List Nat} {D H N D' H' N' : Nat}
    {x : SegInst Wd.F} (h : CutBookW Wd Q s0 frs D H N x) (hD : D ≤ D') (hH : H ≤ H') (hN : N ≤ N') :
    CutBookW Wd Q s0 frs D' H' N' x :=
  { h with D := Nat.le_trans h.D hD, H := by have := h.H; omega, N := by have := h.N; omega }

variable (Wd)

/-- **The facts of a restart** over `Wd` (`LoadPost`). -/
structure LoadPostW (sA sF sB : St Wd.F.S) (aP : Nat) (frsB fixA : List Nat) (x x1 x' : SegInst Wd.F) : Prop where
  off : x.t.next = sA.next + x.K.D
  grows : sA.next ≤ sF.next
  mgrows : (Wd.toMlx sA.ffi).next ≤ (Wd.toMlx sF.ffi).next
  ngrows : (Wd.toMlx sA.ffi).nnext ≤ (Wd.toMlx sF.ffi).nnext
  next : x1.t.next = x.t.next + (sF.next - sA.next)
  mnext : (Wd.toMlx x1.t.ffi).next = (Wd.toMlx x.t.ffi).next + ((Wd.toMlx sF.ffi).next - (Wd.toMlx sA.ffi).next)
  mnnext : (Wd.toMlx x1.t.ffi).nnext =
    (Wd.toMlx x.t.ffi).nnext + ((Wd.toMlx sF.ffi).nnext - (Wd.toMlx sA.ffi).nnext)
  t : x'.t = x1.t
  D : x'.K.D = x1.t.next - sB.next
  lo : x'.K.lo = x.K.lo
  hi : x'.K.hi = x.K.hi
  base : x'.K.base = sB.trace
  prompt : x'.K.fr aP = x.K.fr aP
  framed : ∀ a, x'.K.fr a ≠ none ↔ a ∈ frsB
  fix : ∀ a ∈ fixA, x.M.a a = a → x'.M.a a = a

variable {Wd}

/-- **The bookkeeping across a restart** (`CutBook.restart`). -/
theorem CutBookW.restart {Q : PrefPW Wd} {sA sF sB : St Wd.F.S} {frsA frsB : List Nat} {D H N : Nat}
    {x x1 x' : SegInst Wd.F} (hb : CutBookW Wd Q sA frsA D H N x)
    (hp : LoadPostW Wd sA sF sB Q.aP frsB Q.fixA x x1 x') :
    CutBookW Wd Q sB frsB (D + (sF.next - sB.next)) (H + ((Wd.toMlx sF.ffi).next - (Wd.toMlx sB.ffi).next))
      (N + ((Wd.toMlx sF.ffi).nnext - (Wd.toMlx sB.ffi).nnext)) x' where
  prompt := by rw [hp.prompt]; exact hb.prompt
  framed := hp.framed
  lo := by rw [hp.lo]; exact hb.lo
  hi := by rw [hp.hi]; exact hb.hi
  base := hp.base
  D := by have := hp.off; have := hp.next; have := hp.grows; have := hb.D; rw [hp.D]; omega
  H := by have := hp.mnext; have := hp.mgrows; have := hb.H; rw [hp.t]; omega
  N := by have := hp.mnnext; have := hp.ngrows; have := hb.N; rw [hp.t]; omega
  fix := fun a ha => hp.fix a ha (hb.fix a ha)

variable (Wd)

/-- The bookkeeping of an invariant at a cut over `Wd` (`bookB`). -/
def bookBW (Q : PrefPW Wd) (s0 : St Wd.F.S) (frs : List Nat) (ν : Nat → F64) (D H N : Nat)
    (G : SegInst Wd.F → Prop) (x : SegInst Wd.F) : Prop :=
  x.ν = ν ∧ CutBookW Wd Q s0 frs D H N x ∧ G x

/-- **A case with the world's restart facts** (`BCase`). -/
structure BCaseW (L : SegLaws Wd.F) (A B : Cut Wd.F) (pp : PrefPW Wd) (frsB : List Nat) extends XCase L A B where
  θ : Nat → SymE
  post : ∀ x x1 x', R0 x A.s0 S0 → Post x x1 x' →
    LoadPostW Wd A.s0 case.sF B.s0 pp.aP frsB pp.fixA x x1 x' ∧ x'.ν = Shift.valuation θ x.ν

variable {Wd}

/-- **What a bookkept case needs** (`BCase.Ok`). -/
structure BCaseW.Ok {L : SegLaws Wd.F} {A B : Cut Wd.F} {Q : PrefPW Wd} {frsB : List Nat} (c : BCaseW Wd L A B Q frsB)
    (frsA : List Nat) (νA νB : Nat → F64) (DA HA NA DB HB NB : Nat) (GA GB : SegInst Wd.F → Prop) : Prop where
  entry : ∀ x, x.ν = νA → CutBookW Wd Q A.s0 frsA DA HA NA x → GA x → c.Q x
  good : Good νA c.S0.oracle
  val : Shift.valuation c.θ νA = νB
  D : DA + (c.case.sF.next - B.s0.next) ≤ DB
  H : HA + ((Wd.toMlx c.case.sF.ffi).next - (Wd.toMlx B.s0.ffi).next) ≤ HB
  N : NA + ((Wd.toMlx c.case.sF.ffi).nnext - (Wd.toMlx B.s0.ffi).nnext) ≤ NB
  graph : c.Book (bookBW Wd Q A.s0 frsA νA DA HA NA GA) GB

/-- **A bookkept case's cut step** (`book_step`). -/
theorem book_stepW {L : SegLaws Wd.F} {A B : Cut Wd.F} {Q : PrefPW Wd} {frsA frsB : List Nat}
    (c : BCaseW Wd L A B Q frsB) {νA νB : Nat → F64} {DA HA NA DB HB NB : Nat} {GA GB : SegInst Wd.F → Prop}
    (h : c.Ok frsA νA νB DA HA NA DB HB NB GA GB) :
    CutStep (A.with (bookBW Wd Q A.s0 frsA νA DA HA NA GA)) (B.with (bookBW Wd Q B.s0 frsB νB DB HB NB GB)) c.n := by
  refine c.toXCase.step (fun x ⟨hv, hb, hg⟩ => ⟨hv ▸ h.good, h.entry x hv hb hg⟩) ?_
  intro x x1 x' hR hB h0 hst hend ht hC hR' hP
  obtain ⟨hv, hb, hg⟩ := hB
  obtain ⟨hp, hval⟩ := c.post x x1 x' h0 hP
  refine ⟨by rw [hval, hv, h.val], (hb.restart hp).mono h.D h.H h.N, ?_⟩
  exact h.graph x x1 x' hR ⟨hv, hb, hg⟩ h0 hst hend ht hC hR' hP

end Book

/-! ## The drains, the tail, the final step -/

section Drains
variable {Wd : World}

/-- The drain cut's invariant cut after `k` drains over `Wd` (`prefCut`). -/
def prefCutW (pc : Cut Wd.F) (Q : PrefPW Wd) (frs : List Nat) (PV : Nat → Nat → Nat → Nat → F64) (C : Nat)
    (W : PrefCtr) (Gp : Nat → SegInst Wd.F → Prop) (k : Nat) : ICut Wd.F :=
  pc.with (bookBW Wd Q pc.s0 frs (prefVal PV C k) (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN) (Gp k))

/-- **The prefill invariant** over `Wd` (`PrefillInv`). -/
def PrefillInvW (pc : Cut Wd.F) (Q : PrefPW Wd) (frs : List Nat) (PV : Nat → Nat → Nat → Nat → F64) (C : Nat)
    (W : PrefCtr) (Gp : Nat → SegInst Wd.F → Prop) (k : Nat) (t : St Wd.F.S) (Cs : CSrv) : Prop :=
  (prefCutW pc Q frs PV C W Gp k).Inv t Cs

/-- **A drain's obligations** over `Wd` (`DrainOk`). -/
def DrainOkW {L : SegLaws Wd.F} {pc : Cut Wd.F} {Q : PrefPW Wd} {frs : List Nat} (dc : BCaseW Wd L pc pc Q frs)
    (PV : Nat → Nat → Nat → Nat → F64) (C : Nat) (W : PrefCtr) (Gp : Nat → SegInst Wd.F → Prop) (k : Nat) : Prop :=
  dc.Ok frs (prefVal PV C k) (prefVal PV C (k + 1)) (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN)
    (W.D0 + (k + 1) * W.ΔJ) (W.H0 + (k + 1) * W.ΔH) (W.N0 + (k + 1) * W.ΔN) (Gp k) (Gp (k + 1))

/-- `DrainOkW` from the template's deltas (`DrainOk.of`). -/
theorem DrainOkW.of {L : SegLaws Wd.F} {pc : Cut Wd.F} {Q : PrefPW Wd} {frs : List Nat} {dc : BCaseW Wd L pc pc Q frs}
    {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr} {Gp : Nat → SegInst Wd.F → Prop} {k : Nat}
    (hentry : ∀ x, x.ν = prefVal PV C k →
      CutBookW Wd Q pc.s0 frs (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN) x → Gp k x → dc.Q x)
    (hgood : Good (prefVal PV C k) dc.S0.oracle)
    (hnext : Shift.valuation dc.θ (prefVal PV C k) = prefVal PV C (k + 1))
    (hdJ : dc.case.sF.next - pc.s0.next ≤ W.ΔJ)
    (hdH : (Wd.toMlx dc.case.sF.ffi).next - (Wd.toMlx pc.s0.ffi).next ≤ W.ΔH)
    (hdN : (Wd.toMlx dc.case.sF.ffi).nnext - (Wd.toMlx pc.s0.ffi).nnext ≤ W.ΔN)
    (hG : dc.Book (bookBW Wd Q pc.s0 frs (prefVal PV C k) (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN)
      (Gp k)) (Gp (k + 1))) :
    DrainOkW dc PV C W Gp k where
  entry := hentry
  good := hgood
  val := hnext
  D := by have e : (k + 1) * W.ΔJ = k * W.ΔJ + W.ΔJ := Nat.succ_mul k W.ΔJ; omega
  H := by have e : (k + 1) * W.ΔH = k * W.ΔH + W.ΔH := Nat.succ_mul k W.ΔH; omega
  N := by have e : (k + 1) * W.ΔN = k * W.ΔN + W.ΔN := Nat.succ_mul k W.ΔN; omega
  graph := hG

/-- **One drain** over `Wd` (`prefill_step`). -/
theorem prefill_stepW {L : SegLaws Wd.F} {pc : Cut Wd.F} {Q : PrefPW Wd} {frs : List Nat}
    (dc : BCaseW Wd L pc pc Q frs) {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr}
    {Gp : Nat → SegInst Wd.F → Prop} {k : Nat} (h : DrainOkW dc PV C W Gp k) :
    CutStep (prefCutW pc Q frs PV C W Gp k) (prefCutW pc Q frs PV C W Gp (k + 1)) dc.n :=
  book_stepW dc h

/-- **All drains** over `Wd` (`prefill_all`). -/
theorem prefill_allW {L : SegLaws Wd.F} {pc : Cut Wd.F} {Q : PrefPW Wd} {frs : List Nat}
    (sel : Nat → BCaseW Wd L pc pc Q frs) {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr}
    {Gp : Nat → SegInst Wd.F → Prop} (m k : Nat) (h : ∀ j, k ≤ j → j < k + m → DrainOkW (sel j) PV C W Gp j)
    {t : St Wd.F.S} {Cs : CSrv} (hinv : PrefillInvW pc Q frs PV C W Gp k t Cs) :
    ∃ t' Cs', runC Wd.F (iterSteps (fun j => (sel j).n) k m) t Cs = some (t', Cs') ∧
      PrefillInvW pc Q frs PV C W Gp (k + m) t' Cs' :=
  CutStep.iter (prefCutW pc Q frs PV C W Gp) (fun j => (sel j).n) (fun j => k ≤ j ∧ j < k + m)
    (fun j hj => prefill_stepW (sel j) (h j hj.1 hj.2)) m k (fun j hj => ⟨by omega, by omega⟩) t Cs hinv

/-- The pre-final cut's invariant cut over `Wd` (`preFinalCut`). -/
def preFinalCutW (pf : Cut Wd.F) (Q : PrefPW Wd) (frs : List Nat) (PVf : Nat → Nat → Nat → F64) (Lp : Nat)
    (D H N : Nat) (Gf : SegInst Wd.F → Prop) : ICut Wd.F :=
  pf.with (bookBW Wd Q pf.s0 frs (PVf (Lp - 1) (capL (Lp - 1))) D H N Gf)

/-- **The tail** over `Wd` (`tail_step`). -/
theorem tail_stepW {L : SegLaws Wd.F} {pc pf : Cut Wd.F} {Q : PrefPW Wd} {frs frsF : List Nat}
    (tc : BCaseW Wd L pc pf Q frsF) {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr}
    {Gp : Nat → SegInst Wd.F → Prop} {k : Nat} {PVf : Nat → Nat → Nat → F64} {Lp D H N : Nat}
    {Gf : SegInst Wd.F → Prop}
    (h : tc.Ok frs (prefVal PV C k) (PVf (Lp - 1) (capL (Lp - 1)))
      (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN) D H N (Gp k) Gf) :
    CutStep (prefCutW pc Q frs PV C W Gp k) (preFinalCutW pf Q frsF PVf Lp D H N Gf) tc.n :=
  book_stepW tc h

/-- **The final step** over `Wd` (`final_d1_step`). -/
theorem final_d1_stepW {L : SegLaws Wd.F} {pf ps : Cut Wd.F} {Q : PrefPW Wd} {frs frsS : List Nat}
    (fc : BCaseW Wd L pf ps Q frsS) {PVf : Nat → Nat → Nat → F64} {Lp D H N : Nat} {Gf : SegInst Wd.F → Prop}
    {νS : Nat → F64} {D' H' N' : Nat} {GS : SegInst Wd.F → Prop}
    (h : fc.Ok frs (PVf (Lp - 1) (capL (Lp - 1))) νS D H N D' H' N' Gf GS) :
    CutStep (preFinalCutW pf Q frs PVf Lp D H N Gf) (ps.with (bookBW Wd Q ps.s0 frsS νS D' H' N' GS)) fc.n :=
  book_stepW fc h

end Drains

/-! ## The whole prefill over a world's FFI -/

/-- The invariants of the prefill chain at its cuts (`PrefInvs`), over the FFI `F`. -/
structure PrefInvsW (F : Ffi) where
  ld : Nat → ICut F
  pc0 : Nat → ICut F
  pc : Nat → Nat → ICut F
  pf : Nat → ICut F
  ps : Nat → ICut F
  dec : Nat → ICut F

section Whole
variable {F : Ffi}

/-- The pre-final cut of each source (`PrefInvs.pre`). -/
def PrefInvsW.pre (I : PrefInvsW F) (L : Nat) : PFSrc → ICut F
  | .first => I.pc0 L
  | .drained => I.pc L (drains L)
  | .tailed => I.pf L

/-- **The checked steps of the prefill chain up to its exit** (`PrefSteps` without POST), each class's
step at the prompt lengths `1 ≤ L ≤ 262143` where it applies (the class covers hold there; the top
theorems derive the range from `1 ≤ |π|`, `1 ≤ T`, `|π| + T ≤ 262144`). An EOS as the first sampled
token halts from the exit cut, so it needs no POST. -/
structure PrefStepsPW (I : PrefInvsW F) where
  nSetup : SetupClass → Nat
  setup : ∀ c L, 1 ≤ L → L ≤ 262143 → c.Applies L → CutStep (I.ld L) (I.pc0 L) (nSetup c)
  nFirst : FirstClass → Nat
  firstDrain : ∀ C L, 1 ≤ L → L ≤ 262143 → (FirstClass.drain C).Applies L →
    CutStep (I.pc0 L) (I.pc L 1) (nFirst (.drain C))
  firstTail : ∀ X L, 1 ≤ L → L ≤ 262143 → (FirstClass.tail X).Applies L →
    CutStep (I.pc0 L) (I.pf L) (nFirst (.tail X))
  nDrain : DrainClass → Nat
  drain : ∀ d L j, 1 ≤ L → L ≤ 262143 → d.Applies L j → CutStep (I.pc L j) (I.pc L (j + 1)) (nDrain d)
  nTail : TailClass → Nat
  tail : ∀ c L, 1 ≤ L → L ≤ 262143 → c.Applies L → CutStep (I.pc L (drains L)) (I.pf L) (nTail c)
  nFinal : PFSrc → FinalClass → Nat
  final : ∀ c L, 1 ≤ L → L ≤ 262143 → c.Applies L →
    CutStep (I.pre L (pfSrcOf L)) (I.ps L) (nFinal (pfSrcOf L) c)

/-- **The checked steps of the prefill chain** (`PrefSteps`): up to the exit, and POST. -/
structure PrefStepsW (I : PrefInvsW F) extends PrefStepsPW I where
  nPost : PostClass → Nat
  post : ∀ c L, 1 ≤ L → L ≤ 262143 → c.Applies L → CutStep (I.ps L) (I.dec L) (nPost c)

/-- The steps of the prefill route of `L` up to the exit. -/
def PrefStepsPW.n {I : PrefInvsW F} (S : PrefStepsPW I) (L : Nat) : Nat :=
  S.nSetup (setupOf L) +
    (if 1 ≤ drains L then
      S.nFirst (.drain (chunkC L)) + iterSteps (fun j => S.nDrain (drainOf L j)) 1 (drains L - 1) +
        (if 1 ≤ tailRows L then S.nTail (tailOf L) else 0)
    else if 2 ≤ L then S.nFirst (.tail (rowClass (L - 1))) else 0) +
    S.nFinal (pfSrcOf L) (finalOf L)

/-- The steps of the prefill route of `L` (`PrefSteps.n`). -/
def PrefStepsW.n {I : PrefInvsW F} (S : PrefStepsW I) (L : Nat) : Nat := S.toPrefStepsPW.n L + S.nPost (postOf L)

/-- The prefill up to the pre-final cut, from the first call (`prefill_mid`). -/
theorem prefill_midW {I : PrefInvsW F} (S : PrefStepsPW I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.pc0 L) (I.pre L (pfSrcOf L))
      (if 1 ≤ drains L then
        S.nFirst (.drain (chunkC L)) + iterSteps (fun j => S.nDrain (drainOf L j)) 1 (drains L - 1) +
          (if 1 ≤ tailRows L then S.nTail (tailOf L) else 0)
      else if 2 ≤ L then S.nFirst (.tail (rowClass (L - 1))) else 0) := by
  have hcov := chain_cover L h1 h2
  have e := drains_tail L
  by_cases hd : 1 ≤ drains L
  · rw [ite_eq_left hd]
    have hL1 : L ≠ 1 := by
      intro hL; subst hL; simp [drains] at hd
    have hfirst := S.firstDrain (chunkC L) L h1 h2 ⟨rfl, hd⟩
    have hdr : CutStep (I.pc L 1) (I.pc L (drains L))
        (iterSteps (fun j => S.nDrain (drainOf L j)) 1 (drains L - 1)) := by
      have := CutStep.iter (I.pc L) (fun j => S.nDrain (drainOf L j)) (fun j => 1 ≤ j ∧ j + 1 ≤ drains L)
        (fun j hj => S.drain (drainOf L j) L j h1 h2 (hcov.2.2.1 j hj.1 hj.2).2.1) (drains L - 1) 1
        (fun j hj => ⟨by omega, by omega⟩)
      exact this.cast rfl (by rw [show 1 + (drains L - 1) = drains L by omega]) rfl
    by_cases ht : 1 ≤ tailRows L
    · rw [ite_eq_left ht]
      have hsrc : pfSrcOf L = .tailed := by unfold pfSrcOf; rw [ite_eq_right hL1, ite_eq_right (by omega)]
      rw [hsrc]
      have htl := S.tail (tailOf L) L h1 h2 (tail_cover (by omega) hd ht).2.1
      exact (hfirst.trans hdr).trans htl
    · rw [ite_eq_right ht]
      have hsrc : pfSrcOf L = .drained := by unfold pfSrcOf; rw [ite_eq_right hL1, ite_eq_left (by omega)]
      rw [hsrc]
      exact ((hfirst.trans hdr).trans (CutStep.refl _)).cast rfl rfl rfl
  · rw [ite_eq_right hd]
    have h0 : drains L = 0 := by omega
    by_cases hL2 : 2 ≤ L
    · rw [ite_eq_left hL2]
      have htr : tailRows L = L - 1 := by rw [h0] at e; omega
      have hsrc : pfSrcOf L = .tailed := by unfold pfSrcOf; rw [ite_eq_right (by omega), ite_eq_right (by omega)]
      rw [hsrc]
      obtain ⟨-, hm, -⟩ := rowClass_spec (t := L - 1) (by omega) (by have := drains_zero_le (by omega) h0; omega)
      exact S.firstTail (rowClass (L - 1)) L h1 h2 ⟨h0, hL2, hm⟩
    · rw [ite_eq_right hL2]
      have hsrc : pfSrcOf L = .first := by unfold pfSrcOf; rw [ite_eq_left (by omega)]
      rw [hsrc]
      exact CutStep.refl _

/-- **The prefill reaches its exit cut**. -/
theorem prefill_reach_psW {I : PrefInvsW F} (S : PrefStepsPW I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.ld L) (I.ps L) (S.n L) := by
  have hcov := chain_cover L h1 h2
  have hs := S.setup (setupOf L) L h1 h2 hcov.1.2.1
  have hf := S.final (finalOf L) L h1 h2 hcov.2.2.2.2.2.1.2.1
  exact (hs.trans (prefill_midW S h1 h2)).trans hf

/-- POST at `L`, from its class. -/
theorem PrefStepsW.post_at {I : PrefInvsW F} (S : PrefStepsW I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.ps L) (I.dec L) (S.nPost (postOf L)) :=
  S.post (postOf L) L h1 h2 (chain_cover L h1 h2).2.2.2.2.2.2.2.1

/-- **The prefill reaches the decode cut** (`prefill_reach`). -/
theorem prefill_reachW {I : PrefInvsW F} (S : PrefStepsW I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.ld L) (I.dec L) (S.n L) :=
  (prefill_reach_psW S.toPrefStepsPW h1 h2).trans (S.post_at h1 h2)

/-- A decode route from the decode cut (`DecodeRoute`). -/
def DecodeRouteW (Idec : ICut F) (t0 : St F.S) (C0 : CSrv) (Goal : Prop) : Prop :=
  ∀ N t1 C1, runC F N t0 C0 = some (t1, C1) → Idec.Inv t1 C1 → Goal

/-- **The route from the boot run**, for any decode route (`source_prompt`). -/
theorem source_promptW {I : PrefInvsW F} (S : PrefStepsW I) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 262143)
    {N0 : Nat} {t0 tL : St F.S} {C0 CL : CSrv} (hboot : runC F N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL) {Goal : Prop} (hD : DecodeRouteW (I.dec L) t0 C0 Goal) : Goal := by
  obtain ⟨t1, C1, hr, h1⟩ := prefill_reachW S hL1 hL2 tL CL hld
  exact hD _ t1 C1 (runC_trans hboot hr) h1

end Whole

end Host.Ts.Sim.Prefill
