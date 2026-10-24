import host.simgraph.iter.Exit
import host.sim.LoopL
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim.ExtractSim (cachesT nodePair cachesAllB cacheOkB)
open Inference.Models.Qwen

/-! # The graph invariant of the decode loop after a prompt of length `L`

`GI` (Inv.lean) carries, at iteration `i` (time `i + 2`), the forward results of the reference
`(firstContext …).run promptToken` (the decode of the one-token prompt). After a prompt of `L`
tokens, the cut of iteration `i` sits at absolute time `L + i + 1` with KV capacity
`capL (L + i + 1)`, and the reference is the context after the prompt. That reference is a
parameter here (`RefRun`: the reached state at every table and time; the prefill workstream
constructs it), so are its tokens (`htk`: the valuation's token `j + 1` is the reference's
token at time `L + j`).

* `ForwardAtR`, `GIL`, `GxL`: `ForwardAt`, `GI`, `Gx` at absolute times, with the reference `R`.
* `gi_nextL`, `CaseFwdL`, `gstep_ofL` (discharges `Sim.LoopGStepL (GxL …)`): one iteration.
* `GFL`, `GFCL`, `fgstep_coreL`, `fgstepC_ofL`: the final case's conclusions (times `L … L + T - 1`).
* `egstep_coreL`, `egstepC_ofL`, `fgstep_core_atL`, `fgstepEC_ofL`: the EOS stops.
* At `L = 1` with the existing reference (`refPrompt1`) every definition is the existing one
  (`forwardAtR_one`, `GIL_one`, `GxL_one`, `GFL_one`, `GFCL_one`). -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

/-! ## The reference -/

/-- A reference trajectory: at every table, the reached state at every time. -/
abbrev RefRun :=
  (tab : List F64) → (time : Nat) → time ≤ 262144 → TokenAutoregressive.State (firstPipeline M K env tab leaves typed) time

/-- The existing reference: the decode of the one-token prompt `promptToken`. -/
noncomputable def refPrompt1 (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed)) :
    RefRun M K env leaves typed :=
  fun tab time hb => (firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run promptToken
    time hb

theorem forall_time {F : (n : Nat) → n ≤ 262144 → Prop} {a b : Nat} (e : a = b) (h : ∀ ha, F a ha) :
    ∀ hb, F b hb := by
  subst e; exact h

theorem ref_token_congr (R : RefRun M K env leaves typed) (tab : List F64) {a b : Nat} (e : a = b) (ha : a ≤ 262144)
    (hb : b ≤ 262144) : (R tab a ha).token = (R tab b hb).token := by
  subst e; rfl

/-- `ForwardAt` at the reference `R`. -/
def ForwardAtR (R : RefRun M K env leaves typed) (tab : List F64) (time : Nat) (hb : time ≤ 262144)
    (cs : List Cache) (out : Nat) (G : Nat → Option (RNode Int InKey)) : Prop :=
  ∃ hs, (∃ r, evalR M K env G out = some r ∧ itemUint32 r = some (R tab time hb).token.val) ∧
    ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs (R tab time hb).cache ∧
    CacheValues M K env G cs hs

/-- **At the existing reference `ForwardAtR` is `ForwardAt`.** -/
theorem forwardAtR_one (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))
    (tab : List F64) (time : Nat) (hb : time ≤ 262144) (cs : List Cache) (out : Nat)
    (G : Nat → Option (RNode Int InKey)) :
    ForwardAtR M K env leaves typed (refPrompt1 M K env leaves typed parameters) tab time hb cs out G ↔
      ForwardAt M K env tab leaves typed (hpOf M K env leaves typed parameters tab) time hb cs out G := Iff.rfl

