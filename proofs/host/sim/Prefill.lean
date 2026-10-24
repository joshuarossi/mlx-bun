import host.sim.Seg
import host.sim.PrefillSched
import host.sim.GeneralL
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The prefill chain

The prefill of a prompt of `L` tokens is a chain of template cases between cuts (design
`host-L-design.md` §3.2-3.4): loadDone →SETUP→ the first `nextPrefillStep` call (PC0) →DRAIN-first→
the drain cut after one drain → … DRAIN-later … → the drain cut after `k` drains →TAIL→ the pre-final
cut (`o = L - 1`) →FINAL→ the prefill loop's exit →POST→ the decode cut `i = 1`.

* A cut (`Cut`) is a template start with its relation family (generic: `Rel` under the native
  relation, or a relation with further frames); with the bookkeeping of an invariant it is an
  `ICut`, whose invariant `ICut.Inv` holds of a target when some related pair satisfies the
  bookkeeping. `CutStep I J n`: `n` target steps take `I`'s invariant to `J`'s (`trans`, `iter` by
  `loop_induct`).
* A case between cuts (`XCase`: a `SegCase` restarting into the next cut, with its entry) gives a
  `CutStep` (`XCase.step`). In the load world the bookkeeping is `CutBook` (design §3.4: the framed
  prompt, the framed set, the fixed handle band, the base trace, counter bounds, fixed addresses)
  and a restart gives the facts `LoadPost` (`load_restart`'s shape) and the substituted valuation;
  `BCase` is a case with those facts, and `book_step` its cut step under `BCase.Ok`.
* `PrefillInv … k` (the drain cut after `k` drains, offset `k·C`, capacity `capL (k·C)`),
  `prefill_step` (one DRAIN-later case), `prefill_all` (`loop_induct` over the drains),
  `PreFinalInv` (`o = L - 1`), `tail_step`, `final_d1_step` (FINAL to the loop exit), `post_stepL` (POST
  to the decode cut: `LoopInvL … 1`, `loopCut_inv`).
* `PrefSteps`: the checked steps of every class of the chain (`host.sim.PrefillSched`), each a
  `CutStep` where its class applies. `prefill_reach`: for every `L ∈ [1, 262143]` the chain of `L`'s
  classes takes the loadDone invariant to the decode cut's. `source_tokens_promptL`,
  `source_tokens_prompt_eosL`: with the boot run to loadDone and the decode loop (`loop_sourceL`,
  `loop_source_eosL`) the route halts with the emitted readbacks. -/

/-! ## Cuts and cut steps -/

section Cuts
variable {F : Ffi}

/-- A template cut: the start state, its oracle-free table and the relation family there. -/
structure Cut (F : Ffi) where
  s0 : St F.S
  tab0 : List SymE
  R : SRel F

/-- A cut with the bookkeeping `B` of an invariant (a predicate of the related pair). -/
structure ICut (F : Ffi) extends Cut F where
  B : SegInst F → Prop

/-- The cut `c` with bookkeeping `B`. -/
def Cut.with (c : Cut F) (B : SegInst F → Prop) : ICut F := { c with B }

/-- **The invariant at a cut**: some pair related to the cut's start, with target `(t, C)`, satisfies
the bookkeeping. -/
def ICut.Inv (I : ICut F) (t : St F.S) (C : CSrv) : Prop :=
  ∃ x : SegInst F, x.t = t ∧ x.C = C ∧ I.R x I.s0 ⟨I.tab0, []⟩ ∧ I.B x

/-- **A cut step**: `n` target steps take `I`'s invariant to `J`'s. -/
def CutStep (I J : ICut F) (n : Nat) : Prop :=
  ∀ t C, I.Inv t C → ∃ t' C', runC F n t C = some (t', C') ∧ J.Inv t' C'

theorem CutStep.refl (I : ICut F) : CutStep I I 0 := fun t C h => ⟨t, C, rfl, h⟩

theorem CutStep.trans {I J K : ICut F} {n m : Nat} (h1 : CutStep I J n) (h2 : CutStep J K m) :
    CutStep I K (n + m) := by
  intro t C h
  obtain ⟨t1, C1, hr1, h1'⟩ := h1 t C h
  obtain ⟨t2, C2, hr2, h2'⟩ := h2 t1 C1 h1'
  exact ⟨t2, C2, runC_trans hr1 hr2, h2'⟩

theorem CutStep.cast {I J I' J' : ICut F} {n n' : Nat} (h : CutStep I J n) (hI : I' = I) (hJ : J' = J)
    (hn : n' = n) : CutStep I' J' n' := by
  subst hI hJ hn; exact h

/-- **Iterated cut steps** (`loop_induct`). -/
theorem CutStep.iter (I : Nat → ICut F) (len : Nat → Nat) (ok : Nat → Prop)
    (h : ∀ j, ok j → CutStep (I j) (I (j + 1)) (len j)) :
    ∀ m k, (∀ j, j < m → ok (k + j)) → CutStep (I k) (I (k + m)) (iterSteps len k m) := by
  intro m k hm t C hinv
  exact loop_induct (fun j t C => (I j).Inv t C) ok len (fun j t C hj hok => h j hok t C hj) m k t C hinv hm

/-- **A restarting segment case is a cut step**: from the start cut's invariant (entered into the
chain's start relation), the case's steps reach a pair related to the next cut, whose bookkeeping
`book` derives from the case's start, end and restart facts. -/
theorem cutStep_of_case {L : SegLaws F} {A B : Cut F} {S0 : SSrv} {R0 : SRel F}
    {Post : SegInst F → SegInst F → SegInst F → Prop}
    (c : SegCase L R0 A.s0 S0 (.restart B.R B.s0 ⟨B.tab0, []⟩ Post)) {BA BB : SegInst F → Prop}
    (entry : ∀ x, A.R x A.s0 ⟨A.tab0, []⟩ → BA x → R0 x A.s0 S0)
    (book : ∀ x x1 x', A.R x A.s0 ⟨A.tab0, []⟩ → BA x → R0 x A.s0 S0 → x.Step L c.n S0.tab.length x1 →
      c.Rend x1 c.sF c.SF → x'.t = x1.t → x'.C = x1.C → B.R x' B.s0 ⟨B.tab0, []⟩ → Post x x1 x' → BB x') :
    CutStep (A.with BA) (B.with BB) c.n := by
  rintro t C ⟨x, rfl, rfl, hR, hB⟩
  have h0 := entry x hR hB
  obtain ⟨x1, x', hst, hend, ht, hC, hR', hP⟩ := seg_restart c h0
  exact ⟨x1.t, x1.C, hst.run, x', ht, hC, hR', book x x1 x' hR hB h0 hst hend ht hC hR' hP⟩

/-- **A case from cut `A` into cut `B`** (`B = A` for a self-restart): its server (the template
table with the case's oracle), the chain's start relation `R0`, the restart's facts `Post`, and the
entry (a pair related at `A` whose valuation satisfies the oracle and the entry condition `Q`, e.g.
the acceptances' context and value predicates, is related to the chain's start). -/
structure XCase (L : SegLaws F) (A B : Cut F) where
  S0 : SSrv
  tab : S0.tab = A.tab0
  R0 : SRel F
  Post : SegInst F → SegInst F → SegInst F → Prop
  case : SegCase L R0 A.s0 S0 (.restart B.R B.s0 ⟨B.tab0, []⟩ Post)
  Q : SegInst F → Prop
  entry : ∀ x, A.R x A.s0 ⟨A.tab0, []⟩ → Good x.ν S0.oracle → Q x → R0 x A.s0 S0

/-- The target steps of a case. -/
abbrev XCase.n {L : SegLaws F} {A B : Cut F} (c : XCase L A B) : Nat := c.case.n

/-- A case's obligation from the start bookkeeping `BA` to a property `BB` of the restarted pair. -/
def XCase.Book {L : SegLaws F} {A B : Cut F} (c : XCase L A B) (BA BB : SegInst F → Prop) : Prop :=
  ∀ x x1 x', A.R x A.s0 ⟨A.tab0, []⟩ → BA x → c.R0 x A.s0 c.S0 → x.Step L c.n c.S0.tab.length x1 →
    c.case.Rend x1 c.case.sF c.case.SF → x'.t = x1.t → x'.C = x1.C → B.R x' B.s0 ⟨B.tab0, []⟩ →
    c.Post x x1 x' → BB x'

/-- **A case's cut step.** -/
theorem XCase.step {L : SegLaws F} {A B : Cut F} (c : XCase L A B) {BA BB : SegInst F → Prop}
    (hQ : ∀ x, BA x → Good x.ν c.S0.oracle ∧ c.Q x) (hb : c.Book BA BB) : CutStep (A.with BA) (B.with BB) c.n :=
  cutStep_of_case c.case (fun x hR hB => c.entry x hR (hQ x hB).1 (hQ x hB).2) hb

end Cuts

/-! ## The load world's bookkeeping -/

/-- The fixed parameters of the prefill bookkeeping: the native parameters, the prompt array's
address and the prompt, the addresses every map fixes. -/
structure PrefP where
  P : LoadP
  aP : Nat
  π : List Nat
  fixA : List Nat

/-- **The bookkeeping at a cut** (design §3.4) with template start `s0`: the prompt framed with
template prefix `[]` and target prefix `π`, the framed addresses `frs` (the prompt and the ghost
slots; `forwarded` and `emitted` are empty and unframed), the renamed handle band, the base trace,
the counter offset within `D` and the target's handle and node counters within `H`, `N` of the
template's, the fixed addresses. -/
structure CutBook (Q : PrefP) (s0 : St LF.S) (frs : List Nat) (D H N : Nat) (x : SegInst LF) : Prop where
  prompt : x.K.fr Q.aP = some ([], Q.π.map natV)
  framed : ∀ a, x.K.fr a ≠ none ↔ a ∈ frs
  lo : x.K.lo = Q.P.lo
  hi : x.K.hi = Q.P.E
  base : x.K.base = s0.trace
  D : x.K.D ≤ D
  H : x.t.ffi.mlx.next ≤ s0.ffi.mlx.next + H
  N : x.t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + N
  fix : ∀ a ∈ Q.fixA, x.M.a a = a

theorem CutBook.mono {Q : PrefP} {s0 : St LF.S} {frs : List Nat} {D H N D' H' N' : Nat} {x : SegInst LF}
    (h : CutBook Q s0 frs D H N x) (hD : D ≤ D') (hH : H ≤ H') (hN : N ≤ N') : CutBook Q s0 frs D' H' N' x :=
  { h with D := Nat.le_trans h.D hD, H := by have := h.H; omega, N := by have := h.N; omega }

/-- **The facts of a load-world restart** from a case started at `sA` (pair `x`), whose chain ended at
`sF` (pair `x1`), into the template start `sB` (pair `x'`): the start offset, the lockstep counters
along the case, the restarted context (offset to `sB`, the band, the base trace `sB.trace`, the
prompt's frame kept, the framed set `frsB`), the fixed addresses kept (`load_restart`'s shape). -/
structure LoadPost (sA sF sB : St LF.S) (aP : Nat) (frsB fixA : List Nat) (x x1 x' : SegInst LF) : Prop where
  off : x.t.next = sA.next + x.K.D
  grows : sA.next ≤ sF.next
  mgrows : sA.ffi.mlx.next ≤ sF.ffi.mlx.next
  ngrows : sA.ffi.mlx.nnext ≤ sF.ffi.mlx.nnext
  next : x1.t.next = x.t.next + (sF.next - sA.next)
  mnext : x1.t.ffi.mlx.next = x.t.ffi.mlx.next + (sF.ffi.mlx.next - sA.ffi.mlx.next)
  mnnext : x1.t.ffi.mlx.nnext = x.t.ffi.mlx.nnext + (sF.ffi.mlx.nnext - sA.ffi.mlx.nnext)
  t : x'.t = x1.t
  D : x'.K.D = x1.t.next - sB.next
  lo : x'.K.lo = x.K.lo
  hi : x'.K.hi = x.K.hi
  base : x'.K.base = sB.trace
  prompt : x'.K.fr aP = x.K.fr aP
  framed : ∀ a, x'.K.fr a ≠ none ↔ a ∈ frsB
  fix : ∀ a ∈ fixA, x.M.a a = a → x'.M.a a = a

/-- **The bookkeeping across a restart**: the counter bounds grow by the case's end counters over the
next template's. -/
theorem CutBook.restart {Q : PrefP} {sA sF sB : St LF.S} {frsA frsB : List Nat} {D H N : Nat}
    {x x1 x' : SegInst LF} (hb : CutBook Q sA frsA D H N x) (hp : LoadPost sA sF sB Q.aP frsB Q.fixA x x1 x') :
    CutBook Q sB frsB (D + (sF.next - sB.next)) (H + (sF.ffi.mlx.next - sB.ffi.mlx.next))
      (N + (sF.ffi.mlx.nnext - sB.ffi.mlx.nnext)) x' where
  prompt := by rw [hp.prompt]; exact hb.prompt
  framed := hp.framed
  lo := by rw [hp.lo]; exact hb.lo
  hi := by rw [hp.hi]; exact hb.hi
  base := hp.base
  D := by have := hp.off; have := hp.next; have := hp.grows; have := hb.D; rw [hp.D]; omega
  H := by have := hp.mnext; have := hp.mgrows; have := hb.H; rw [hp.t]; omega
  N := by have := hp.mnnext; have := hp.ngrows; have := hb.N; rw [hp.t]; omega
  fix := fun a ha => hp.fix a ha (hb.fix a ha)

/-- The bookkeeping of an invariant at a cut: the valuation `ν`, `CutBook`, and the graph side `G`. -/
def bookB (Q : PrefP) (s0 : St LF.S) (frs : List Nat) (ν : Nat → F64) (D H N : Nat) (G : SegInst LF → Prop)
    (x : SegInst LF) : Prop :=
  x.ν = ν ∧ CutBook Q s0 frs D H N x ∧ G x

/-- **A case with the load world's restart facts**: the restart's facts give `LoadPost` into the
next cut (framed set `frsB`) and the valuation substituted by `θ`. -/
structure BCase (L : SegLaws LF) (A B : Cut LF) (pp : PrefP) (frsB : List Nat) extends XCase L A B where
  θ : Nat → SymE
  post : ∀ x x1 x', R0 x A.s0 S0 → Post x x1 x' →
    LoadPost A.s0 case.sF B.s0 pp.aP frsB pp.fixA x x1 x' ∧ x'.ν = Shift.valuation θ x.ν

/-- **What a bookkept case needs** from the start bookkeeping (valuation `νA`, framed set `frsA`,
bounds `DA HA NA`, graph side `GA`) to the next (`νB`, `frsB`, `DB HB NB`, `GB`): the entry
condition, the oracle at `νA` (LinGood, per class), the restart's substitution taking `νA` to `νB`,
the bounds, and the graph obligation (`GB` of the restarted pair from the case's start, run and
end). -/
structure BCase.Ok {L : SegLaws LF} {A B : Cut LF} {Q : PrefP} {frsB : List Nat} (c : BCase L A B Q frsB)
    (frsA : List Nat) (νA νB : Nat → F64) (DA HA NA DB HB NB : Nat) (GA GB : SegInst LF → Prop) : Prop where
  entry : ∀ x, x.ν = νA → CutBook Q A.s0 frsA DA HA NA x → GA x → c.Q x
  good : Good νA c.S0.oracle
  val : Shift.valuation c.θ νA = νB
  D : DA + (c.case.sF.next - B.s0.next) ≤ DB
  H : HA + (c.case.sF.ffi.mlx.next - B.s0.ffi.mlx.next) ≤ HB
  N : NA + (c.case.sF.ffi.mlx.nnext - B.s0.ffi.mlx.nnext) ≤ NB
  graph : c.Book (bookB Q A.s0 frsA νA DA HA NA GA) GB

/-- **A bookkept case's cut step.** -/
theorem book_step {L : SegLaws LF} {A B : Cut LF} {Q : PrefP} {frsA frsB : List Nat} (c : BCase L A B Q frsB)
    {νA νB : Nat → F64} {DA HA NA DB HB NB : Nat} {GA GB : SegInst LF → Prop}
    (h : c.Ok frsA νA νB DA HA NA DB HB NB GA GB) :
    CutStep (A.with (bookB Q A.s0 frsA νA DA HA NA GA)) (B.with (bookB Q B.s0 frsB νB DB HB NB GB)) c.n := by
  refine c.toXCase.step (fun x ⟨hv, hb, hg⟩ => ⟨hv ▸ h.good, h.entry x hv hb hg⟩) ?_
  intro x x1 x' hR hB h0 hst hend ht hC hR' hP
  obtain ⟨hv, hb, hg⟩ := hB
  obtain ⟨hp, hval⟩ := c.post x x1 x' h0 hP
  refine ⟨by rw [hval, hv, h.val], (hb.restart hp).mono h.D h.H h.N, ?_⟩
  exact h.graph x x1 x' hR ⟨hv, hb, hg⟩ h0 hst hend ht hC hR' hP

/-! ## The drains -/

/-- The counter bases and per-drain deltas of the drain cut. -/
structure PrefCtr where
  D0 : Nat
  H0 : Nat
  N0 : Nat
  ΔJ : Nat
  ΔH : Nat
  ΔN : Nat

/-- The valuation of the drain cut after `k` drains of chunk `C`: offset `k·C`, capacity
`capL (k·C)`, drain count `k`, from the template's valuation family `PV o cap k`. -/
def prefVal (PV : Nat → Nat → Nat → Nat → F64) (C k : Nat) : Nat → F64 := PV (k * C) (capL (k * C)) k

/-- The drain cut's invariant cut after `k` drains. -/
def prefCut (pc : Cut LF) (Q : PrefP) (frs : List Nat) (PV : Nat → Nat → Nat → Nat → F64) (C : Nat) (W : PrefCtr)
    (Gp : Nat → SegInst LF → Prop) (k : Nat) : ICut LF :=
  pc.with (bookB Q pc.s0 frs (prefVal PV C k) (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN) (Gp k))

/-- **The prefill invariant** at the drain cut after `k` drains of chunk `C` (design §3.4): the
target is related to the drain cut's template at offset `k·C`, capacity `capL (k·C)`, with the
framed prompt, empty unframed `forwarded`/`emitted`, the counters within `D0 + k·ΔJ` (and so on),
the fixed addresses, and the graph side `Gp k` (a parameter: the prompt-prefix chain, caches and
SSM state after positions `0 … kC - 1`). -/
def PrefillInv (pc : Cut LF) (Q : PrefP) (frs : List Nat) (PV : Nat → Nat → Nat → Nat → F64) (C : Nat) (W : PrefCtr)
    (Gp : Nat → SegInst LF → Prop) (k : Nat) (t : St LF.S) (Cs : CSrv) : Prop :=
  (prefCut pc Q frs PV C W Gp k).Inv t Cs

/-- **A drain's obligations** for the DRAIN-later case `dc` at drain `k`: its `Ok` from the drain cut
after `k` drains to the drain cut after `k + 1` (the restart's substitution takes offset `kC` to
`(k+1)C` and the capacity to `capL ((k+1)C)`: `capL_drain`), with the template's counter deltas
within `ΔJ`, `ΔH`, `ΔN`; the graph obligation is `DrainGStep`: `Gp (k + 1)` of the restarted pair. -/
def DrainOk {L : SegLaws LF} {pc : Cut LF} {Q : PrefP} {frs : List Nat} (dc : BCase L pc pc Q frs)
    (PV : Nat → Nat → Nat → Nat → F64) (C : Nat) (W : PrefCtr) (Gp : Nat → SegInst LF → Prop) (k : Nat) : Prop :=
  dc.Ok frs (prefVal PV C k) (prefVal PV C (k + 1)) (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN)
    (W.D0 + (k + 1) * W.ΔJ) (W.H0 + (k + 1) * W.ΔH) (W.N0 + (k + 1) * W.ΔN) (Gp k) (Gp (k + 1))

/-- `DrainOk` from the template's deltas. -/
theorem DrainOk.of {L : SegLaws LF} {pc : Cut LF} {Q : PrefP} {frs : List Nat} {dc : BCase L pc pc Q frs}
    {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr} {Gp : Nat → SegInst LF → Prop} {k : Nat}
    (hentry : ∀ x, x.ν = prefVal PV C k → CutBook Q pc.s0 frs (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN) x →
      Gp k x → dc.Q x)
    (hgood : Good (prefVal PV C k) dc.S0.oracle)
    (hnext : Shift.valuation dc.θ (prefVal PV C k) = prefVal PV C (k + 1))
    (hdJ : dc.case.sF.next - pc.s0.next ≤ W.ΔJ) (hdH : dc.case.sF.ffi.mlx.next - pc.s0.ffi.mlx.next ≤ W.ΔH)
    (hdN : dc.case.sF.ffi.mlx.nnext - pc.s0.ffi.mlx.nnext ≤ W.ΔN)
    (hG : dc.Book (bookB Q pc.s0 frs (prefVal PV C k) (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN) (Gp k))
      (Gp (k + 1))) :
    DrainOk dc PV C W Gp k where
  entry := hentry
  good := hgood
  val := hnext
  D := by have e : (k + 1) * W.ΔJ = k * W.ΔJ + W.ΔJ := Nat.succ_mul k W.ΔJ; omega
  H := by have e : (k + 1) * W.ΔH = k * W.ΔH + W.ΔH := Nat.succ_mul k W.ΔH; omega
  N := by have e : (k + 1) * W.ΔN = k * W.ΔN + W.ΔN := Nat.succ_mul k W.ΔN; omega
  graph := hG

/-- **One drain** (DRAIN-later): the prefill invariant after `k` drains gives it after `k + 1`, after
the case's steps. -/
theorem prefill_step {L : SegLaws LF} {pc : Cut LF} {Q : PrefP} {frs : List Nat} (dc : BCase L pc pc Q frs)
    {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr} {Gp : Nat → SegInst LF → Prop} {k : Nat}
    (h : DrainOk dc PV C W Gp k) :
    CutStep (prefCut pc Q frs PV C W Gp k) (prefCut pc Q frs PV C W Gp (k + 1)) dc.n :=
  book_step dc h

/-- **All drains** (`loop_induct` over `j < m`): with a checked case for each drain (`sel j`: for
chunks 128 and 64 the growth class alternates) whose obligations hold, the prefill invariant after
`k` drains gives it after `k + m`. -/
theorem prefill_all {L : SegLaws LF} {pc : Cut LF} {Q : PrefP} {frs : List Nat} (sel : Nat → BCase L pc pc Q frs)
    {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr} {Gp : Nat → SegInst LF → Prop} (m k : Nat)
    (h : ∀ j, k ≤ j → j < k + m → DrainOk (sel j) PV C W Gp j) {t : St LF.S} {Cs : CSrv}
    (hinv : PrefillInv pc Q frs PV C W Gp k t Cs) :
    ∃ t' Cs', runC LF (iterSteps (fun j => (sel j).n) k m) t Cs = some (t', Cs') ∧
      PrefillInv pc Q frs PV C W Gp (k + m) t' Cs' :=
  CutStep.iter (prefCut pc Q frs PV C W Gp) (fun j => (sel j).n) (fun j => k ≤ j ∧ j < k + m)
    (fun j hj => prefill_step (sel j) (h j hj.1 hj.2)) m k (fun j hj => ⟨by omega, by omega⟩) t Cs hinv

/-! ## The tail, the final step and POST -/

/-- The pre-final cut's invariant cut (`o = L - 1`, capacity `capL (L - 1)`), at bounds `D H N`. -/
def preFinalCut (pf : Cut LF) (Q : PrefP) (frs : List Nat) (PVf : Nat → Nat → Nat → F64) (Lp : Nat)
    (D H N : Nat) (Gf : SegInst LF → Prop) : ICut LF :=
  pf.with (bookB Q pf.s0 frs (PVf (Lp - 1) (capL (Lp - 1))) D H N Gf)

/-- **The pre-final invariant**: the pre-final cut's template related at offset `L - 1`, capacity
`capL (L - 1)`, length `L`, with the cut bookkeeping and the graph side `Gf` (the caches and SSM state
after positions `0 … L - 2`). -/
def PreFinalInv (pf : Cut LF) (Q : PrefP) (frs : List Nat) (PVf : Nat → Nat → Nat → F64) (Lp : Nat)
    (D H N : Nat) (Gf : SegInst LF → Prop) (t : St LF.S) (Cs : CSrv) : Prop :=
  (preFinalCut pf Q frs PVf Lp D H N Gf).Inv t Cs

/-- **The tail** (TAIL-later): from the prefill invariant after `k` drains, the tail case reaches the
pre-final invariant (the cut's bounds grow by the tail's end counters over the pre-final template's). -/
theorem tail_step {L : SegLaws LF} {pc pf : Cut LF} {Q : PrefP} {frs frsF : List Nat} (tc : BCase L pc pf Q frsF)
    {PV : Nat → Nat → Nat → Nat → F64} {C : Nat} {W : PrefCtr} {Gp : Nat → SegInst LF → Prop} {k : Nat}
    {PVf : Nat → Nat → Nat → F64} {Lp D H N : Nat} {Gf : SegInst LF → Prop}
    (h : tc.Ok frs (prefVal PV C k) (PVf (Lp - 1) (capL (Lp - 1)))
      (W.D0 + k * W.ΔJ) (W.H0 + k * W.ΔH) (W.N0 + k * W.ΔN) D H N (Gp k) Gf) :
    CutStep (prefCut pc Q frs PV C W Gp k) (preFinalCut pf Q frsF PVf Lp D H N Gf) tc.n :=
  book_step tc h

/-- **The final step** (FINAL(D1)): from the pre-final invariant, the final case reaches the
prefill loop's exit cut `ps` with its bookkeeping (valuation `νS`, bounds `D' H' N'`, graph side
`GS`: the final hidden row of the prompt). -/
theorem final_d1_step {L : SegLaws LF} {pf ps : Cut LF} {Q : PrefP} {frs frsS : List Nat} (fc : BCase L pf ps Q frsS)
    {PVf : Nat → Nat → Nat → F64} {Lp D H N : Nat} {Gf : SegInst LF → Prop}
    {νS : Nat → F64} {D' H' N' : Nat} {GS : SegInst LF → Prop}
    (h : fc.Ok frs (PVf (Lp - 1) (capL (Lp - 1))) νS D H N D' H' N' Gf GS) :
    CutStep (preFinalCut pf Q frs PVf Lp D H N Gf) (ps.with (bookB Q ps.s0 frsS νS D' H' N' GS)) fc.n :=
  book_step fc h

/-! ### The decode cut -/

/-- **The decode cut** `i = 1` as an invariant cut: the decode template related at the loop valuation
of iteration 1 after `L` tokens, with `LoopInvL`'s bookkeeping at iteration 1. -/
def loopCut (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE)
    (fixA : List Nat) (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (E0 : List Val) :
    ICut LF where
  s0 := s0
  tab0 := tab0
  R := fun x s S => Rel LF (LR P (toks.drop 1)) x.M x.ν x.K s S x.t x.C
  B := fun x => ∃ nx p1, x.ν = valL ρ T tk L 1 nx ∧ x.K.fr = frOf s0 p1 E0 ∧ x.K.lo = P.lo ∧ x.K.hi = P.E ∧
    x.K.base = s0.trace ∧ toks[0]? = some (x.M.num 79) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), x.C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    x.K.D = 0 ∧ x.t.ffi.mlx.next ≤ s0.ffi.mlx.next ∧ x.t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext ∧
    (∀ a ∈ fixA, x.M.a a = a) ∧ Gx 1 x.M x.t x.C

/-- **The decode cut's invariant is `LoopInvL … 1`.** -/
theorem loopCut_inv {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE}
    {fixA : List Nat} {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val}
    (ΔJ ΔH ΔN : Nat) (t : St LF.S) (C : CSrv) :
    (loopCut Gx P s0 tab0 fixA L ρ T tk toks E0).Inv t C ↔ LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t C := by
  constructor
  · rintro ⟨⟨M, ν, K, t', C'⟩, ht, hC, hR, nx, p1, hν, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hH, hN, hfix, hG⟩
    change t' = t at ht
    change C' = C at hC
    change ν = valL ρ T tk L 1 nx at hν
    subst ht hC hν
    change K.fr = frOf s0 p1 E0 at hfr
    change K.D = 0 at hD
    change t'.ffi.mlx.next ≤ s0.ffi.mlx.next at hH
    change t'.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext at hN
    refine ⟨M, K, nx, p1, hR, ?_, hlo, hhi, hbase, h79, hnx, hvals, ?_, ?_, ?_, hfix, hG⟩
    · rw [hfr]; simp
    · show K.D ≤ (1 - 1) * ΔJ
      rw [hD]; exact Nat.zero_le _
    · show t'.ffi.mlx.next ≤ s0.ffi.mlx.next + (1 - 1) * ΔH
      simp only [Nat.sub_self, Nat.zero_mul, Nat.add_zero]; exact hH
    · show t'.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (1 - 1) * ΔN
      simp only [Nat.sub_self, Nat.zero_mul, Nat.add_zero]; exact hN
  · rintro ⟨M, K, nx, p1, hR, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hH, hN, hfix, hG⟩
    refine ⟨⟨M, valL ρ T tk L 1 nx, K, t, C⟩, rfl, rfl, hR, nx, p1, rfl, ?_, hlo, hhi, hbase, h79, hnx, hvals,
      ?_, ?_, ?_, hfix, hG⟩
    · show K.fr = frOf s0 p1 E0
      rw [hfr]; simp
    · show K.D = 0
      have : K.D ≤ (1 - 1) * ΔJ := hD
      simp only [Nat.sub_self, Nat.zero_mul] at this; omega
    · show t.ffi.mlx.next ≤ s0.ffi.mlx.next
      have : t.ffi.mlx.next ≤ s0.ffi.mlx.next + (1 - 1) * ΔH := hH
      simpa using this
    · show t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext
      have : t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (1 - 1) * ΔN := hN
      simpa using this

/-- **POST**: from the prefill loop's exit cut, the POST case (token-0 logits and sample, decode
iterations 0 and 1) restarts into the decode template, where the restart's facts give `LoopInvL`'s
bookkeeping at iteration 1 (`hbook`). -/
theorem post_stepL {L : SegLaws LF} {ps : Cut LF} {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {Lp : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat}
    {toks : List NumV} {E0 : List Val}
    (pc : XCase L ps (loopCut Gx P s0 tab0 fixA Lp ρ T tk toks E0).toCut) {BS : SegInst LF → Prop}
    (hQ : ∀ x, BS x → Good x.ν pc.S0.oracle ∧ pc.Q x)
    (hbook : pc.Book BS (loopCut Gx P s0 tab0 fixA Lp ρ T tk toks E0).B) :
    CutStep (ps.with BS) (loopCut Gx P s0 tab0 fixA Lp ρ T tk toks E0) pc.n :=
  pc.step hQ hbook

/-! ## The whole prefill -/

/-- The invariants of the prefill chain of a prompt of length `L` at its cuts. -/
structure PrefInvs where
  /-- The loadDone cut. -/
  ld : Nat → ICut LF
  /-- The first `nextPrefillStep` call (`o = 0`). -/
  pc0 : Nat → ICut LF
  /-- The `nextPrefillStep` call after `k ≥ 1` drains (`PrefillInv`). -/
  pc : Nat → Nat → ICut LF
  /-- The pre-final call after a tail (`PreFinalInv`). -/
  pf : Nat → ICut LF
  /-- The prefill loop's exit. -/
  ps : Nat → ICut LF
  /-- The decode cut `i = 1` (`loopCut`). -/
  dec : Nat → ICut LF

/-- Where FINAL starts: the first call (`L = 1`), the drain cut (no tail), the call after a tail. -/
inductive PFSrc where
  | first
  | drained
  | tailed
  deriving DecidableEq

def pfSrcOf (L : Nat) : PFSrc := if L = 1 then .first else if tailRows L = 0 then .drained else .tailed

/-- The pre-final cut of each source. -/
def PrefInvs.pre (I : PrefInvs) (L : Nat) : PFSrc → ICut LF
  | .first => I.pc0 L
  | .drained => I.pc L (drains L)
  | .tailed => I.pf L

/-- **The checked steps of the prefill chain**: for each class of each position, the step count of
its template case and the cut step wherever the class applies (each from `book_step`,
`prefill_step`, `tail_step`, `final_d1_step`, `post_stepL` with the class's template case and facts). -/
structure PrefSteps (I : PrefInvs) where
  nSetup : SetupClass → Nat
  setup : ∀ c L, c.Applies L → CutStep (I.ld L) (I.pc0 L) (nSetup c)
  nFirst : FirstClass → Nat
  firstDrain : ∀ C L, (FirstClass.drain C).Applies L → CutStep (I.pc0 L) (I.pc L 1) (nFirst (.drain C))
  firstTail : ∀ X L, (FirstClass.tail X).Applies L → CutStep (I.pc0 L) (I.pf L) (nFirst (.tail X))
  nDrain : DrainClass → Nat
  drain : ∀ d L j, d.Applies L j → CutStep (I.pc L j) (I.pc L (j + 1)) (nDrain d)
  nTail : TailClass → Nat
  tail : ∀ c L, c.Applies L → CutStep (I.pc L (drains L)) (I.pf L) (nTail c)
  nFinal : PFSrc → FinalClass → Nat
  final : ∀ c L, c.Applies L → CutStep (I.pre L (pfSrcOf L)) (I.ps L) (nFinal (pfSrcOf L) c)
  nPost : PostClass → Nat
  post : ∀ c L, c.Applies L → CutStep (I.ps L) (I.dec L) (nPost c)

/-- The steps of the prefill route of `L` (`L`'s chain of classes). -/
def PrefSteps.n {I : PrefInvs} (S : PrefSteps I) (L : Nat) : Nat :=
  S.nSetup (setupOf L) +
    (if 1 ≤ drains L then
      S.nFirst (.drain (chunkC L)) + iterSteps (fun j => S.nDrain (drainOf L j)) 1 (drains L - 1) +
        (if 1 ≤ tailRows L then S.nTail (tailOf L) else 0)
    else if 2 ≤ L then S.nFirst (.tail (rowClass (L - 1))) else 0) +
    S.nFinal (pfSrcOf L) (finalOf L) + S.nPost (postOf L)

/-- The prefill up to the pre-final cut, from the first call. -/
theorem prefill_mid {I : PrefInvs} (S : PrefSteps I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.pc0 L) (I.pre L (pfSrcOf L))
      (if 1 ≤ drains L then
        S.nFirst (.drain (chunkC L)) + iterSteps (fun j => S.nDrain (drainOf L j)) 1 (drains L - 1) +
          (if 1 ≤ tailRows L then S.nTail (tailOf L) else 0)
      else if 2 ≤ L then S.nFirst (.tail (rowClass (L - 1))) else 0) := by
  have hcov := chain_cover L h1 h2
  have e := drains_tail L
  by_cases hd : 1 ≤ drains L
  · rw [ite_eq_left hd]
    have hC := chunkC_mem (L := L) (by omega)
    have hC64 : 64 ≤ chunkC L := by rcases chunkSizes_cases hC with h | h | h | h | h | h <;> omega
    have hL1 : L ≠ 1 := by
      intro hL; subst hL; simp [drains] at hd
    -- the first drain and the later drains
    have hfirst := S.firstDrain (chunkC L) L ⟨rfl, hd⟩
    have hdr : CutStep (I.pc L 1) (I.pc L (drains L))
        (iterSteps (fun j => S.nDrain (drainOf L j)) 1 (drains L - 1)) := by
      have := CutStep.iter (I.pc L) (fun j => S.nDrain (drainOf L j)) (fun j => 1 ≤ j ∧ j + 1 ≤ drains L)
        (fun j hj => S.drain (drainOf L j) L j (hcov.2.2.1 j hj.1 hj.2).2.1) (drains L - 1) 1
        (fun j hj => ⟨by omega, by omega⟩)
      exact this.cast rfl (by rw [show 1 + (drains L - 1) = drains L by omega]) rfl
    by_cases ht : 1 ≤ tailRows L
    · rw [ite_eq_left ht]
      have hsrc : pfSrcOf L = .tailed := by unfold pfSrcOf; rw [ite_eq_right hL1, ite_eq_right (by omega)]
      rw [hsrc]
      have htl := S.tail (tailOf L) L (tail_cover (by omega) hd ht).2.1
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
      exact S.firstTail (rowClass (L - 1)) L ⟨h0, hL2, hm⟩
    · rw [ite_eq_right hL2]
      have hsrc : pfSrcOf L = .first := by unfold pfSrcOf; rw [ite_eq_left (by omega)]
      rw [hsrc]
      exact CutStep.refl _

/-- **The prefill reaches the decode cut**: for every `L ∈ [1, 262143]` (every prompt with
`L + T ≤ 262144`), the steps of `L`'s chain of classes take the loadDone invariant to the decode
cut's invariant. -/
theorem prefill_reach {I : PrefInvs} (S : PrefSteps I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.ld L) (I.dec L) (S.n L) := by
  have hcov := chain_cover L h1 h2
  have hs := S.setup (setupOf L) L hcov.1.2.1
  have hf := S.final (finalOf L) L hcov.2.2.2.2.2.1.2.1
  have hp := S.post (postOf L) L hcov.2.2.2.2.2.2.2.1
  exact ((hs.trans (prefill_mid S h1 h2)).trans hf).trans hp

/-! ## The route -/

/-- A decode route from the decode cut: every run from `(t0, C0)` reaching a target where the decode
cut's invariant holds continues to `Goal` (`loop_sourceL`, `loop_source_eosL` are instances at
`loopCut`). -/
def DecodeRoute (Idec : ICut LF) (t0 : St LF.S) (C0 : CSrv) (Goal : Prop) : Prop :=
  ∀ N t1 C1, runC LF N t0 C0 = some (t1, C1) → Idec.Inv t1 C1 → Goal

/-- **The route from the boot run**, for any decode route: the boot run to loadDone, the prefill's
chain of checked steps, the decode route. -/
theorem source_prompt {I : PrefInvs} (S : PrefSteps I) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 262143)
    {N0 : Nat} {t0 tL : St LF.S} {C0 CL : CSrv} (hboot : runC LF N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL) {Goal : Prop} (hD : DecodeRoute (I.dec L) t0 C0 Goal) : Goal := by
  obtain ⟨t1, C1, hr, h1⟩ := prefill_reach S hL1 hL2 tL CL hld
  exact hD _ t1 C1 (runC_trans hboot hr) h1

/-- **The source tokens of a prompt of length `L`**: the boot run to loadDone where the loadDone
invariant holds, the prefill's chain of checked steps (`prefill_reach`) to the decode cut, and the
decode loop (`loop_sourceL`) halt with the `emitted` binding the cut's prefix followed by the first
`T - 1` readbacks. Every template-dependent fact is a hypothesis: the steps `S` (one template case
per class, `PrefSteps`), the decode cut's invariant being `LoopInvL … 1` (`hdec`), and the decode
loop's cases and obligations (as in `loop_sourceL`). -/
theorem source_tokens_promptL {I : PrefInvs} (S : PrefSteps I) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 262143)
    {N0 : Nat} {t0 tL : St LF.S} {C0 CL : CSrv} (hboot : runC LF N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL)
    {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} {cE : Nat}
    (Sacc : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (cs : LoopCases ok P s0 tab0 fixA) {ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    (F0 : FinalSim P VBOk ok s0 tab0 cE (finalDG false false))
    (F1 : FinalSim P VBOk ok s0 tab0 cE (finalDG true false))
    (F2 : FinalSim P VBOk ok s0 tab0 cE (finalDG false true))
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {env : Env} {nm : Name}
    (henv : lookupEnv nm env = some cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepL Gx (loopSelL cs L i) L ρ T tk toks i)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → FinalGStepL Gx P fixA F0.fc L ρ T tk toks G)
    (hF0 : (T - 2) % 256 = 0 → FinalGStepL Gx P fixA F1.fc L ρ T tk toks G)
    (hF1 : (T - 1) % 256 = 0 → FinalGStepL Gx P fixA F2.fc L ρ T tk toks G)
    (hdec : I.dec L = loopCut Gx P s0 tab0 fixA L ρ T tk toks E0) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
      CSrv.Le CL CF ∧ G tF CF := by
  obtain ⟨t1, C1, hr, h1⟩ := prefill_reach S hL1 hL2 tL CL hld
  rw [hdec] at h1
  have hinv := (loopCut_inv ΔJ ΔH ΔN t1 C1).1 h1
  obtain ⟨N, tF, CF, hrun, hv, hem, hLe, hGoal⟩ := loop_sourceL Sacc st hfr17 hcE hb cs hcs F0 F1 F2 henv hT hLT
    hlen htk notEos hVB hJ hH hN hG hF hF0 hF1 (runC_trans hboot hr) hinv
  exact ⟨N, tF, CF, hrun, hv, hem, (runC_le _ _ _ _ _ hr).trans hLe, hGoal⟩

/-- **The EOS stop of a prompt of length `L`**: token `k` (`2 ≤ k ≤ T`) is EOS and tokens `2 … k-1`
are not; the boot run, the prefill and the decode loop's EOS cases (`loop_source_eosL`) halt with the
`emitted` binding the cut's prefix followed by the first `k - 2` readbacks. -/
theorem source_tokens_prompt_eosL {I : PrefInvs} (S : PrefSteps I) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 262143)
    {N0 : Nat} {t0 tL : St LF.S} {C0 CL : CSrv} (hboot : runC LF N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL)
    {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} {cE : Nat}
    (Sacc : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (cs : LoopCases ok P s0 tab0 fixA) {ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    (X : ExitSim P VBOk ok s0 tab0 cE)
    (FE0 : FinalESim P VBOk ok s0 tab0 cE (finalEDG false))
    (FE1 : FinalESim P VBOk ok s0 tab0 cE (finalEDG true))
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {env : Env} {nm : Name}
    (henv : lookupEnv nm env = some cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T) (notEos : ∀ j, 2 ≤ j → j < k → tk j ≠ 248044) (eos : tk k = 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T → LoopGStepL Gx (loopSelL cs L i) L ρ T tk toks i)
    (hX : k < T → ExitGStepL Gx P fixA X.ec L ρ T tk toks (k - 1) G)
    (hF : k = T → (T - 2) % 256 ≠ 0 → FinalEGStepL Gx P fixA FE0.ec L ρ T tk toks G)
    (hF0 : k = T → (T - 2) % 256 = 0 → FinalEGStepL Gx P fixA FE1.ec L ρ T tk toks G)
    (Q : St LF.S → Prop) (hQX : Q X.ec.sF) (hQ0 : Q FE0.ec.sF) (hQ1 : Q FE1.ec.sF)
    (hdec : I.dec L = loopCut Gx P s0 tab0 fixA L ρ T tk toks E0) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (k - 2)).map Val.num) ∧
      CSrv.Le CL CF ∧ G tF CF ∧
      ∃ i MF ν KF s Sx, Q s ∧ Rel LF (LR P (toks.drop i)) MF ν KF s Sx tF CF ∧ ∀ a ∈ fixA, MF.a a = a := by
  obtain ⟨t1, C1, hr, h1⟩ := prefill_reach S hL1 hL2 tL CL hld
  rw [hdec] at h1
  have hinv := (loopCut_inv ΔJ ΔH ΔN t1 C1).1 h1
  obtain ⟨N, tF, CF, hrun, hv, hem, hLe, hGoal, rest⟩ := loop_source_eosL Sacc st hfr17 hcE hb cs hcs X FE0 FE1 henv
    hT hLT hlen htk k hk2 hkT notEos eos hVB hJ hH hN hG hX hF hF0 Q hQX hQ0 hQ1 (runC_trans hboot hr) hinv
  exact ⟨N, tF, CF, hrun, hv, hem, (runC_le _ _ _ _ _ hr).trans hLe, hGoal, rest⟩

end Host.Ts.Sim.Prefill
