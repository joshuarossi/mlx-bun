import host.simgraph.world.Lift
import host.sim.world.IterCut
import host.simgraph.mach.Step
import host.simgraph.world.Caches
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt cacheAt CachesBelow cachesAt_comp cachesAt_below
  mem_of_length_le_one mem_of_length_le_two)
open Host.Mlx.SimGraph.Mach (MRef ForwardAtM)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The decode loop's graph side at the machine reference, over a world

The prefill's MMA kernels and the Neural Engine are uninterpreted, so for an arbitrary prompt the
reference of the decode loop is the machine's (`MRef`, `host.simgraph.mach.Step`): at every table and
time a token and the cache handles, each next one the D1 forward's trace step (`MRefDecodes`). The
invariant and the obligations of `host.simgraph.iter.InvL`/`InvA` restated against it, over a world
`Wd` through its graph projection (`GraphProj`):

* `GIM`, `GxM`: `GIL`, `GxL` with `ForwardAtM` for `ForwardAtR`; the current state's handles are the
  reference's own (`R tab (L + i + 1) = some (tok, hs)`) with their capacity (`CapsFor`), no model
  cache (`ChainHolds`). `GIM.congr`: it reads the map only at the template's carriers.
* `gi_nextM`: one iteration of the invariant.
* `CaseFwdM`: a loop case's forward at iteration `i` (`CaseFwdA` at the machine reference): from the
  reference's handles at `L + i + 1` and the next state at `L + i + 2`, the output node holds the
  next token and the next cache tensors the next handles. `template_cached_forwardM` discharges it
  (the step from `MRefDecodes`, the kinds and shapes from `compat_of_caps`, `shapesOk_of_caps`).
* `gstep_coreM`; `gstep_ofM` (`LoopGStepM`, a case of one run or of pieces), `gstep_ofCM`
  (`LoopGStepCW`, a cut-step chain), `gstep_ofGM` (`LoopGStepGW`, through compactions: the map
  agrees with the start's at the template's carriers, `IterGhostCW.node`).
* `GFM`: the halted target's conclusions (every forward result of times `L … L + T - 1` at the
  reference, the memoized readbacks' values); `fgstep_coreM`, `lgstep_ofM` (`LastGStepM`),
  `egstep_coreM`, `cgstep_ofM` (`CutGStepM`).
* `FinalCacheW`: a halting chain's program caches (the `cache` binding of the target's load-world part
  at the images of the template's carriers), from its end state's kernel-checked facts
  (`FinalCacheTpl.cache`, `RelB.cachesTW_end`); `lgstepC_ofM` (`fgstepC_ofL`): a final chain's goal
  with the program's caches holding the reference's handles (`forwardAtM_congrC`).

The tokens: `htk`, the reference is defined at `L + j` with the route's token `j + 1` (the native
readbacks), below `2 ^ 31`. -/

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey)

/-! ## The invariant -/

/-- **The invariant at iteration `i` after a prompt of length `L` at the machine reference `R`**
(absolute time `L + i + 1`), at table `tab`, for the target's native state `x` under the node map
`σ` (`GIL`). -/
structure GIM (I : TplInputs) (R : MRef) (L : Nat) (tab : List F64) (i : Nat) (σ : Nat → Nat)
    (x : Host.Mlx.Ffi.St) : Prop where
  hist : ∀ k, L ≤ k → k ≤ L + i + 1 → ∃ cs out,
    ForwardAtM M K env R tab k cs out (Gr tab x) ∧ out < x.nnext ∧ CachesBelow cs x.nnext
  read : ∃ cs, ForwardAtM M K env R tab (L + i) cs (σ I.read) (Gr tab x) ∧ σ I.read < x.nnext ∧
    CachesBelow cs x.nnext
  cur : ∃ tok hs, R tab (L + i + 1) = some (tok, hs) ∧
    (∃ r, evalR M K env (Gr tab x) (σ I.fed) = some r ∧ itemUint32 r = some tok) ∧
    CacheValues M K env (Gr tab x) (cachesAt σ I.caches) hs ∧
    CapsFor (Sim.capL (L + i + 1)) (stageWeights (weights (firstValues M K env tab))) hs ∧
    σ I.fed < x.nnext ∧ CachesBelow (cachesAt σ I.caches) x.nnext
  params : ∀ t ∈ parameterTensors parameterChoice,
    evalR M K env (Gr tab x) t.node = some (firstValues M K env tab t) ∧ t.node < x.nnext
  reads : ReadbackValues M K env (CSrv.val ⟨tab⟩) (Gr tab x) x.items ∧ ∀ k, x.nnext ≤ k → x.items.get k = none

/-- **The loop's graph invariant after a prompt of length `L` at the machine reference** (`GxL`),
an invariant of the mlx state (`liftG Wd (GxM …)` over a world). -/
def GxM (I : TplInputs) (R : MRef) (L : Nat) : MlxInv :=
  fun i Mp x Cs => ∀ tab, Sim.CSrv.Le Cs ⟨tab⟩ → GIM M K env I R L tab i Mp.node x