theorem ForwardAtR.grow {R : RefRun M K env leaves typed} {tab : List F64} {time : Nat} {hb : time ≤ 262144}
    {cs : List Cache} {out : Nat} (N : Nums Int) (Ks : KernelSources) (s s' : Ffi.St)
    (h : ForwardAtR M K env leaves typed R tab time hb cs out (ffiGraph N Ks s))
    (hg : Grows Ks s s') (hout : out < s.nnext) (hlt : CachesBelow cs s.nnext) :
    ForwardAtR M K env leaves typed R tab time hb cs out (ffiGraph N Ks s') := by
  obtain ⟨hs, ⟨r, hr, ht⟩, hh, hc⟩ := h
  exact ⟨hs, ⟨r, evalR_grows M K env N Ks s s' hg out hout r hr, ht⟩, hh,
    cacheValues_grows M K env N Ks s s' hg cs hs hlt hc⟩

theorem forwardAtR_time {R : RefRun M K env leaves typed} {tab : List F64} {a b : Nat} (e : a = b)
    (ha : a ≤ 262144) (hb : b ≤ 262144) {cs : List Cache} {out : Nat} {G : Nat → Option (RNode Int InKey)}
    (h : ForwardAtR M K env leaves typed R tab a ha cs out G) : ForwardAtR M K env leaves typed R tab b hb cs out G := by
  subst e; exact h

/-- `ForwardAtR` reads its caches only through their tensor nodes. -/
theorem forwardAtR_congr {R : RefRun M K env leaves typed} {tab : List F64} {time : Nat} {hb : time ≤ 262144}
    {cs cs' : List Cache} {out : Nat} {G : Nat → Option (RNode Int InKey)}
    (h : ForwardAtR M K env leaves typed R tab time hb cs out G) (hc : cs.map cacheNodePair = cs'.map cacheNodePair) :
    ForwardAtR M K env leaves typed R tab time hb cs' out G := by
  obtain ⟨hs, htok, hh, hv⟩ := h
  refine ⟨hs, htok, hh, ?_⟩
  clear hh htok
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

/-! ## The invariant -/

/-- **The invariant at iteration `i` after a prompt of length `L`** (absolute time `L + i + 1`),
at table `tab`, for the target native state `x` under the node map `σ`, with reference `R`. -/
structure GIL (I : TplInputs) (R : RefRun M K env leaves typed) (L : Nat) (tab : List F64) (i : Nat)
    (σ : Nat → Nat) (x : Ffi.St) : Prop where
  hist : ∀ k (_ : L ≤ k) (_ : k ≤ L + i + 1) (hb : k ≤ 262144), ∃ cs out,
    ForwardAtR M K env leaves typed R tab k hb cs out (Gr tab x) ∧ out < x.nnext ∧ CachesBelow cs x.nnext
  read : ∀ (hb : L + i ≤ 262144), ∃ cs,
    ForwardAtR M K env leaves typed R tab (L + i) hb cs (σ I.read) (Gr tab x) ∧ σ I.read < x.nnext ∧
      CachesBelow cs x.nnext
  cur : ∀ (hb : L + i + 1 ≤ 262144), ∃ hs,
    (∃ r, evalR M K env (Gr tab x) (σ I.fed) = some r ∧ itemUint32 r = some (R tab (L + i + 1) hb).token.val) ∧
    ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs (R tab (L + i + 1) hb).cache ∧
    CacheValues M K env (Gr tab x) (cachesAt σ I.caches) hs ∧
    CapsFor (Sim.capL (L + i + 1)) (stageWeights (weights (firstValues M K env tab))) hs ∧
    σ I.fed < x.nnext ∧ CachesBelow (cachesAt σ I.caches) x.nnext
  params : ∀ t ∈ parameterTensors parameterChoice, evalR M K env (Gr tab x) t.node = some (firstValues M K env tab t) ∧
    t.node < x.nnext
  reads : ReadbackValues M K env (CSrv.val ⟨tab⟩) (Gr tab x) x.items ∧ ∀ k, x.nnext ≤ k → x.items.get k = none

/-- **The loop's graph invariant after a prompt of length `L`** (`LoopInvL`'s `Gx`). -/
def GxL (I : TplInputs) (R : RefRun M K env leaves typed) (L : Nat) (i : Nat) (Mp : Host.Ts.Sim.Map)
    (t : St Host.Load.LSt) (Cs : CSrv) : Prop :=
  ∀ tab, Host.Ts.Sim.CSrv.Le Cs ⟨tab⟩ → GIL M K env leaves typed I R L tab i Mp.node t.ffi.mlx

theorem capL_capOf (i : Nat) : Sim.capL (1 + i + 1) = capOf i := by unfold Sim.capL capOf; omega

/-- **At `L = 1` with the existing reference, `GIL` is `GI`.** -/
theorem GIL_one (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))
    (I : TplInputs) (tab : List F64) (i : Nat) (σ : Nat → Nat) (x : Ffi.St) :
    GIL M K env leaves typed I (refPrompt1 M K env leaves typed parameters) 1 tab i σ x ↔
      GI M K env leaves typed parameters I tab i σ x := by
  constructor
  · intro h
    refine ⟨fun k h1 h2 hb => h.hist k h1 (by omega) hb, ?_, ?_, h.params, h.reads⟩
    · exact forall_time (F := fun n hb => ∃ cs, ForwardAtR M K env leaves typed (refPrompt1 M K env leaves typed
        parameters) tab n hb cs (σ I.read) (Gr tab x) ∧ σ I.read < x.nnext ∧ CachesBelow cs x.nnext)
        (by omega) h.read
    · have hc := h.cur
      rw [capL_capOf] at hc
      exact forall_time (F := fun n hb => ∃ hs, (∃ r, evalR M K env (Gr tab x) (σ I.fed) = some r ∧
          itemUint32 r = some (refPrompt1 M K env leaves typed parameters tab n hb).token.val) ∧
        ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs
          (refPrompt1 M K env leaves typed parameters tab n hb).cache ∧
        CacheValues M K env (Gr tab x) (cachesAt σ I.caches) hs ∧
        CapsFor (capOf i) (stageWeights (weights (firstValues M K env tab))) hs ∧
        σ I.fed < x.nnext ∧ CachesBelow (cachesAt σ I.caches) x.nnext) (by omega) hc
  · intro h
    refine ⟨fun k h1 h2 hb => h.hist k h1 (by omega) hb, ?_, ?_, h.params, h.reads⟩
    · exact forall_time (F := fun n hb => ∃ cs, ForwardAtR M K env leaves typed (refPrompt1 M K env leaves typed
        parameters) tab n hb cs (σ I.read) (Gr tab x) ∧ σ I.read < x.nnext ∧ CachesBelow cs x.nnext)
        (by omega) h.read
    · rw [capL_capOf]
      exact forall_time (F := fun n hb => ∃ hs, (∃ r, evalR M K env (Gr tab x) (σ I.fed) = some r ∧
          itemUint32 r = some (refPrompt1 M K env leaves typed parameters tab n hb).token.val) ∧
        ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs
          (refPrompt1 M K env leaves typed parameters tab n hb).cache ∧
        CacheValues M K env (Gr tab x) (cachesAt σ I.caches) hs ∧
        CapsFor (capOf i) (stageWeights (weights (firstValues M K env tab))) hs ∧
        σ I.fed < x.nnext ∧ CachesBelow (cachesAt σ I.caches) x.nnext) (by omega) h.cur

/-- **At `L = 1` with the existing reference, `GxL` is `Gx`.** -/
theorem GxL_one (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))
    (I : TplInputs) (i : Nat) (Mp : Host.Ts.Sim.Map) (t : St Host.Load.LSt) (Cs : CSrv) :
    GxL M K env leaves typed I (refPrompt1 M K env leaves typed parameters) 1 i Mp t Cs ↔
      Gx M K env leaves typed parameters I i Mp t Cs :=
  ⟨fun h tab hle => (GIL_one M K env leaves typed parameters I tab i _ _).1 (h tab hle),
   fun h tab hle => (GIL_one M K env leaves typed parameters I tab i _ _).2 (h tab hle)⟩

/-- `GxL_one` as an equality of the further invariants: every statement about `Gx` (the loop
cases' `LoopGStep (Gx …)`, …) is one about `GxL … 1`. -/
theorem GxL_one_eq (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))
    (I : TplInputs) :
    GxL M K env leaves typed I (refPrompt1 M K env leaves typed parameters) 1 = Gx M K env leaves typed parameters I := by
  funext i Mp t Cs
  exact propext (GxL_one M K env leaves typed parameters I i Mp t Cs)

/-- **One iteration of the invariant** after a prompt of length `L` (`gi_next`). -/
theorem gi_nextL (I : TplInputs) (R : RefRun M K env leaves typed) (L : Nat) (tab : List F64) (i : Nat)
    (σ σT : Nat → Nat) (x x1 : Ffi.St) (outT : Nat) (outs : List (Option Nat × Option Nat))
    (hG : GIL M K env leaves typed I R L tab i σ x)
    (hgrow : Grows SourceKernels.sources x x1) (hn : x.nnext ≤ x1.nnext)
    (hb : L + i + 2 ≤ 262144)
    (hnew : ∀ k v, x1.items.get k = some v → x.items.get k = some v ∨ (x.items.get k = none ∧ k = σ I.read ∧
      CSrv.val ⟨tab⟩ v = some (F64.ofNat (R tab (L + i) (by omega)).token.val)))
    (hyitems : ∀ k, x1.nnext ≤ k → x1.items.get k = none)
    (hfwd : ∃ next, (∃ r, evalR M K env (Gr tab x1) (σ outT) = some r ∧
        itemUint32 r = some (R tab (L + i + 2) hb).token.val) ∧
      ChainHolds (firstPipeline M K env tab leaves typed).graph.stages next (R tab (L + i + 2) hb).cache ∧
      CacheValues M K env (Gr tab x1) (cachesAt σ outs) next ∧
      CapsFor (Sim.capL (L + i + 2)) (stageWeights (weights (firstValues M K env tab))) next)
    (hout : σ outT < x1.nnext) (houts : CachesBelow (cachesAt σ outs) x1.nnext)
    (hread : σT I.read = I.fed) (hfed : σT I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map σT, p.2.map σT)) = outs) :
    GIL M K env leaves typed I R L tab (i + 1) (fun j => σ (σT j)) x1 where
  hist := by
    intro k h1 h2 hk
    by_cases hk2 : k ≤ L + i + 1
    · obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 hk2 hk
      refine ⟨cs, out, ForwardAtR.grow M K env leaves typed _ _ _ _ hf hgrow ho hc, by omega, ?_⟩
      intro c hc' t ht; have := hc c hc' t ht; omega
    · have hk3 : k = L + i + 2 := by omega
      subst hk3
      obtain ⟨next, htok, hh, hc, _⟩ := hfwd
      exact ⟨cachesAt σ outs, σ outT, ⟨next, htok, hh, hc⟩, hout, houts⟩
  read := by
    intro hb'
    obtain ⟨hs, htok, hh, hc, _, hf, hcb⟩ := hG.cur (by omega)
    refine ⟨cachesAt σ I.caches, ?_, ?_, ?_⟩
    · simp only [hread]
      exact ForwardAtR.grow M K env leaves typed _ _ _ _ ⟨hs, htok, hh, hc⟩ hgrow hf hcb
    · simp only [hread]; omega
    · intro c hc' t ht; have := hcb c hc' t ht; omega
  cur := by
    intro hb'
    obtain ⟨next, htok, hh, hc, hcaps⟩ := hfwd
    have he : cachesAt (fun j => σ (σT j)) I.caches = cachesAt σ outs := by
      rw [← hcaches, cachesAt_comp]
    refine ⟨next, ?_, hh, by rw [he]; exact hc, hcaps, by simp only [hfed]; exact hout, by rw [he]; exact houts⟩
    simp only [hfed]
    exact htok
  params := by
    intro t ht
    obtain ⟨hv, hlt⟩ := hG.params t ht
    exact ⟨evalR_grows M K env _ _ _ _ hgrow _ hlt _ hv, by omega⟩
  reads := by
    refine ⟨?_, hyitems⟩
    intro k v hk
    rcases hnew k v hk with hx | ⟨_, rfl, hν⟩
    · obtain ⟨token, htk, ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < x.nnext := by
        by_contra hc
        rw [hG.reads.2 k (by omega)] at hx
        cases hx
      exact ⟨token, htk, ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
    · obtain ⟨cs, ⟨hs, ⟨r, hr, hi⟩, _, _⟩, hlt, _⟩ := hG.read (by omega)
      refine ⟨_, ?_, ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
      have := (R tab (L + i) (by omega)).token.isLt
      omega

