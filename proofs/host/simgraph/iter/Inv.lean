import host.simgraph.Forward
import host.simgraph.Grow
import host.mlx.ReadbackValues
import host.load.run.full.RecurrenceReadbacks
import host.sim.Free
import host.load.CacheCarriersCommand
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference.Models.Qwen

/-! # The graph invariant of the decode loop

At the start of iteration `i` (time `i + 2`) the target's native graph, read at any
server table `tab` extending the current one, carries:

* `hist`: the forward result of every time `1 … i + 2`;
* `read`: the result of time `i + 1` at the image of the template node `20157`, which
  the iteration reads back;
* `cur`: the result of time `i + 2` at the image of the template node `22538` (the
  token fed to this iteration), with the caches at the images of the template's cache
  inputs, their chain facts and their uniform capacity `cap i`;
* `params`: the checkpoint parameter values;
* `reads`: every memoized readback is the value of its node.

The iteration's inputs are built from the template's carriers (`loadedAt`,
`tokenAt`): only their nodes enter the graph side, so no extraction from the
target's heap is needed. -/

/-- A tensor at node `n` (its handle and recorded node are not read by the graph side). -/
def tensorAt (n : Nat) : Tensor := ⟨0, n, ⟨.zeros, [], [], 0⟩⟩

/-- A cache whose tensors are at the nodes `p` under `σ`. -/
def cacheAt (σ : Nat → Nat) (p : Option Nat × Option Nat) : Cache :=
  ⟨[], 0, p.1.map fun j => tensorAt (σ j), p.2.map fun j => tensorAt (σ j)⟩

def cachesAt (σ : Nat → Nat) (ps : List (Option Nat × Option Nat)) : List Cache := ps.map (cacheAt σ)

theorem cachesAt_nodes (σ : Nat → Nat) (ps : List (Option Nat × Option Nat)) :
    (cachesAt σ ps).map cacheNodePair = ps.map fun p => (p.1.map σ, p.2.map σ) := by
  simp only [cachesAt, List.map_map]
  congr 1
  funext p
  simp [cacheNodePair, cacheAt, tensorAt, Option.map_map, Function.comp_def]

theorem cachesAt_comp (σ τ : Nat → Nat) (ps : List (Option Nat × Option Nat)) :
    cachesAt σ (ps.map fun p => (p.1.map τ, p.2.map τ)) = cachesAt (fun j => σ (τ j)) ps := by
  simp only [cachesAt, List.map_map]
  congr 1
  funext p
  simp [cacheAt, Option.map_map, Function.comp_def]

/-- The iteration's loaded inputs: the run's model and the caches at `ps` under `σ`. -/
def loadedAt (σ : Nat → Nat) (ps : List (Option Nat × Option Nat)) : Loaded :=
  ⟨parameterChoice.model, cachesAt σ ps⟩

/-- Cache tensors below a node bound. -/
def CachesBelow (cs : List Cache) (b : Nat) : Prop :=
  ∀ c ∈ cs, ∀ t, (c.first = some t ∨ c.second = some t) → t.node < b

theorem cachesAt_below (σ : Nat → Nat) (ps : List (Option Nat × Option Nat)) (b : Nat)
    (h : ∀ p ∈ ps, ∀ j, (p.1 = some j ∨ p.2 = some j) → σ j < b) : CachesBelow (cachesAt σ ps) b := by
  intro c hc t ht
  obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hc
  rcases ht with ht | ht
  · obtain ⟨j, hj, rfl⟩ := Option.map_eq_some_iff.mp ht
    exact h p hp j (.inl hj)
  · obtain ⟨j, hj, rfl⟩ := Option.map_eq_some_iff.mp ht
    exact h p hp j (.inr hj)

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- `ForwardResult` on the native graph `G` (the five-token development's `ForwardResult`
is this on its terminal graph). -/
def ForwardAt (table : List F64) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (time : Nat) (supported : time ≤ 262144) (sourceCaches : List Cache) (outputNode : Nat)
    (G : Nat → Option (RNode Int InKey)) : Prop :=
  let after := (firstContext M K env table leaves typed parameters).run promptToken time supported
  ∃ hs, (∃ r, evalR M K env G outputNode = some r ∧ itemUint32 r = some after.token.val) ∧
    ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs after.cache ∧
    CacheValues M K env G sourceCaches hs