theorem cachesAt_congrM {σ σ' : Nat → Nat} {ps : List (Option Nat × Option Nat)}
    (h : ∀ p ∈ ps, ∀ j, (p.1 = some j ∨ p.2 = some j) → σ' j = σ j) : cachesAt σ' ps = cachesAt σ ps := by
  unfold cachesAt
  refine List.map_congr_left fun p hp => ?_
  obtain ⟨a, b⟩ := p
  have ha : a.map (fun j => Iter.tensorAt (σ' j)) = a.map (fun j => Iter.tensorAt (σ j)) := by
    cases a with
    | none => rfl
    | some j => simp only [Option.map_some]; rw [h _ hp j (.inl rfl)]
  have hb : b.map (fun j => Iter.tensorAt (σ' j)) = b.map (fun j => Iter.tensorAt (σ j)) := by
    cases b with
    | none => rfl
    | some j => simp only [Option.map_some]; rw [h _ hp j (.inr rfl)]
  simp only [cacheAt, ha, hb]

/-- `GIM` reads the node map only at the template's carriers. -/
theorem GIM.congr {I : TplInputs} {R : MRef} {L : Nat} {tab : List F64} {i : Nat} {σ σ' : Nat → Nat}
    {x : Host.Mlx.Ffi.St} (h : GIM M K env I R L tab i σ x) (hr : σ' I.read = σ I.read) (hf : σ' I.fed = σ I.fed)
    (hc : cachesAt σ' I.caches = cachesAt σ I.caches) : GIM M K env I R L tab i σ' x where
  hist := h.hist
  read := by rw [hr]; exact h.read
  cur := by rw [hf, hc]; exact h.cur
  params := h.params
  reads := h.reads

theorem forwardAtM_time {R : MRef} {tab : List F64} {a b : Nat} (e : a = b) {cs : List Cache} {out : Nat}
    {G : Nat → Option (RNode Int InKey)} (h : ForwardAtM M K env R tab a cs out G) :
    ForwardAtM M K env R tab b cs out G := by
  subst e; exact h

/-- `ForwardAtM` reads its caches only through their tensor nodes. -/
theorem forwardAtM_congrC {R : MRef} {tab : List F64} {time : Nat} {cs cs' : List Cache} {out : Nat}
    {G : Nat → Option (RNode Int InKey)} (h : ForwardAtM M K env R tab time cs out G)
    (hc : cs.map cacheNodePair = cs'.map cacheNodePair) : ForwardAtM M K env R tab time cs' out G := by
  obtain ⟨tok, hs, hR, htok, hv⟩ := h
  refine ⟨tok, hs, hR, htok, ?_⟩
  clear hR htok
  unfold CacheValues at hv ⊢
  induction hv generalizing cs' with
  | nil =>
    cases cs' with
    | nil => exact .nil
    | cons _ _ => cases hc
  | @cons c h cs hs hx _ ih =>
    cases cs' with
    | nil => cases hc
    | cons c' cs' =>
      simp only [List.map_cons, List.cons.injEq] at hc
      obtain ⟨hc1, hc2⟩ := hc
      obtain ⟨ta, tb, a, b, h1, h2, h3, h4, h5⟩ := hx
      simp only [cacheNodePair, Prod.mk.injEq, h1, h2, Option.map_some] at hc1
      obtain ⟨ha, hb'⟩ := hc1
      obtain ⟨ta', h1', hta⟩ := Option.map_eq_some_iff.mp ha.symm
      obtain ⟨tb', h2', htb⟩ := Option.map_eq_some_iff.mp hb'.symm
      exact .cons ⟨ta', tb', a, b, h1', h2', h3, hta ▸ h4, htb ▸ h5⟩ (ih hc2)

/-- **One iteration of the invariant** at the machine reference (`gi_nextL`). -/
theorem gi_nextM (I : TplInputs) (R : MRef) (L : Nat) (tab : List F64) (i : Nat)
    (σ σT : Nat → Nat) (x x1 : Host.Mlx.Ffi.St) (outT : Nat) (outs : List (Option Nat × Option Nat))
    (hG : GIM M K env I R L tab i σ x)
    (hgrow : Grows SourceKernels.sources x x1) (hn : x.nnext ≤ x1.nnext)
    (hnew : ∀ k v, x1.items.get k = some v → x.items.get k = some v ∨ (x.items.get k = none ∧ k = σ I.read ∧
      ∃ tok, (∃ hs, R tab (L + i) = some (tok, hs)) ∧ tok < 2 ^ 31 ∧ CSrv.val ⟨tab⟩ v = some (F64.ofNat tok)))
    (hyitems : ∀ k, x1.nnext ≤ k → x1.items.get k = none)
    (hfwd : ∃ tok next, R tab (L + i + 2) = some (tok, next) ∧
      (∃ r, evalR M K env (Gr tab x1) (σ outT) = some r ∧ itemUint32 r = some tok) ∧
      CacheValues M K env (Gr tab x1) (cachesAt σ outs) next ∧
      CapsFor (Sim.capL (L + i + 2)) (stageWeights (weights (firstValues M K env tab))) next)
    (hout : σ outT < x1.nnext) (houts : CachesBelow (cachesAt σ outs) x1.nnext)
    (hread : σT I.read = I.fed) (hfed : σT I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map σT, p.2.map σT)) = outs) :
    GIM M K env I R L tab (i + 1) (fun j => σ (σT j)) x1 where
  hist := by
    intro k h1 h2
    by_cases hk2 : k ≤ L + i + 1
    · obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 hk2
      refine ⟨cs, out, Mach.ForwardAtM.grow M K env _ _ _ _ hf hgrow ho hc, by omega, ?_⟩
      intro c hc' t ht; have := hc c hc' t ht; omega
    · have hk3 : k = L + i + 2 := by omega
      subst hk3
      obtain ⟨tok, next, hR, htok, hc, _⟩ := hfwd
      exact ⟨cachesAt σ outs, σ outT, ⟨tok, next, hR, htok, hc⟩, hout, houts⟩
  read := by
    obtain ⟨tok, hs, hR, htok, hc, _, hf, hcb⟩ := hG.cur
    refine ⟨cachesAt σ I.caches, ?_, ?_, ?_⟩
    · simp only [hread]
      exact Mach.ForwardAtM.grow M K env _ _ _ _ ⟨tok, hs, hR, htok, hc⟩ hgrow hf hcb
    · simp only [hread]; omega
    · intro c hc' t ht; have := hcb c hc' t ht; omega
  cur := by
    obtain ⟨tok, next, hR, htok, hc, hcaps⟩ := hfwd
    have he : cachesAt (fun j => σ (σT j)) I.caches = cachesAt σ outs := by
      rw [← hcaches, cachesAt_comp]
    refine ⟨tok, next, hR, ?_, by rw [he]; exact hc, hcaps, by simp only [hfed]; exact hout, by rw [he]; exact houts⟩
    simp only [hfed]
    exact htok
  params := by
    intro t ht
    obtain ⟨hv, hlt⟩ := hG.params t ht
    exact ⟨evalR_grows M K env _ _ _ _ hgrow _ hlt _ hv, by omega⟩
  reads := by
    refine ⟨?_, hyitems⟩
    intro k v hk
    rcases hnew k v hk with hx | ⟨_, rfl, tok, ⟨hs0, hR0⟩, hb, hν⟩
    · obtain ⟨token, htk, ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < x.nnext := by
        by_contra hc
        rw [hG.reads.2 k (by omega)] at hx
        cases hx
      exact ⟨token, htk, ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
    · obtain ⟨cs, ⟨tok', hs', hR', ⟨r, hr, hi⟩, _⟩, hlt, _⟩ := hG.read
      obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR'.symm.trans hR0))
      exact ⟨tok', hb, ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩

/-! ## A loop case's graph step -/

section Steps
variable {Wd : Sim.World} (pr : GraphProj Wd) {A : Sim.Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE}

/-- **A loop case's forward at iteration `i` at the machine reference** over `Wd` (`CaseFwdA`): at
the case's end `s1` under the general relation (the graph constants `A`), the template's time
variable at `L + i + 1`, the reference's token and handles at `L + i + 1` held by the current
carriers (with their capacity), its next state at `L + i + 2`, and the loaded parameters: the
output node holds the next token and the next cache tensors the next handles, at the next
capacity. -/
def CaseFwdM (A : Sim.Addr) (I : TplInputs) (R : MRef) (L : Nat) (s1 : Wd.F.S) (S1tab : List SymE) (outT : Nat)
    (outs : List (Option Nat × Option Nat)) (i : Nat) : Prop :=
  ∀ (tab : List F64) (P' : Sim.LoadP) (NB : Nat) (Mp : Sim.Map) (n : Nat) (y : Wd.F.S) (ν : Nat → F64),
    Sim.G.LoadR P' NB Mp n (pr.toLoad s1) (pr.toLoad y) → P'.NL = A.NL → P'.N0 = A.N0 →
    ν A.tvar = F64.ofNat (L + i + 1) →
    (∀ j e, nth? S1tab j = some e → CSrv.val ⟨tab⟩ (Mp.nv (.ref j)) = some (e.eval ν)) →
    Mp.big (A.rope : Int) = (A.rope : Int) →
    ∀ tok hs tok' hs', R tab (L + i + 1) = some (tok, hs) → R tab (L + i + 2) = some (tok', hs') → tok < 2 ^ 31 →
      CapsFor (Sim.capL (L + i + 1)) (stageWeights (weights (firstValues M K env tab))) hs →
      CacheValues M K env (Gr tab (Wd.toMlx y)) (cachesAt Mp.node I.caches) hs →
      (∃ r, evalR M K env (Gr tab (Wd.toMlx y)) (Mp.node I.fed) = some r ∧ itemUint32 r = some tok) →
      (∀ t ∈ parameterTensors parameterChoice,
        evalR M K env (Gr tab (Wd.toMlx y)) t.node = some (firstValues M K env tab t)) →
      (∃ r, evalR M K env (Gr tab (Wd.toMlx y)) (Mp.node outT) = some r ∧ itemUint32 r = some tok') ∧
        CacheValues M K env (Gr tab (Wd.toMlx y)) (cachesAt Mp.node outs) hs' ∧
        CapsFor (Sim.capL (L + i + 2)) (stageWeights (weights (firstValues M K env tab))) hs'

/-- **The core of a loop case's graph step at the machine reference** (`gstep_ofA`'s proof over a
world): from the invariant at the start, the general relations at the start and at the end
(`s1`, `S1`, the end's map `M1` agreeing with the start's at the template's carriers), the mlx
growth, the server's growth, the band, and the case's forward, the invariant at the next iteration
under any restart map of the end along `σc`. -/
theorem gstep_coreM (hPNL : ∀ r, (pr.lp P r).NL = A.NL) (hPN0 : ∀ r, (pr.lp P r).N0 = A.N0)
    (hPE : Wd.E P ≤ A.rope) (hrope : A.rope < 2 ^ 56)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (toks : List NumV) (i : Nat) (I : TplInputs)
    (outT : Nat) (outs : List (Option Nat × Option Nat)) (s1 : St Wd.F.S) (S1 : SSrv) (σc : Sim.Map)
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (fwd : CaseFwdM M K env pr A I R L s1.ffi S1.tab outT outs i)
    (hread : σc.node I.read = I.fed) (hfed : σc.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map σc.node, p.2.map σc.node)) = outs)
    (hsread : (Wd.toMlx s0.ffi).items.get I.read = none)
    (hpread : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (h1read : (Wd.toMlx s1.ffi).items.get I.read = some (.ref A.tok))
    (h1pread : ((Wd.toMlx s1.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hs1tok : (Wd.toMlx s1.ffi).tokens = [])
    (htokv : nth? tab0 A.tok = some (.var A.kvar))
    (hpout : ((Wd.toMlx s1.ffi).nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → ((Wd.toMlx s1.ffi).nodes.get j).isSome = true)
    {nx : Nat} (hVk : V i nx A.kvar = F64.ofNat (tk (i + 1))) {ν1 : Nat → F64}
    (hVt1 : ν1 A.tvar = F64.ofNat (L + i + 1))
    {Mp M1 : Sim.Map} {Kc : Sim.Ctx} {t t1 : St Wd.F.S} {Cs C1 : CSrv}
    (hG : GxM M K env I R L i Mp (Wd.toMlx t.ffi) Cs)
    (hst : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) Mp tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi))
    (hnum0 : Sim.NumOK Mp (V i nx) ⟨tab0, []⟩ Cs) (hhi : Kc.hi = Wd.E P) (hle : Sim.CSrv.Le Cs C1)
    (fr : Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx t1.ffi))
    (hcar : M1.node I.read = Mp.node I.read ∧ M1.node I.fed = Mp.node I.fed ∧
      cachesAt M1.node I.caches = cachesAt Mp.node I.caches)
    (hend : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) M1 S1.tab.length (pr.toLoad s1.ffi) (pr.toLoad t1.ffi))
    (hnum1 : Sim.NumOK M1 ν1 S1 C1) (hbig : ∀ j, Sim.BigFixed Kc.lo Kc.hi j → M1.big j = j)
    (n : Nat) (v : NumV) (a b d : Nat) :
    GxM M K env I R L (i + 1) (((M1.setNum n v).after σc).rebig a b d) (Wd.toMlx t1.ffi) C1 := by
  intro tab hle1
  have hle0 : Sim.CSrv.Le Cs ⟨tab⟩ := hle.trans hle1
  obtain ⟨hcr, hcf, hcc⟩ := hcar
  have hG1 : GIM M K env I R L tab i M1.node (Wd.toMlx t.ffi) := (hG tab hle0).congr M K env hcr hcf hcc
  have hgrow := fr.grows SourceKernels.sources
  have mr0 : Sim.G.MR (pr.lp P (toks.drop i)) (pr.NB P) Mp tab0.length (Wd.toMlx s0.ffi) (Wd.toMlx t.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hst.mlx
  have mr1 : Sim.G.MR (pr.lp P (toks.drop i)) (pr.NB P) M1 S1.tab.length (Wd.toMlx s1.ffi) (Wd.toMlx t1.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hend.mlx
  obtain ⟨tok, hs, hR1, htok, hcv, hcaps, hfedlt, hcb⟩ := hG1.cur
  obtain ⟨hs1', hR1'⟩ := htk tab (i + 1) (by omega)
  have etok : tok = tk (i + 1 + 1) := (Prod.mk.inj (Option.some.inj (hR1.symm.trans hR1'))).1
  obtain ⟨hs2, hR2⟩ := htk tab (i + 2) (by omega)
  have hcv1 : CacheValues M K env (Gr tab (Wd.toMlx t1.ffi)) (cachesAt M1.node I.caches) hs :=
    cacheValues_grows M K env _ _ _ _ hgrow _ hs hcb hcv
  have hprev1 : ∃ r, evalR M K env (Gr tab (Wd.toMlx t1.ffi)) (M1.node I.fed) = some r ∧ itemUint32 r = some tok := by
    obtain ⟨r, hr, hi⟩ := htok
    exact ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hfedlt _ hr, hi⟩
  have hpar1 : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (Gr tab (Wd.toMlx t1.ffi)) t.node = some (firstValues M K env tab t) := fun t ht =>
    evalR_grows M K env _ _ _ _ hgrow _ (hG1.params t ht).2 _ (hG1.params t ht).1
  have hnum : ∀ j e, nth? S1.tab j = some e → CSrv.val ⟨tab⟩ (M1.nv (.ref j)) = some (e.eval ν1) :=
    fun j e he => hle1.val (hnum1 j e he)
  have hrope1 : M1.big (A.rope : Int) = (A.rope : Int) :=
    hbig _ (.inr (.inr ⟨by rw [hhi]; omega, by omega⟩))
  obtain ⟨hout, hcvn, hcapn⟩ := fwd tab _ _ M1 _ t1.ffi _ hend (hPNL _) (hPN0 _) hVt1 hnum hrope1 tok hs _ hs2 hR1
    hR2 (by rw [etok]; exact htkb (i + 1) (by omega)) hcaps hcv1 hprev1 hpar1
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped = [Mp.nv (.ref A.tok)] := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hs1tok] at hpe
    exact (List.append_left_inj _).mp hpe.symm
  subst hpop
  have hplen : ks.length ≤ 1 := hks
  have hslot1 : (Wd.toMlx t1.ffi).items.get (M1.node I.read) = some (M1.nv (.ref A.tok)) := by
    rw [mr1.items I.read h1pread, h1read]; rfl
  have hslot0 : (Wd.toMlx t.ffi).items.get (M1.node I.read) = none := by
    rw [hcr, mr0.items I.read hpread, hsread]; rfl
  have hks1 : M1.node I.read ∈ ks := by
    rcases hnewk _ _ hslot1 with h | ⟨_, h, _⟩
    · rw [hslot0] at h; cases h
    · exact h
  have hval : CSrv.val ⟨tab⟩ (Mp.nv (.ref A.tok)) = some (F64.ofNat (tk (i + 1))) := by
    show CSrv.val ⟨tab⟩ (Mp.num A.tok) = _
    rw [hle0.val (hnum0 A.tok _ htokv)]
    show some (V i nx A.kvar) = _
    rw [hVk]
  obtain ⟨hs0', hR0⟩ := htk tab i (by omega)
  exact gi_nextM M K env I R L tab i M1.node σc.node (Wd.toMlx t.ffi) (Wd.toMlx t1.ffi) outT outs hG1 hgrow fr.nnext
    (fun k v hk => by
      rcases hnewk k v hk with h | ⟨hx, hk', hv⟩
      · exact .inl h
      · refine .inr ⟨hx, mem_of_length_le_one hplen hks1 hk', tk (i + 1), ⟨hs0', hR0⟩, htkb i (by omega), ?_⟩
        rw [List.mem_singleton] at hv
        rw [hv]
        exact hval)
    mr1.yitems ⟨_, hs2, hR2, hout, hcvn, hcapn⟩ (mr1.nimg outT hpout)
    (cachesAt_below _ _ _ fun p hp j hj => mr1.nimg j (hpouts p hp j hj)) hread hfed hcaches

/-- **A loop case's graph step at the machine reference** (`gstep_ofA` over a world; a case of one
run or of pieces, `LoopGStepM`, hence `LoopGStepW` by `LoopGStepM.toW`). -/
theorem gstep_ofM (hPNL : ∀ r, (pr.lp P r).NL = A.NL) (hPN0 : ∀ r, (pr.lp P r).N0 = A.N0)
    (hPE : Wd.E P ≤ A.rope) (hrope : A.rope < 2 ^ 56) {fixA : List Nat} (c : Sim.LoopCaseW Wd A P s0 tab0 fixA)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (toks : List NumV) (i : Nat) (I : TplInputs)
    (outT : Nat) (outs : List (Option Nat × Option Nat))
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (hVt : ∀ nx, V i nx A.tvar = F64.ofNat (L + i + 1)) (hVk : ∀ nx, V i nx A.kvar = F64.ofNat (tk (i + 1)))
    (fwd : CaseFwdM M K env pr A I R L c.s1.ffi c.S1.tab outT outs i)
    (hread : c.σ.node I.read = I.fed) (hfed : c.σ.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map c.σ.node, p.2.map c.σ.node)) = outs)
    (hsread : (Wd.toMlx s0.ffi).items.get I.read = none)
    (hpread : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (h1read : (Wd.toMlx c.s1.ffi).items.get I.read = some (.ref A.tok))
    (h1pread : ((Wd.toMlx c.s1.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hs1tok : (Wd.toMlx c.s1.ffi).tokens = [])
    (htokv : nth? tab0 A.tok = some (.var A.kvar))
    (hpout : ((Wd.toMlx c.s1.ffi).nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → ((Wd.toMlx c.s1.ffi).nodes.get j).isSome = true) :
    LoopGStepM pr (GxM M K env I R L) c V toks i := by
  intro _ nx Mp M1 Kc t t1 Cs C1 hG hst hnum0 _ hhi hle fr hext hend hnum1 hbig
  exact gstep_coreM M K env pr hPNL hPN0 hPE hrope R L V tk toks i I outT outs c.s1 c.S1 c.σ htk htkb fwd hread hfed
    hcaches hsread hpread h1read h1pread hs0tok hs1tok htokv hpout hpouts (hVk nx) (hVt nx) hG hst hnum0 hhi hle fr
    ⟨by rw [hext.node], by rw [hext.node], by rw [hext.node]⟩ hend hnum1 hbig _ _ _ _ _

/-- **A loop case's graph step across cuts at the machine reference** (`LoopGStepCW`, for
`decodeIter_piecesW`): the end pair's valuation keeps the loop table's values (the ghost), so its
time variable when the loop table holds it (`htv`). -/
theorem gstep_ofCM (hPNL : ∀ r, (pr.lp P r).NL = A.NL) (hPN0 : ∀ r, (pr.lp P r).N0 = A.N0)
    (hPE : Wd.E P ≤ A.rope) (hrope : A.rope < 2 ^ 56) {fixA : List Nat} {W : Nat → Option Sim.WFrame}
    {Fr : Sim.LoopFramesA A} (c : Sim.LoopCaseW Wd A P s0 tab0 fixA)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (toks : List NumV) (i : Nat) (I : TplInputs)
    (outT : Nat) (outs : List (Option Nat × Option Nat))
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (hVt : ∀ nx, V i nx A.tvar = F64.ofNat (L + i + 1)) (hVk : ∀ nx, V i nx A.kvar = F64.ofNat (tk (i + 1)))
    (htv : ∃ j, nth? tab0 j = some (.var A.tvar))
    (fwd : CaseFwdM M K env pr A I R L c.s1.ffi c.S1.tab outT outs i)
    (hread : c.σ.node I.read = I.fed) (hfed : c.σ.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map c.σ.node, p.2.map c.σ.node)) = outs)
    (hsread : (Wd.toMlx s0.ffi).items.get I.read = none)
    (hpread : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (h1read : (Wd.toMlx c.s1.ffi).items.get I.read = some (.ref A.tok))
    (h1pread : ((Wd.toMlx c.s1.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hs1tok : (Wd.toMlx c.s1.ffi).tokens = [])
    (htokv : nth? tab0 A.tok = some (.var A.kvar))
    (hpout : ((Wd.toMlx c.s1.ffi).nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → ((Wd.toMlx c.s1.ffi).nodes.get j).isSome = true) :
    Sim.Prefill.LoopGStepCW (liftG Wd (GxM M K env I R L)) W Fr c V toks i := by
  intro _ nx Mp Kc t Cs n x1 hG hst _ _ hhi hrun hgh hend
  obtain ⟨j0, hj0⟩ := htv
  have hVt1 : x1.ν A.tvar = F64.ofNat (L + i + 1) := by
    have := hgh.tab j0 _ hj0
    exact this.trans (hVt nx)
  exact gstep_coreM M K env pr hPNL hPN0 hPE hrope R L V tk toks i I outT outs c.s1 c.S1 c.σ htk htkb fwd hread hfed
    hcaches hsread hpread h1read h1pread hs0tok hs1tok htokv hpout hpouts (hVk nx) hVt1 hG (pr.loadR hst)
    hst.srv.num hhi (Sim.runC_le _ _ _ _ _ hrun) hgh.grows
    ⟨by rw [hgh.ext.node], by rw [hgh.ext.node], by rw [hgh.ext.node]⟩ (pr.loadR hend) hend.srv.num
    (by have hk : x1.K = Kc := hgh.ctx; rw [← hk]; exact hend.bigFixed) _ _ _ _ _

/-- **A loop case's graph step through compactions at the machine reference** (`LoopGStepGW`, for
`decodeIter_piecesCW`): the end's map agrees with the start's at the template's carriers, nodes of
the template start (`IterGhostCW.node`), and the end valuation keeps the time variable when the
loop table holds it. -/
theorem gstep_ofGM (hPNL : ∀ r, (pr.lp P r).NL = A.NL) (hPN0 : ∀ r, (pr.lp P r).N0 = A.N0)
    (hPE : Wd.E P ≤ A.rope) (hrope : A.rope < 2 ^ 56) {fixA : List Nat} {W : Nat → Option Sim.WFrame}
    {Fr : Sim.LoopFramesA A} (e : Sim.Prefill.IterEndW Wd A P s0 tab0 fixA) (g : Sim.Prefill.GhostP)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (toks : List NumV) (i : Nat) (I : TplInputs)
    (outT : Nat) (outs : List (Option Nat × Option Nat))
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (hVt : ∀ nx, V i nx A.tvar = F64.ofNat (L + i + 1)) (hVk : ∀ nx, V i nx A.kvar = F64.ofNat (tk (i + 1)))
    (htv : ∃ j, nth? tab0 j = some (.var A.tvar))
    (hcarR : I.read < (Wd.toMlx s0.ffi).nnext) (hcarF : I.fed < (Wd.toMlx s0.ffi).nnext)
    (hcarC : ∀ p ∈ I.caches, ∀ j, (p.1 = some j ∨ p.2 = some j) → j < (Wd.toMlx s0.ffi).nnext)
    (fwd : CaseFwdM M K env pr A I R L e.s1.ffi e.S1.tab outT outs i)
    (hread : e.σ.node I.read = I.fed) (hfed : e.σ.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map e.σ.node, p.2.map e.σ.node)) = outs)
    (hsread : (Wd.toMlx s0.ffi).items.get I.read = none)
    (hpread : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (h1read : (Wd.toMlx e.s1.ffi).items.get I.read = some (.ref A.tok))
    (h1pread : ((Wd.toMlx e.s1.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hs1tok : (Wd.toMlx e.s1.ffi).tokens = [])
    (htokv : nth? tab0 A.tok = some (.var A.kvar))
    (hpout : ((Wd.toMlx e.s1.ffi).nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → ((Wd.toMlx e.s1.ffi).nodes.get j).isSome = true) :
    Sim.Prefill.LoopGStepGW (liftG Wd (GxM M K env I R L)) W Fr e g V toks i := by
  intro _ nx Mp Kc t Cs n x1 hG hst _ _ hhi hrun hgh hend
  obtain ⟨j0, hj0⟩ := htv
  have hVt1 : x1.ν A.tvar = F64.ofNat (L + i + 1) := (hgh.tab j0 _ hj0).trans (hVt nx)
  have hhi1 : x1.K.hi = Wd.E P := hgh.hi.trans hhi
  exact gstep_coreM M K env pr hPNL hPN0 hPE hrope R L V tk toks i I outT outs e.s1 e.S1 e.σ htk htkb fwd hread hfed
    hcaches hsread hpread h1read h1pread hs0tok hs1tok htokv hpout hpouts (hVk nx) hVt1 hG (pr.loadR hst)
    hst.srv.num hhi1 (Sim.runC_le _ _ _ _ _ hrun) hgh.grows
    ⟨hgh.node _ hcarR, hgh.node _ hcarF, cachesAt_congrM fun p hp j hj => hgh.node j (hcarC p hp j hj)⟩
    (pr.loadR hend) hend.srv.num hend.bigFixed _ _ _ _ _

/-! ## The halts' graph steps -/

/-- **The halted target's conclusions at the machine reference** (`GFL`): the forward result of
every time `L … L + T - 1` and the memoized readbacks' values. -/
def GFM (R : MRef) (L T : Nat) (tab : List F64) (x : Host.Mlx.Ffi.St) : Prop :=
  (∀ k, L ≤ k → k ≤ L + T - 1 → ∃ cs out, ForwardAtM M K env R tab k cs out (Gr tab x)) ∧
  ReadbackValues M K env (CSrv.val ⟨tab⟩) (Gr tab x) x.items

theorem GFM.mono {R : MRef} {L T T' : Nat} {tab : List F64} {x : Host.Mlx.Ffi.St} (h : GFM M K env R L T tab x)
    (hT : T' ≤ T) : GFM M K env R L T' tab x :=
  ⟨fun k h1 h2 => h.1 k h1 (by omega), h.2⟩

/-- **The final iteration's graph conclusions at a halt `sF`/`SF`** at the machine reference
(`fgstep_core_atA` over a world): `GFM` at the halt, and the time-`L + T - 1` forward result at
the images of the template start's carriers. -/
theorem fgstep_coreM (sF : St Wd.F.S) (SF : SSrv) (R : MRef) (L : Nat) (V : Sim.LoopVals)
    (T : Nat) (tk : Nat → Nat) (toks : List NumV) (I : TplInputs)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31)
    (hVk : V (T - 2) (tk T) A.kvar = F64.ofNat (tk (T - 2 + 1))) (hVn : V (T - 2) (tk T) A.nxt = F64.ofNat (tk T))
    (hT : 2 ≤ T) (hne : I.read ≠ I.fed)
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hsB : (Wd.toMlx s0.ffi).items.get I.fed = none)
    (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hpB : ((Wd.toMlx s0.ffi).nodes.get I.fed).isSome = true)
    (hfA : (Wd.toMlx sF.ffi).items.get I.read = some (.ref A.tok))
    (hfB : (Wd.toMlx sF.ffi).items.get I.fed = some (.ref tab0.length))
    (hpfA : ((Wd.toMlx sF.ffi).nodes.get I.read).isSome = true)
    (hpfB : ((Wd.toMlx sF.ffi).nodes.get I.fed).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx sF.ffi).tokens = [])
    (h79 : nth? SF.tab A.tok = some (.var A.kvar)) (h17 : nth? SF.tab tab0.length = some (.var A.nxt))
    (hlen : T - 2 < toks.length) {Mp MF : Sim.Map} {t tF : St Wd.F.S} {Cs CF : CSrv}
    (hGx : GxM M K env I R L (T - 2) Mp (Wd.toMlx t.ffi) Cs)
    (hst : Sim.G.LoadR (pr.lp P (toks.drop (T - 2))) (pr.NB P) Mp tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi))
    (hle : Sim.CSrv.Le Cs CF) (fr : Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx tF.ffi))
    (hext : Sim.Ext (Mp.setNum tab0.length toks[T - 2]) MF (tab0.length + 1))
    (hend : Sim.G.LoadR (pr.lp P (toks.drop (T - 1))) (pr.NB P) MF SF.tab.length (pr.toLoad sF.ffi) (pr.toLoad tF.ffi))
    (hnumF : Sim.NumOK MF (V (T - 2) (tk T)) SF CF) :
    GFM M K env R L T CF.tab (Wd.toMlx tF.ffi) ∧
      ForwardAtM M K env R CF.tab (L + T - 1) (cachesAt MF.node I.caches) (MF.node I.fed) (Gr CF.tab (Wd.toMlx tF.ffi)) := by
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 : Sim.G.MR (pr.lp P (toks.drop (T - 2))) (pr.NB P) Mp tab0.length (Wd.toMlx s0.ffi) (Wd.toMlx t.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hst.mlx
  have mr1 : Sim.G.MR (pr.lp P (toks.drop (T - 1))) (pr.NB P) MF SF.tab.length (Wd.toMlx sF.ffi)
      (Wd.toMlx tF.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hend.mlx
  have hT2 : L + (T - 2) + 1 = L + T - 1 := by omega
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 1) := by
    rw [List.drop_eq_getElem_cons hlen]
    congr 2
    omega
  have hpop : popped.length = 2 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok, pr.rest, pr.rest] at hpe
    have hpe' : Mp.nv (.ref A.tok) :: toks[T - 2] :: toks.drop (T - 1) = popped ++ toks.drop (T - 1) := by
      rw [← hdrop]; exact hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks2 : ks.length ≤ 2 := hpop ▸ hks
  have hslotA : (Wd.toMlx tF.ffi).items.get (MF.node I.read) = some (MF.nv (.ref A.tok)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hslotB : (Wd.toMlx tF.ffi).items.get (MF.node I.fed) = some (MF.nv (.ref tab0.length)) := by
    rw [mr1.items I.fed hpfB, hfB]; rfl
  have hfreshA : (Wd.toMlx t.ffi).items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hfreshB : (Wd.toMlx t.ffi).items.get (MF.node I.fed) = none := by
    rw [hnode, mr0.items I.fed hpB, hsB]; rfl
  have hinA : MF.node I.read ∈ ks := by
    rcases hnewk _ _ hslotA with h | ⟨_, h, _⟩
    · rw [hfreshA] at h; cases h
    · exact h
  have hinB : MF.node I.fed ∈ ks := by
    rcases hnewk _ _ hslotB with h | ⟨_, h, _⟩
    · rw [hfreshB] at h; cases h
    · exact h
  have hneF : MF.node I.read ≠ MF.node I.fed := fun h => hne (mr1.ninj _ _ hpfA hpfB h)
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref A.tok)) = some (F64.ofNat (tk (T - 2 + 1))) := by
    change CSrv.val ⟨CF.tab⟩ (MF.num A.tok) = _
    rw [hnumF A.tok _ h79]
    show some (V (T - 2) (tk T) A.kvar) = _
    rw [hVk]
  have hvB : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref tab0.length)) = some (F64.ofNat (tk T)) := by
    change CSrv.val ⟨CF.tab⟩ (MF.num tab0.length) = _
    rw [hnumF tab0.length _ h17]
    show some (V (T - 2) (tk T) A.nxt) = _
    rw [hVn]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  rotate_left 2
  · obtain ⟨tok, hs, hR, htok, hcv, _, hlt, hcb⟩ := hG.cur
    rw [hnode]
    exact forwardAtM_time M K env hT2
      (Mach.ForwardAtM.grow M K env _ _ _ _ ⟨tok, hs, hR, htok, hcv⟩ hgrow hlt hcb)
  · intro k h1 h2
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega)
    exact ⟨cs, out, Mach.ForwardAtM.grow M K env _ _ _ _ hf hgrow ho hc⟩
  · intro k v hk
    rcases hnewk k v hk with hx | ⟨_, hkk, _⟩
    · obtain ⟨token, htk', ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < (Wd.toMlx t.ffi).nnext := by
        by_contra hc
        cases (hG.reads.2 k (Nat.le_of_not_lt hc)).symm.trans hx
      exact ⟨token, htk', ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
    · rcases mem_of_length_le_two hks2 hinA hinB hneF hkk with rfl | rfl
      · rw [hslotA] at hk
        cases hk
        obtain ⟨cs, ⟨tok, hs, hR, ⟨r, hr, hi⟩, _⟩, hlt, _⟩ := hG.read
        obtain ⟨hs', hR'⟩ := htk CF.tab (T - 2) (by omega)
        obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans hR'))
        exact ⟨_, htkb (T - 2) (by omega), ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩,
          hvA⟩
      · rw [hslotB] at hk
        cases hk
        obtain ⟨tok, hs, hR, ⟨r, hr, hi⟩, _, _, hlt, _⟩ := hG.cur
        obtain ⟨hs', hR'⟩ := htk CF.tab (T - 1) (by omega)
        have e : L + (T - 2) + 1 = L + (T - 1) := by omega
        rw [e] at hR
        obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans hR'))
        rw [show T - 1 + 1 = T by omega] at hi
        exact ⟨_, by have := htkb (T - 1) (by omega); rwa [show T - 1 + 1 = T by omega] at this,
          ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvB⟩

/-- **A final chain's graph obligation at the machine reference** (`lgstep_ofA` over a world): the
goal `GFM` at `T`. -/
theorem lgstep_ofM {W : Nat → Option Sim.WFrame} {fixA : List Nat} {T : Nat} {toks : List NumV} {xs : List Val}
    (hs : Sim.HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (I : TplInputs)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31)
    (hVk : V (T - 2) (tk T) A.kvar = F64.ofNat (tk (T - 2 + 1))) (hVn : V (T - 2) (tk T) A.nxt = F64.ofNat (tk T))
    (hT : 2 ≤ T) (hne : I.read ≠ I.fed)
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hsB : (Wd.toMlx s0.ffi).items.get I.fed = none)
    (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hpB : ((Wd.toMlx s0.ffi).nodes.get I.fed).isSome = true)
    (hfA : (Wd.toMlx hs.case.sF.ffi).items.get I.read = some (.ref A.tok))
    (hfB : (Wd.toMlx hs.case.sF.ffi).items.get I.fed = some (.ref tab0.length))
    (hpfA : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.read).isSome = true)
    (hpfB : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.fed).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx hs.case.sF.ffi).tokens = [])
    (h79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar))
    (h17 : nth? hs.case.SF.tab tab0.length = some (.var A.nxt)) :
    LastGStepM pr (fixA := fixA) (GxM M K env I R L) hs V tk
      (fun tF CF => GFM M K env R L T CF.tab (Wd.toMlx tF.ffi)) := by
  intro hlen nx Mp Kc t Cs xF hGx _ hst _ _ _ hle fr hext hν hend
  obtain ⟨hR, -⟩ := hs.rend xF _ _ hend
  rw [hν] at hR
  exact (fgstep_coreM M K env pr hs.case.sF hs.case.SF R L V T tk toks I htk htkb hVk hVn hT hne hsA hsB hpA hpB
    hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen hGx hst hle fr hext (pr.loadR hR) hR.srv.num).1

/-- **A halting chain's program caches** (`final_cache`'s conclusion over a world): at its end relation,
under a map fixing `fixA`, the `cache` binding of the target's load-world part extracts to caches at
the images of the template's carriers `I.caches`. -/
def FinalCacheW {W : Nat → Option Sim.WFrame} {r : List NumV} {st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val}
    (fixA : List Nat) (I : TplInputs) (je : Host.Ts.Env) (hs : Sim.HaltSegW Wd A W P r s0 st0 tab1 xs) : Prop :=
  ∀ xF : Sim.SegInst Wd.F, (∀ a ∈ fixA, xF.M.a a = a) → hs.case.Rend xF hs.case.sF hs.case.SF →
    ∃ cs, Sim.ExtractSim.cachesT (xF.t.reFfi (pr.toLoad xF.t.ffi)) je = some cs ∧
      cs.map cacheNodePair = I.caches.map fun p => (p.1.map xF.M.node, p.2.map xF.M.node)

/-- **A halting chain's cache facts** (`final_cache`'s premises over a world, kernel checks of the
chain's end state `sF`): the `cache` cell `cc` fixed and outside `W`'s domain `wl`, holding the list
`aL`, unframed in the end context (`QF`); the extraction's objects and cells outside `wl`
(`cachesOkWB`); the caches at the template's carriers. -/
structure FinalCacheTpl {W : Nat → Option Sim.WFrame} {r : List NumV} {st0 : St Wd.F.S} {tab1 : List SymE}
    {xs : List Val} (fixA : List Nat) (I : TplInputs) (je : Host.Ts.Env) (hs : Sim.HaltSegW Wd A W P r s0 st0 tab1 xs) where
  wl : List Nat
  hW : ∀ a w, W a = some w → a ∈ wl
  cc : Nat
  aL : Nat
  hcc : lookupEnv chars!"cache" je = some cc
  hfix : cc ∈ fixA
  hwc : W cc = none
  hcell : hs.case.sF.cell? cc = some (some (.obj aL))
  hQF : ∀ ν K, hs.QF ν K → K.fr aL = none
  hok : Sim.cachesOkWB hs.case.sF je wl = true
  cs : List Cache
  hcs : Sim.ExtractSim.cachesT (hs.case.sF.reFfi (pr.toLoad hs.case.sF.ffi)) je = some cs
  hn : cs.map cacheNodePair = I.caches

/-- **The program caches from the cache facts** (`final_cache` over a world: `RelB.cachesTW_end`). -/
theorem FinalCacheTpl.cache {W : Nat → Option Sim.WFrame} {r : List NumV} {st0 : St Wd.F.S} {tab1 : List SymE}
    {xs : List Val} {fixA : List Nat} {I : TplInputs} {je : Host.Ts.Env} {hs : Sim.HaltSegW Wd A W P r s0 st0 tab1 xs}
    (c : FinalCacheTpl pr fixA I je hs) : FinalCacheW pr fixA I je hs := by
  intro xF hfix hend
  obtain ⟨hR, hQ⟩ := hs.rend xF _ _ hend
  have hcs : Sim.cachesTW (fun x => (pr.toLoad x).mlx) hs.case.sF je = some c.cs := by
    rw [← Sim.cachesTW_reFfi (fun x : Host.Load.LSt => x.mlx) hs.case.sF pr.toLoad, Sim.cachesTW_lf]
    exact c.hcs
  obtain ⟨cs', h1, h2⟩ := hR.cachesTW_end c.hW (mx := fun x => (pr.toLoad x).mlx) (pr.loadR hR).mlx.toMRw c.hcc
    (hfix _ c.hfix) c.hwc c.hcell (c.hQF _ _ hQ) c.hok hcs
  refine ⟨cs', ?_, ?_⟩
  · rw [← Sim.cachesTW_lf, Sim.cachesTW_reFfi]
    exact h1
  · have e : (Sim.ExtractSim.nodePair : Cache → Option Nat × Option Nat) = cacheNodePair := rfl
    have := Sim.cacheRW_nodes h2
    rw [e, c.hn] at this
    exact this

/-- **A final chain's graph obligation with the program's caches** at the machine reference
(`fgstepC_ofL` over a world): the goal `GFM` at `T`, and the `cache` binding's caches hold the
reference's handles at `L + T - 1`. -/
theorem lgstepC_ofM {W : Nat → Option Sim.WFrame} {fixA : List Nat} {T : Nat} {toks : List NumV} {xs : List Val}
    (hs : Sim.HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (I : TplInputs) (je : Host.Ts.Env)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31)
    (hVk : V (T - 2) (tk T) A.kvar = F64.ofNat (tk (T - 2 + 1))) (hVn : V (T - 2) (tk T) A.nxt = F64.ofNat (tk T))
    (hT : 2 ≤ T) (hne : I.read ≠ I.fed)
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hsB : (Wd.toMlx s0.ffi).items.get I.fed = none)
    (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hpB : ((Wd.toMlx s0.ffi).nodes.get I.fed).isSome = true)
    (hfA : (Wd.toMlx hs.case.sF.ffi).items.get I.read = some (.ref A.tok))
    (hfB : (Wd.toMlx hs.case.sF.ffi).items.get I.fed = some (.ref tab0.length))
    (hpfA : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.read).isSome = true)
    (hpfB : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.fed).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx hs.case.sF.ffi).tokens = [])
    (h79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar))
    (h17 : nth? hs.case.SF.tab tab0.length = some (.var A.nxt)) (hc : FinalCacheW pr fixA I je hs) :
    LastGStepM pr (fixA := fixA) (GxM M K env I R L) hs V tk
      (fun tF CF => GFM M K env R L T CF.tab (Wd.toMlx tF.ffi) ∧ ∃ cs out,
        Sim.ExtractSim.cachesT (tF.reFfi (pr.toLoad tF.ffi)) je = some cs ∧
          ForwardAtM M K env R CF.tab (L + T - 1) cs out (Gr CF.tab (Wd.toMlx tF.ffi))) := by
  intro hlen nx Mp Kc t Cs xF hGx hfix hst _ _ _ hle fr hext hν hend
  have hfix' : ∀ a ∈ fixA, xF.M.a a = a := fun a ha => by rw [hext.a]; exact hfix a ha
  obtain ⟨cs, hcs, hn⟩ := hc xF hfix' hend
  obtain ⟨hR, -⟩ := hs.rend xF _ _ hend
  rw [hν] at hR
  obtain ⟨h1, h2⟩ := fgstep_coreM M K env pr hs.case.sF hs.case.SF R L V T tk toks I htk htkb hVk hVn hT hne hsA hsB
    hpA hpB hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen hGx hst hle fr hext (pr.loadR hR) hR.srv.num
  exact ⟨h1, cs, _, hcs, forwardAtM_congrC M K env h2 ((Iter.cachesAt_nodes _ _).trans hn.symm)⟩