/-! ## A loop case's graph step -/

/-- A loop case's forward result at iteration `i` after a prompt of length `L` (absolute time
`L + i + 1`; `CaseFwd`): the next token at the image of `outT`, the next caches at the images of
`outs` with capacity `capL (L + i + 2)`. -/
def CaseFwdL (I : TplInputs) (R : RefRun M K env leaves typed) (L : Nat) (s1 : LSt) (S1tab : List SymE)
    (outT : Nat) (outs : List (Option Nat × Option Nat)) (i : Nat) (hb : L + i + 2 ≤ 262144) : Prop :=
  ∀ (tab : List F64) (P : Sim.LoadP) (Mp : Sim.Map) (n : Nat) (y : LSt) (ν : Nat → F64),
    Sim.LoadR P Mp n s1 y → P.NL = 20000 → P.N0 = 22539 → ν 9 = F64.ofNat (L + i + 1) →
    (∀ j e, nth? S1tab j = some e → CSrv.val ⟨tab⟩ (Mp.nv (.ref j)) = some (e.eval ν)) →
    Mp.big 5554869888 = 5554869888 →
    ∀ hs, ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs (R tab (L + i + 1) (by omega)).cache →
      CapsFor (Sim.capL (L + i + 1)) (stageWeights (weights (firstValues M K env tab))) hs →
      CacheValues M K env (Gr tab y.mlx) (cachesAt Mp.node I.caches) hs →
      (∃ r, evalR M K env (Gr tab y.mlx) (Mp.node I.fed) = some r ∧
        itemUint32 r = some (R tab (L + i + 1) (by omega)).token.val) →
      (∀ t ∈ parameterTensors parameterChoice, evalR M K env (Gr tab y.mlx) t.node = some (firstValues M K env tab t)) →
      ∃ next, (∃ r, evalR M K env (Gr tab y.mlx) (Mp.node outT) = some r ∧
          itemUint32 r = some (R tab (L + i + 2) hb).token.val) ∧
        ChainHolds (firstPipeline M K env tab leaves typed).graph.stages next (R tab (L + i + 2) hb).cache ∧
        CacheValues M K env (Gr tab y.mlx) (cachesAt Mp.node outs) next ∧
        CapsFor (Sim.capL (L + i + 2)) (stageWeights (weights (firstValues M K env tab))) next