/-- **Lift along growth.** -/
theorem ForwardAt.grow {table : List F64} {parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)}
    {time : Nat} {supported : time ≤ 262144} {cs : List Cache} {out : Nat} (N : Nums Int) (Ks : KernelSources)
    (s s' : Ffi.St) (h : ForwardAt M K env table leaves typed parameters time supported cs out (ffiGraph N Ks s))
    (hg : Grows Ks s s') (hout : out < s.nnext) (hlt : CachesBelow cs s.nnext) :
    ForwardAt M K env table leaves typed parameters time supported cs out (ffiGraph N Ks s') := by
  obtain ⟨hs, ⟨r, hr, ht⟩, hh, hc⟩ := h
  exact ⟨hs, ⟨r, evalR_grows M K env N Ks s s' hg out hout r hr, ht⟩, hh,
    cacheValues_grows M K env N Ks s s' hg cs hs hlt hc⟩

/-- The target's graph read at table `tab`. -/
noncomputable abbrev Gr (tab : List F64) (x : Ffi.St) : Nat → Option (RNode Int InKey) :=
  ffiGraph (κ := InKey) (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources x

/-- The parameters at table `tab`. -/
noncomputable abbrev hpOf (tab : List F64) := parameters_for_table M K env leaves typed parameters tab

/-- The KV capacity at iteration `i` (time `i + 2`), as `Host.Ts.Sim.cap`. -/
def capOf (i : Nat) : Nat := 256 * ((i + 1) / 256 + 1)

/-- The template start's cache input nodes (64 pairs) and its two token nodes. -/
structure TplInputs where
  caches : List (Option Nat × Option Nat)
  read : Nat
  fed : Nat

/-- **The invariant at iteration `i`**, at table `tab`, for the target native state `x`
under the node map `σ`. -/
structure GI (I : TplInputs) (tab : List F64) (i : Nat) (σ : Nat → Nat) (x : Ffi.St) : Prop where
  hist : ∀ k (h1 : 1 ≤ k) (h2 : k ≤ i + 2) (hb : k ≤ 262144), ∃ cs out,
    ForwardAt M K env tab leaves typed (hpOf M K env leaves typed parameters tab) k hb cs out (Gr tab x) ∧
      out < x.nnext ∧ CachesBelow cs x.nnext
  read : ∀ (hb : i + 1 ≤ 262144), ∃ cs,
    ForwardAt M K env tab leaves typed (hpOf M K env leaves typed parameters tab) (i + 1) hb cs (σ I.read) (Gr tab x) ∧
      σ I.read < x.nnext ∧ CachesBelow cs x.nnext
  cur : ∀ (hb : i + 2 ≤ 262144), ∃ hs,
    (∃ r, evalR M K env (Gr tab x) (σ I.fed) = some r ∧
      itemUint32 r = some ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
        promptToken (i + 2) hb).token.val) ∧
    ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs
      ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run promptToken (i + 2) hb).cache ∧
    CacheValues M K env (Gr tab x) (cachesAt σ I.caches) hs ∧
    CapsFor (capOf i) (stageWeights (weights (firstValues M K env tab))) hs ∧
    σ I.fed < x.nnext ∧ CachesBelow (cachesAt σ I.caches) x.nnext
  params : ∀ t ∈ parameterTensors parameterChoice, evalR M K env (Gr tab x) t.node = some (firstValues M K env tab t) ∧
    t.node < x.nnext
  reads : ReadbackValues M K env (CSrv.val ⟨tab⟩) (Gr tab x) x.items ∧ ∀ k, x.nnext ≤ k → x.items.get k = none

/-- **The loop's graph invariant** (`LoopInv`'s `Gx`): at every table extending the
current server's, below the context bound. -/
def Gx (I : TplInputs) (i : Nat) (Mp : Host.Ts.Sim.Map) (t : St Host.Load.LSt) (Cs : CSrv) : Prop :=
  ∀ tab, Host.Ts.Sim.CSrv.Le Cs ⟨tab⟩ → GI M K env leaves typed parameters I tab i Mp.node t.ffi.mlx

/-- **One iteration of the invariant.** From the invariant at iteration `i` under the
node map `σ`, a target run that only grows the graph and memoizes one new readback (the
template's readback node's image, with the value of time `i + 1`), and the iteration's
forward result at the image of the template's output node `outT` with the next caches
at the images of `outs`, the invariant holds at `i + 1` under `σ ∘ σT`, where the
restart map `σT` sends the read node to the fed node, the fed node to `outT` and the
cache inputs to `outs`. -/
theorem gi_next (I : TplInputs) (tab : List F64) (i : Nat) (σ σT : Nat → Nat) (x x1 : Ffi.St)
    (outT : Nat) (outs : List (Option Nat × Option Nat))
    (hG : GI M K env leaves typed parameters I tab i σ x)
    (hgrow : Grows SourceKernels.sources x x1) (hn : x.nnext ≤ x1.nnext)
    (hb : i + 3 ≤ 262144)
    (hnew : ∀ k v, x1.items.get k = some v → x.items.get k = some v ∨ (x.items.get k = none ∧ k = σ I.read ∧
      CSrv.val ⟨tab⟩ v = some (F64.ofNat ((firstContext M K env tab leaves typed
        (hpOf M K env leaves typed parameters tab)).run promptToken (i + 1) (by omega)).token.val)))
    (hyitems : ∀ k, x1.nnext ≤ k → x1.items.get k = none)
    (hfwd : ∃ next, (∃ r, evalR M K env (Gr tab x1) (σ outT) = some r ∧
        itemUint32 r = some ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
          promptToken (i + 3) hb).token.val) ∧
      ChainHolds (firstPipeline M K env tab leaves typed).graph.stages next
        ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run promptToken (i + 3) hb).cache ∧
      CacheValues M K env (Gr tab x1) (cachesAt σ outs) next ∧
      CapsFor (capOf (i + 1)) (stageWeights (weights (firstValues M K env tab))) next)
    (hout : σ outT < x1.nnext) (houts : CachesBelow (cachesAt σ outs) x1.nnext)
    (hread : σT I.read = I.fed) (hfed : σT I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map σT, p.2.map σT)) = outs) :
    GI M K env leaves typed parameters I tab (i + 1) (fun j => σ (σT j)) x1 where
  hist := by
    intro k h1 h2 hk
    by_cases hk2 : k ≤ i + 2
    · obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 hk2 hk
      refine ⟨cs, out, ForwardAt.grow M K env leaves typed _ _ _ _ hf hgrow ho hc, by omega, ?_⟩
      intro c hc' t ht; have := hc c hc' t ht; omega
    · have hk3 : k = i + 3 := by omega
      subst hk3
      obtain ⟨next, htok, hh, hc, _⟩ := hfwd
      exact ⟨cachesAt σ outs, σ outT, ⟨next, htok, hh, hc⟩, hout, houts⟩
  read := by
    intro hb'
    obtain ⟨hs, htok, hh, hc, _, hf, hcb⟩ := hG.cur (by omega)
    refine ⟨cachesAt σ I.caches, ?_, ?_, ?_⟩
    · simp only [hread]
      exact ForwardAt.grow M K env leaves typed _ _ _ _ ⟨hs, htok, hh, hc⟩ hgrow hf hcb
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
      have := ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
        promptToken (i + 1) (by omega)).token.isLt
      omega

end Host.Mlx.SimGraph.Iter