/-- **The graph conclusions of a halt at the cut of iteration `i`** at the machine reference
(`egstep_coreA` over a world). -/
theorem egstep_coreM (sF : St Wd.F.S) (SF : SSrv) (R : MRef) (L : Nat) (V : Sim.LoopVals)
    (tk : Nat → Nat) (toks : List NumV) (I : TplInputs) (i : Nat)
    (htk : ∀ tab j, j ≤ i + 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : tk (i + 1) < 2 ^ 31)
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hfA : (Wd.toMlx sF.ffi).items.get I.read = some (.ref A.tok))
    (hpfA : ((Wd.toMlx sF.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx sF.ffi).tokens = [])
    (h79 : nth? SF.tab A.tok = some (.var A.kvar))
    {nx : Nat} (hVk : V i nx A.kvar = F64.ofNat (tk (i + 1))) {Mp MF : Sim.Map} {t tF : St Wd.F.S} {Cs CF : CSrv}
    (hGx : GxM M K env I R L i Mp (Wd.toMlx t.ffi) Cs)
    (hst : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) Mp tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi))
    (hle : Sim.CSrv.Le Cs CF) (fr : Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx tF.ffi))
    (hext : Sim.Ext Mp MF tab0.length)
    (hend : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) MF SF.tab.length (pr.toLoad sF.ffi) (pr.toLoad tF.ffi))
    (hnumF : Sim.NumOK MF (V i nx) SF CF) :
    GFM M K env R L (i + 2) CF.tab (Wd.toMlx tF.ffi) ∧
      ForwardAtM M K env R CF.tab (L + i + 1) (cachesAt MF.node I.caches) (MF.node I.fed) (Gr CF.tab (Wd.toMlx tF.ffi)) := by
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 : Sim.G.MR (pr.lp P (toks.drop i)) (pr.NB P) Mp tab0.length (Wd.toMlx s0.ffi) (Wd.toMlx t.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hst.mlx
  have mr1 : Sim.G.MR (pr.lp P (toks.drop i)) (pr.NB P) MF SF.tab.length (Wd.toMlx sF.ffi) (Wd.toMlx tF.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hend.mlx
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped.length = 1 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok, pr.rest] at hpe
    have hpe' : Mp.nv (.ref A.tok) :: toks.drop i = popped ++ toks.drop i := hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks1 : ks.length ≤ 1 := hpop ▸ hks
  have hslotA : (Wd.toMlx tF.ffi).items.get (MF.node I.read) = some (MF.nv (.ref A.tok)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hfreshA : (Wd.toMlx t.ffi).items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hinA : MF.node I.read ∈ ks := by
    rcases hnewk _ _ hslotA with h | ⟨_, h, _⟩
    · rw [hfreshA] at h; cases h
    · exact h
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref A.tok)) = some (F64.ofNat (tk (i + 1))) := by
    change CSrv.val ⟨CF.tab⟩ (MF.num A.tok) = _
    rw [hnumF A.tok _ h79]
    show some (V i nx A.kvar) = _
    rw [hVk]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · intro k h1 h2
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega)
    exact ⟨cs, out, Mach.ForwardAtM.grow M K env _ _ _ _ hf hgrow ho hc⟩
  · intro k v hk
    rcases hnewk k v hk with hx | ⟨_, hkk, _⟩
    · obtain ⟨token, htk', ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < (Wd.toMlx t.ffi).nnext := by
        by_contra hc
        cases (hG.reads.2 k (Nat.le_of_not_lt hc)).symm.trans hx
      exact ⟨token, htk', ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
    · obtain rfl := mem_of_length_le_one hks1 hinA hkk
      rw [hslotA] at hk
      cases hk
      obtain ⟨cs, ⟨tok, hs, hR, ⟨r, hr, hi⟩, _⟩, hlt, _⟩ := hG.read
      obtain ⟨hs', hR'⟩ := htk CF.tab i (by omega)
      obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans hR'))
      exact ⟨_, htkb, ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvA⟩
  · obtain ⟨tok, hs, hR, htok, hcv, _, hlt, hcb⟩ := hG.cur
    rw [hnode]
    exact Mach.ForwardAtM.grow M K env _ _ _ _ ⟨tok, hs, hR, htok, hcv⟩ hgrow hlt hcb