/-- **A loop case's graph step after a prompt of length `L`** (`gstep_of`): `htk` gives the
valuation's tokens as the reference's (token `j + 1` at time `L + j`). -/
theorem gstep_ofL {ok : St Sim.LF.S → SSrv → Bool} {P : Sim.LoadP} {s0 : St Sim.LF.S} {tab0 : List SymE}
    {fixA : List Nat} (hPNL : P.NL = 20000) (hPN0 : P.N0 = 22539) (hPE : P.E ≤ 5554869888)
    (c : Sim.LoopCase ok P s0 tab0 fixA) (R : RefRun M K env leaves typed) (L : Nat) (ρ : Nat → F64) (T : Nat)
    (tk : Nat → Nat) (toks : List NumV) (i : Nat) (I : TplInputs) (outT : Nat) (outs : List (Option Nat × Option Nat))
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hb : L + i + 2 ≤ 262144)
    (fwd : CaseFwdL M K env leaves typed I R L c.s1.ffi c.S1.tab outT outs i hb)
    (hread : c.σ.node I.read = I.fed) (hfed : c.σ.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map c.σ.node, p.2.map c.σ.node)) = outs)
    (hsread : s0.ffi.mlx.items.get I.read = none) (hpread : (s0.ffi.mlx.nodes.get I.read).isSome = true)
    (h1read : c.s1.ffi.mlx.items.get I.read = some (.ref 79)) (h1pread : (c.s1.ffi.mlx.nodes.get I.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hs1tok : c.s1.ffi.mlx.tokens = [])
    (h79 : nth? tab0 79 = some (.var 14))
    (hpout : (c.s1.ffi.mlx.nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → (c.s1.ffi.mlx.nodes.get j).isSome = true) :
    Sim.LoopGStepL (GxL M K env leaves typed I R L) c L ρ T tk toks i := by
  intro _ nx Mp Kc t Cs M1 t1 C1 hGx hst _ _ hhi hrun fr hext hend tab hle1
  have hle0 : Sim.CSrv.Le Cs ⟨tab⟩ := (Sim.runC_le c.n t Cs t1 C1 hrun).trans hle1
  have hG := hGx tab hle0
  have hnode : M1.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  -- the iteration's current state, lifted to the end
  obtain ⟨hs, htok, hchain, hcv, hcaps, hfedlt, hcb⟩ := hG.cur (by omega)
  have hcv1 : CacheValues M K env (Gr tab t1.ffi.mlx) (cachesAt M1.node I.caches) hs := by
    rw [hnode]; exact cacheValues_grows M K env _ _ _ _ hgrow _ hs hcb hcv
  have hprev1 : ∃ r, evalR M K env (Gr tab t1.ffi.mlx) (M1.node I.fed) = some r ∧
      itemUint32 r = some (R tab (L + i + 1) (by omega)).token.val := by
    obtain ⟨r, hr, hi⟩ := htok
    exact ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hfedlt _ hr, hi⟩
  have hpar1 : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (Gr tab t1.ffi.mlx) t.node = some (firstValues M K env tab t) := fun t ht =>
    evalR_grows M K env _ _ _ _ hgrow _ (hG.params t ht).2 _ (hG.params t ht).1
  have hnum : ∀ j e, nth? c.S1.tab j = some e → CSrv.val ⟨tab⟩ (M1.nv (.ref j)) = some
      (e.eval (Sim.valL ρ T tk L i nx)) := fun j e he => hle1.val (hend.srv.num j e he)
  have hrope : M1.big 5554869888 = 5554869888 :=
    hend.bigFixed _ (.inr (.inr ⟨by rw [hhi]; omega, by decide⟩))
  obtain ⟨next, hout, hnext, hcvn, hcapn⟩ := fwd tab _ M1 _ t1.ffi _ hend.ffi hPNL hPN0 rfl hnum hrope hs hchain hcaps
    hcv1 hprev1 hpar1
  -- the one popped readback: the value of time `L + i`, at the image of the readback slot
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped = [Mp.nv (.ref 79)] := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hs1tok] at hpe
    exact (List.append_left_inj _).mp hpe.symm
  subst hpop
  have hplen : ks.length ≤ 1 := hks
  have hslot1 : t1.ffi.mlx.items.get (M1.node I.read) = some (M1.nv (.ref 79)) := by
    rw [mr1.items I.read h1pread, h1read]; rfl
  have hslot0 : t.ffi.mlx.items.get (M1.node I.read) = none := by
    rw [hnode, mr0.items I.read hpread, hsread]; rfl
  have hks1 : M1.node I.read ∈ ks := by
    rcases hnewk _ _ hslot1 with h | ⟨_, h, _⟩
    · rw [hslot0] at h; cases h
    · exact h
  have hval : CSrv.val ⟨tab⟩ (Mp.nv (.ref 79)) = some (F64.ofNat (R tab (L + i) (by omega)).token.val) := by
    show CSrv.val ⟨tab⟩ (Mp.num 79) = _
    rw [hle0.val (hst.srv.num 79 _ h79)]
    show some (F64.ofNat (tk (i + 1))) = _
    rw [htk tab i (by omega)]
  exact gi_nextL M K env leaves typed I R L tab i M1.node c.σ.node t.ffi.mlx t1.ffi.mlx outT outs
    (by rw [hnode]; exact hG) hgrow fr.nnext hb
    (fun k v hk => by
      rcases hnewk k v hk with h | ⟨hx, hk', hv⟩
      · exact .inl h
      · refine .inr ⟨hx, mem_of_length_le_one hplen hks1 hk', ?_⟩
        rw [List.mem_singleton] at hv
        rw [hv]
        exact hval)
    mr1.yitems ⟨next, hout, hnext, hcvn, hcapn⟩ (mr1.nimg outT hpout)
    (cachesAt_below _ _ _ fun p hp j hj => mr1.nimg j (hpouts p hp j hj)) hread hfed hcaches

/-! ## The final case's conclusions -/

/-- **The conclusions at the halted end `tF` after a prompt of length `L`** (`GF`): the
forward result of every time `L … L + T - 1` and the memoized readbacks. -/
def GFL (R : RefRun M K env leaves typed) (L T : Nat) (tab : List F64) (tF : St Sim.LF.S) : Prop :=
  (∀ k (_ : L ≤ k) (_ : k ≤ L + T - 1) (hb : k ≤ 262144), ∃ cs out,
    ForwardAtR M K env leaves typed R tab k hb cs out (Gr tab tF.ffi.mlx)) ∧
  ReadbackValues M K env (CSrv.val ⟨tab⟩) (Gr tab tF.ffi.mlx) tF.ffi.mlx.items

/-- `GFL` with the last forward's result at the program's final caches (`GFC`). -/
def GFCL (R : RefRun M K env leaves typed) (L T : Nat) (tab : List F64) (tF : St Sim.LF.S) : Prop :=
  GFL M K env leaves typed R L T tab tF ∧
  ∀ hb : L + T - 1 ≤ 262144, ∃ cs out, cachesT tF (entryEnv Host.Load.Run.Full.P.s0) = some cs ∧
    ForwardAtR M K env leaves typed R tab (L + T - 1) hb cs out (Gr tab tF.ffi.mlx)

/-- **At `L = 1` with the existing reference, `GFL` is `GF`.** -/
theorem GFL_one (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))
    (T : Nat) (tab : List F64) (tF : St Sim.LF.S) :
    GFL M K env leaves typed (refPrompt1 M K env leaves typed parameters) 1 T tab tF ↔
      GF M K env leaves typed parameters T tab tF :=
  ⟨fun h => ⟨fun k h1 h2 hb => h.1 k h1 (by omega) hb, h.2⟩, fun h => ⟨fun k h1 h2 hb => h.1 k h1 (by omega) hb, h.2⟩⟩

/-- **At `L = 1` with the existing reference, `GFCL` is `GFC`.** -/
theorem GFCL_one (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))
    (T : Nat) (tab : List F64) (tF : St Sim.LF.S) :
    GFCL M K env leaves typed (refPrompt1 M K env leaves typed parameters) 1 T tab tF ↔
      GFC M K env leaves typed parameters T tab tF :=
  ⟨fun h => ⟨(GFL_one M K env leaves typed parameters T tab tF).1 h.1,
      forall_time (F := fun n hb => ∃ cs out, cachesT tF (entryEnv Host.Load.Run.Full.P.s0) = some cs ∧
        ForwardAtR M K env leaves typed (refPrompt1 M K env leaves typed parameters) tab n hb cs out
          (Gr tab tF.ffi.mlx)) (by omega) h.2⟩,
   fun h => ⟨(GFL_one M K env leaves typed parameters T tab tF).2 h.1,
      forall_time (F := fun n hb => ∃ cs out, cachesT tF (entryEnv Host.Load.Run.Full.P.s0) = some cs ∧
        ForwardAtR M K env leaves typed (refPrompt1 M K env leaves typed parameters) tab n hb cs out
          (Gr tab tF.ffi.mlx)) (by omega) h.2⟩⟩

/-- `GFCL_one` as an equality of the final goals. -/
theorem GFCL_one_eq (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed)) (T : Nat) :
    (fun (tF : St Sim.LF.S) (CF : CSrv) =>
      GFCL M K env leaves typed (refPrompt1 M K env leaves typed parameters) 1 T CF.tab tF) =
      fun tF CF => GFC M K env leaves typed parameters T CF.tab tF := by
  funext tF CF
  exact propext (GFCL_one M K env leaves typed parameters T CF.tab tF)