/-- **A cut halt's graph obligation at the machine reference** (`cgstep_ofA` over a world): the
goal `GFM (i + 2)`. -/
theorem cgstep_ofM {W : Nat → Option Sim.WFrame} {fixA : List Nat} {toks : List NumV} {i : Nat}
    (hs : Sim.HaltSegW Wd A W P (toks.drop i) s0 s0 tab0 []) (R : MRef) (L : Nat) (V : Sim.LoopVals)
    (tk : Nat → Nat) (I : TplInputs)
    (htk : ∀ tab j, j ≤ i + 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : tk (i + 1) < 2 ^ 31) (hVk : ∀ nx, V i nx A.kvar = F64.ofNat (tk (i + 1)))
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hfA : (Wd.toMlx hs.case.sF.ffi).items.get I.read = some (.ref A.tok))
    (hpfA : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx hs.case.sF.ffi).tokens = [])
    (h79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar)) :
    CutGStepM pr (fixA := fixA) (GxM M K env I R L) hs V
      (fun tF CF => GFM M K env R L (i + 2) CF.tab (Wd.toMlx tF.ffi)) := by
  intro nx Mp Kc t Cs xF hGx _ hst _ _ _ hle fr hext hν hend
  obtain ⟨hR, -⟩ := hs.rend xF _ _ hend
  rw [hν] at hR
  exact (egstep_coreM M K env pr hs.case.sF hs.case.SF R L V tk toks I i htk htkb hsA hpA hfA hpfA hs0tok hsFtok
    h79 (hVk nx) hGx hst hle fr hext (pr.loadR hR) hR.srv.num).1

end Steps

end Host.Mlx.SimGraph