/-- **The final iteration's graph conclusions at a halt `sF`/`SF`** after a prompt of length `L`
(`fgstep_core_at`): `GFL` at the halt, and the time-`L + T - 1` forward result at the images of
the template start's carriers. -/
theorem fgstep_core_atL {s0 : St Sim.LF.S} {tab0 : List SymE} (sF : St Sim.LF.S) (SF : SSrv)
    (P : Sim.LoadP) (R : RefRun M K env leaves typed) (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat)
    (toks : List NumV) (I : TplInputs)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hT : 2 ≤ T) (hTb : L + T - 1 ≤ 262144) (hne : I.read ≠ I.fed)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hsB : s0.ffi.mlx.items.get I.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true) (hpB : (s0.ffi.mlx.nodes.get I.fed).isSome = true)
    (hfA : sF.ffi.mlx.items.get I.read = some (.ref 79))
    (hfB : sF.ffi.mlx.items.get I.fed = some (.ref tab0.length))
    (hpfA : (sF.ffi.mlx.nodes.get I.read).isSome = true) (hpfB : (sF.ffi.mlx.nodes.get I.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : sF.ffi.mlx.tokens = [])
    (h79 : nth? SF.tab 79 = some (.var 14)) (h17 : nth? SF.tab tab0.length = some (.var 17))
    (hlen : T - 2 < toks.length) (nx : Nat) (Mp : Sim.Map) (Kc : Sim.Ctx) (t : St Sim.LF.S) (Cs : CSrv)
    (MF : Sim.Map) (KF : Sim.Ctx) (tF : St Sim.LF.S) (CF : CSrv)
    (hGx : GxL M K env leaves typed I R L (T - 2) Mp t Cs)
    (hst : Sim.Rel Sim.LF (Sim.LR P (toks.drop (T - 2))) Mp (Sim.valL ρ T tk L (T - 2) nx) Kc s0 ⟨tab0, []⟩ t Cs)
    (n : Nat) (hrun : runC Sim.LF n t Cs = some (tF, CF)) (fr : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx)
    (hext : Sim.Ext (Mp.setNum tab0.length toks[T - 2]) MF (tab0.length + 1))
    (hend : Sim.Rel Sim.LF (Sim.LR P (toks.drop (T - 1))) MF (Sim.valL ρ T tk L (T - 2) (tk T)) KF sF SF tF CF) :
    GFL M K env leaves typed R L T CF.tab tF ∧
      ForwardAtR M K env leaves typed R CF.tab (L + T - 1) hTb (cachesAt MF.node I.caches) (MF.node I.fed)
        (Gr CF.tab tF.ffi.mlx) := by
  have hle : Sim.CSrv.Le Cs ⟨CF.tab⟩ := Sim.runC_le _ t Cs tF CF hrun
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  have hT2 : L + (T - 2) + 1 = L + T - 1 := by omega
  -- the popped readbacks
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 1) := by
    rw [List.drop_eq_getElem_cons hlen]
    congr 2
    omega
  have hpop : popped.length = 2 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok] at hpe
    have hpe' : Mp.nv (.ref 79) :: toks[T - 2] :: toks.drop (T - 1) = popped ++ toks.drop (T - 1) := by
      rw [← hdrop]; exact hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks2 : ks.length ≤ 2 := hpop ▸ hks
  have hslotA : tF.ffi.mlx.items.get (MF.node I.read) = some (MF.nv (.ref 79)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hslotB : tF.ffi.mlx.items.get (MF.node I.fed) = some (MF.nv (.ref tab0.length)) := by
    rw [mr1.items I.fed hpfB, hfB]; rfl
  have hfreshA : t.ffi.mlx.items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hfreshB : t.ffi.mlx.items.get (MF.node I.fed) = none := by
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
  -- the readback values
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref 79)) =
      some (F64.ofNat (R CF.tab (L + (T - 2)) (by omega)).token.val) := by
    have := hend.srv.num 79 _ h79
    change CSrv.val ⟨CF.tab⟩ (MF.num 79) = _
    rw [this]
    show some (F64.ofNat (tk (T - 2 + 1))) = _
    rw [htk CF.tab (T - 2) (by omega)]
  have hvB : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref tab0.length)) =
      some (F64.ofNat (R CF.tab (L + (T - 2) + 1) (by omega)).token.val) := by
    have := hend.srv.num tab0.length _ h17
    change CSrv.val ⟨CF.tab⟩ (MF.num tab0.length) = _
    rw [this]
    show some (F64.ofNat (tk T)) = _
    have e : tk T = (R CF.tab (L + (T - 1)) (by omega)).token.val := by
      have := htk CF.tab (T - 1) (by omega)
      rwa [show T - 1 + 1 = T by omega] at this
    rw [e, ref_token_congr M K env leaves typed R CF.tab (show L + (T - 1) = L + (T - 2) + 1 by omega)]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  rotate_left 2
  · obtain ⟨hs, htok, hh, hcv, _, hlt, hcb⟩ := hG.cur (by omega)
    rw [hnode]
    exact forwardAtR_time M K env leaves typed hT2 _ hTb
      (ForwardAtR.grow M K env leaves typed _ _ _ _ ⟨hs, htok, hh, hcv⟩ hgrow hlt hcb)
  · intro k h1 h2 hb
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega) hb
    exact ⟨cs, out, ForwardAtR.grow M K env leaves typed _ _ _ _ hf hgrow ho hc⟩
  · intro k v hk
    rcases hnewk k v hk with hx | ⟨_, hkk, _⟩
    · obtain ⟨token, htk', ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < (t.ffi : LSt).mlx.nnext := by
        by_contra hc
        cases (hG.reads.2 k (Nat.le_of_not_lt hc)).symm.trans hx
      exact ⟨token, htk', ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
    · rcases mem_of_length_le_two hks2 hinA hinB hneF hkk with rfl | rfl
      · rw [hslotA] at hk
        cases hk
        obtain ⟨cs, ⟨hs, ⟨r, hr, hi⟩, _, _⟩, hlt, _⟩ := hG.read (by omega)
        refine ⟨_, ?_, ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvA⟩
        have := (R CF.tab (L + (T - 2)) (by omega)).token.isLt
        omega
      · rw [hslotB] at hk
        cases hk
        obtain ⟨hs, ⟨r, hr, hi⟩, _, _, _, hlt, _⟩ := hG.cur (by omega)
        refine ⟨_, ?_, ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvB⟩
        have := (R CF.tab (L + (T - 2) + 1) (by omega)).token.isLt
        omega

/-- **A final case's graph step after a prompt of length `L`, with the program's final caches**
(`fgstepC_of`): the goal `GFCL`. -/
theorem fgstepC_ofL {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (fixA : List Nat) (fc : Sim.FinalCase okA okB s0 tab0 cE aN) (R : RefRun M K env leaves typed) (L : Nat)
    (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hT : 2 ≤ T) (hTb : L + T - 1 ≤ 262144)
    (hsA : s0.ffi.mlx.items.get tplInputs.read = none) (hsB : s0.ffi.mlx.items.get tplInputs.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hpB : (s0.ffi.mlx.nodes.get tplInputs.fed).isSome = true)
    (hfA : fc.sF.ffi.mlx.items.get tplInputs.read = some (.ref 79))
    (hfB : fc.sF.ffi.mlx.items.get tplInputs.fed = some (.ref tab0.length))
    (hpfA : (fc.sF.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hpfB : (fc.sF.ffi.mlx.nodes.get tplInputs.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : fc.sF.ffi.mlx.tokens = [])
    (h79 : nth? fc.SF.tab 79 = some (.var 14)) (h17 : nth? fc.SF.tab tab0.length = some (.var 17))
    (hc : Host.Load.Run.Tpl.cacheCell ∈ fixA)
    (hpres : (fc.sF.heap.get Host.Load.Run.Tpl.cacheCell).isSome = true) {aC : Nat}
    (hbind : bindingOf fc.sF (entryEnv Host.Load.Run.Full.P.s0) chars!"cache" = some (.obj aC))
    (hne : [2673447, 12502, aN].contains aC = false)
    (hok : cachesAllB fc.sF (entryEnv Host.Load.Run.Full.P.s0) cacheOkB = true) {cs : List Cache}
    (hcs : cachesT fc.sF (entryEnv Host.Load.Run.Full.P.s0) = some cs) (hn : cs.map nodePair = tplCaches) :
    Sim.FinalGStepL (GxL M K env leaves typed tplInputs R L) Sim.loadP0 fixA fc L ρ T tk toks
      (fun tF CF => GFCL M K env leaves typed R L T CF.tab tF) := by
  intro hlen nx Mp Kc t Cs MF KF tF CF hGx hfixA hst _ _ _ hrun fr hext _ _ hKF hend
  obtain ⟨hgf, hfwd⟩ := fgstep_core_atL M K env leaves typed fc.sF fc.SF Sim.loadP0 R L ρ T tk toks tplInputs htk hT
    hTb (by decide) hsA hsB hpA hpB hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen nx Mp Kc t Cs MF KF tF CF hGx hst _
    hrun fr hext hend
  have hfix : MF.a Host.Load.Run.Tpl.cacheCell = Host.Load.Run.Tpl.cacheCell := by
    rw [hext.a]; exact hfixA _ hc
  obtain ⟨cs', hcs', hn'⟩ := Host.Load.Run.Tpl.final_cache hend hfix hKF hpres hbind hne hok hcs hn
  refine ⟨hgf, fun hb => ⟨cs', _, hcs', forwardAtR_congr M K env leaves typed hfwd ?_⟩⟩
  rw [cachesAt_nodes]
  exact hn'.symm

/-- **An EOS final case's graph step after a prompt of length `L`** (`fgstepEC_of`): the goal
`GFCL`. -/
theorem fgstepEC_ofL {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (fixA : List Nat)
    (ec : Sim.ExitCase okA okB s0 (Sim.finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (R : RefRun M K env leaves typed) (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hT : 2 ≤ T) (hTb : L + T - 1 ≤ 262144)
    (hsA : s0.ffi.mlx.items.get tplInputs.read = none) (hsB : s0.ffi.mlx.items.get tplInputs.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hpB : (s0.ffi.mlx.nodes.get tplInputs.fed).isSome = true)
    (hfA : ec.sF.ffi.mlx.items.get tplInputs.read = some (.ref 79))
    (hfB : ec.sF.ffi.mlx.items.get tplInputs.fed = some (.ref tab0.length))
    (hpfA : (ec.sF.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hpfB : (ec.sF.ffi.mlx.nodes.get tplInputs.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : ec.sF.ffi.mlx.tokens = [])
    (h79 : nth? ec.SF.tab 79 = some (.var 14)) (h17 : nth? ec.SF.tab tab0.length = some (.var 17))
    (hc : Host.Load.Run.Tpl.cacheCell ∈ fixA)
    (hpres : (ec.sF.heap.get Host.Load.Run.Tpl.cacheCell).isSome = true) {aC : Nat}
    (hbind : bindingOf ec.sF (entryEnv Host.Load.Run.Full.P.s0) chars!"cache" = some (.obj aC))
    (hne : [2673447, 12502, aN].contains aC = false)
    (hok : cachesAllB ec.sF (entryEnv Host.Load.Run.Full.P.s0) cacheOkB = true) {cs : List Cache}
    (hcs : cachesT ec.sF (entryEnv Host.Load.Run.Full.P.s0) = some cs) (hn : cs.map nodePair = tplCaches) :
    Sim.FinalEGStepL (GxL M K env leaves typed tplInputs R L) Sim.loadP0 fixA ec L ρ T tk toks
      (fun tF CF => GFCL M K env leaves typed R L T CF.tab tF) := by
  intro hlen nx Mp Kc t Cs MF KF tF CF hGx hfixA hst _ _ _ hrun fr hext _ _ hKF hend
  obtain ⟨hgf, hfwd⟩ := fgstep_core_atL M K env leaves typed ec.sF ec.SF Sim.loadP0 R L ρ T tk toks tplInputs htk hT
    hTb (by decide) hsA hsB hpA hpB hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen nx Mp Kc t Cs MF KF tF CF hGx hst _
    hrun fr hext hend
  have hfix : MF.a Host.Load.Run.Tpl.cacheCell = Host.Load.Run.Tpl.cacheCell := by
    rw [hext.a]; exact hfixA _ hc
  obtain ⟨cs', hcs', hn'⟩ := Host.Load.Run.Tpl.final_cache hend hfix hKF hpres hbind hne hok hcs hn
  refine ⟨hgf, fun hb => ⟨cs', _, hcs', forwardAtR_congr M K env leaves typed hfwd ?_⟩⟩
  rw [cachesAt_nodes]
  exact hn'.symm

/-! ## EOS at a loop cut -/

/-- **The exit case's graph conclusions** after a prompt of length `L` (`egstep_core`): `GFL` at
the halt for times `L … L + i + 1`, and the time-`L + i + 1` forward result at the images of the
template start's carriers. -/
theorem egstep_coreL {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (P : Sim.LoadP) (ec : Sim.ExitCase okA okB s0 s0 tab0 cE aN []) (R : RefRun M K env leaves typed) (L : Nat)
    (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (I : TplInputs) (i : Nat)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hib : L + i + 1 ≤ 262144)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true)
    (hfA : ec.sF.ffi.mlx.items.get I.read = some (.ref 79))
    (hpfA : (ec.sF.ffi.mlx.nodes.get I.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : ec.sF.ffi.mlx.tokens = [])
    (h79 : nth? ec.SF.tab 79 = some (.var 14))
    (nx : Nat) (Mp : Sim.Map) (Kc : Sim.Ctx) (t : St Sim.LF.S) (Cs : CSrv)
    (MF : Sim.Map) (KF : Sim.Ctx) (tF : St Sim.LF.S) (CF : CSrv)
    (hGx : GxL M K env leaves typed I R L i Mp t Cs)
    (hst : Sim.Rel Sim.LF (Sim.LR P (toks.drop i)) Mp (Sim.valL ρ T tk L i nx) Kc s0 ⟨tab0, []⟩ t Cs)
    (n : Nat) (hrun : runC Sim.LF n t Cs = some (tF, CF)) (fr : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx)
    (hext : Sim.Ext Mp MF tab0.length)
    (hend : Sim.Rel Sim.LF (Sim.LR P (toks.drop i)) MF (Sim.valL ρ T tk L i nx) KF ec.sF ec.SF tF CF) :
    GFL M K env leaves typed R L (i + 2) CF.tab tF ∧
      ForwardAtR M K env leaves typed R CF.tab (L + i + 1) hib (cachesAt MF.node I.caches) (MF.node I.fed)
        (Gr CF.tab tF.ffi.mlx) := by
  have hle : Sim.CSrv.Le Cs ⟨CF.tab⟩ := Sim.runC_le _ t Cs tF CF hrun
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  -- the popped readback
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped.length = 1 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok] at hpe
    have hpe' : Mp.nv (.ref 79) :: toks.drop i = popped ++ toks.drop i := hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks1 : ks.length ≤ 1 := hpop ▸ hks
  have hslotA : tF.ffi.mlx.items.get (MF.node I.read) = some (MF.nv (.ref 79)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hfreshA : t.ffi.mlx.items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hinA : MF.node I.read ∈ ks := by
    rcases hnewk _ _ hslotA with h | ⟨_, h, _⟩
    · rw [hfreshA] at h; cases h
    · exact h
  -- the readback value: the cut's token
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref 79)) = some (F64.ofNat (R CF.tab (L + i) (by omega)).token.val) := by
    have := hend.srv.num 79 _ h79
    change CSrv.val ⟨CF.tab⟩ (MF.num 79) = _
    rw [this]
    show some (F64.ofNat (tk (i + 1))) = _
    rw [htk CF.tab i (by omega)]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · intro k h1 h2 hb
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega) hb
    exact ⟨cs, out, ForwardAtR.grow M K env leaves typed _ _ _ _ hf hgrow ho hc⟩
  · intro k v hk
    rcases hnewk k v hk with hx | ⟨_, hkk, _⟩
    · obtain ⟨token, htk', ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < (t.ffi : LSt).mlx.nnext := by
        by_contra hc
        cases (hG.reads.2 k (Nat.le_of_not_lt hc)).symm.trans hx
      exact ⟨token, htk', ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
    · obtain rfl := mem_of_length_le_one hks1 hinA hkk
      rw [hslotA] at hk
      cases hk
      obtain ⟨cs, ⟨hs, ⟨r, hr, hi⟩, _, _⟩, hlt, _⟩ := hG.read (by omega)
      refine ⟨_, ?_, ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvA⟩
      have := (R CF.tab (L + i) (by omega)).token.isLt
      omega
  · obtain ⟨hs, htok, hh, hcv, _, hlt, hcb⟩ := hG.cur hib
    rw [hnode]
    exact ForwardAtR.grow M K env leaves typed _ _ _ _ ⟨hs, htok, hh, hcv⟩ hgrow hlt hcb

/-- **The exit case's graph step after a prompt of length `L`, with the program's final caches**
(`egstepC_of`): the goal `GFCL (i + 2)`. -/
theorem egstepC_ofL {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (fixA : List Nat) (ec : Sim.ExitCase okA okB s0 s0 tab0 cE aN []) (R : RefRun M K env leaves typed) (L : Nat)
    (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (i : Nat)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hib : L + i + 1 ≤ 262144)
    (hsA : s0.ffi.mlx.items.get tplInputs.read = none)
    (hpA : (s0.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hfA : ec.sF.ffi.mlx.items.get tplInputs.read = some (.ref 79))
    (hpfA : (ec.sF.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : ec.sF.ffi.mlx.tokens = [])
    (h79 : nth? ec.SF.tab 79 = some (.var 14))
    (hc : Host.Load.Run.Tpl.cacheCell ∈ fixA)
    (hpres : (ec.sF.heap.get Host.Load.Run.Tpl.cacheCell).isSome = true) {aC : Nat}
    (hbind : bindingOf ec.sF (entryEnv Host.Load.Run.Full.P.s0) chars!"cache" = some (.obj aC))
    (hne : [2673447, 12502, aN].contains aC = false)
    (hok : cachesAllB ec.sF (entryEnv Host.Load.Run.Full.P.s0) cacheOkB = true) {cs : List Cache}
    (hcs : cachesT ec.sF (entryEnv Host.Load.Run.Full.P.s0) = some cs) (hn : cs.map nodePair = tplCaches) :
    Sim.ExitGStepL (GxL M K env leaves typed tplInputs R L) Sim.loadP0 fixA ec L ρ T tk toks i
      (fun tF CF => GFCL M K env leaves typed R L (i + 2) CF.tab tF) := by
  intro nx Mp Kc t Cs MF KF tF CF hGx hfixA hst _ _ _ hrun fr hext _ _ hKF hend
  obtain ⟨hgf, hfwd⟩ := egstep_coreL M K env leaves typed Sim.loadP0 ec R L ρ T tk toks tplInputs i htk hib
    hsA hpA hfA hpfA hs0tok hsFtok h79 nx Mp Kc t Cs MF KF tF CF hGx hst _ hrun fr hext hend
  have hfix : MF.a Host.Load.Run.Tpl.cacheCell = Host.Load.Run.Tpl.cacheCell := by
    rw [hext.a]; exact hfixA _ hc
  obtain ⟨cs', hcs', hn'⟩ := Host.Load.Run.Tpl.final_cache hend hfix hKF hpres hbind hne hok hcs hn
  refine ⟨hgf, fun hb => ⟨cs', _, hcs', forwardAtR_congr M K env leaves typed
    (forwardAtR_time M K env leaves typed (by omega) _ hb hfwd) ?_⟩⟩
  rw [cachesAt_nodes]
  exact hn'.symm

end Host.Mlx.SimGraph.Iter
