import host.load.run.full.cached.Shapes
import host.load.run.full.cached.FinalGraph
import host.load.run.full.cached.Result
import host.load.CacheCarriersCommand
import host.simgraph.Forward
namespace Host.Mlx.SimGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Full.Cached Host.Load.CachedShapes
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option maxRecDepth 1000000

/-! # The iteration's other premises

* `capsFor_of_values`: caches carried by graph nodes of the route's shapes
  have a uniform capacity (`CapsFor`). `caps_first`: the first cached
  step's caches (the prompt step's outputs) are at capacity 256.
* `parameter_values_extend`: every native state that keeps the load
  program's nodes and the route's kernel objects evaluates the parameter
  tensors to the checkpoint values (no equality of kernel tables needed).
* `outputs_of_template`: the iteration's output-carrier premise from the
  template's carrier check and the iteration map on cache tensors. -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

/-! ## Uniform capacity of carried caches -/

theorem capsFor_of_values (G : Nat → Option (RNode Int InKey)) (c : Nat) (ws : List StageWeights)
    (cs : List Cache) (hs : List Handles) (values : CacheValues M K env G cs hs)
    (compatible : List.Forall₂ CacheCompatible ws hs) (classes : List.Forall₂ CacheClassMatches ws cs)
    (shapes : ∀ cc ∈ cs, cc.operation = chars!"KVCache" → ∀ t, cc.first = some t ∨ cc.second = some t →
      ∀ v, evalR M K env G t.node = some v → v.shape = [1, 4, c, 256]) :
    CapsFor c ws hs := by
  induction compatible generalizing cs with
  | nil => exact .nil
  | @cons w h ws hs hc rest ih =>
    cases classes with
    | @cons _ cc _ cs hcl classes =>
      cases values with
      | cons hv values =>
        obtain ⟨ta, tb, a, b, hfirst, hsecond, hvals, ha, hb⟩ := hv
        refine .cons ?_ (ih cs values classes fun cc' hm => shapes cc' (List.mem_cons_of_mem _ hm))
        cases w with
        | delta _ =>
          cases h with
          | attention _ _ => exact hc.elim
          | delta conv rec =>
            cases conv <;> cases rec <;> simp [handleVals] at hvals
            trivial
        | attention _ =>
          cases h with
          | delta _ _ => exact hc.elim
          | attention kb vb =>
            cases kb with
            | none => simp [handleVals] at hvals
            | some x =>
              cases vb with
              | none => simp [handleVals] at hvals
              | some y =>
                simp only [handleVals, Option.some.injEq, Prod.mk.injEq] at hvals
                obtain ⟨h1, h2⟩ := hvals
                have hop : cc.operation = chars!"KVCache" := hcl
                exact ⟨by rw [h1]; exact shapes cc (List.mem_cons_self ..) hop ta (.inl hfirst) a ha,
                  by rw [h2]; exact shapes cc (List.mem_cons_self ..) hop tb (.inr hsecond) b hb⟩

/-- **The base case**: the caches the first cached step reads are at capacity 256. -/
theorem caps_first (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) (hs : List Handles)
    (chain : ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs
      ((firstContext M K env table leaves typed parameters).run promptToken 1 (by decide)).cache)
    (caches : CacheValues M K env (terminalGraph table) firstChoice.cache hs) :
    CapsFor 256 (stageWeights (weights (firstValues M K env table))) hs := by
  have compatible := cacheCompatible_of_holds M K _ _ hs _
    (stages_loaded M K _ _ (firstPipeline_loaded M K env table leaves typed)) chain
  have shapes := caches_sound M K env (terminalGraph table) .bfloat16 [1,4,256,256] 6 firstChoice.cache
    (cache_shapes_checked1 table)
  exact capsFor_of_values M K env (terminalGraph table) 256 _ _ hs caches compatible
    (cache_classes1 (contents M K env (firstFfiGraph table)))
    (fun cc hc hop t ht v hv => (shapes cc hc hop t ht v hv).2)

/-- The time-1 forward result with its uniform capacity. -/
theorem forward_first_caps (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed)) (outputNode : Nat)
    (h : ForwardResult M K env table leaves typed parameters 1 (by decide) firstChoice.cache outputNode) :
    ∃ hs, ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs
        ((firstContext M K env table leaves typed parameters).run promptToken 1 (by decide)).cache ∧
      CacheValues M K env (terminalGraph table) firstChoice.cache hs ∧
      CapsFor 256 (stageWeights (weights (firstValues M K env table))) hs := by
  obtain ⟨hs, _, hh, hc⟩ := h
  exact ⟨hs, hh, hc, caps_first M K env table leaves typed parameters hs hh hc⟩

/-! ## Parameter values in later native states -/

theorem renameN_id {κ : Type} (r : RNode Int κ) : renameN (fun i => i) (fun h => h) r = r := by
  obtain ⟨p, ins⟩ := r
  have : ∀ q : RPrim Int κ, renameCls (fun h => h) q = q := by
    intro q; induction q <;> simp_all [renameCls]
  simp [renameN, this]

/-- Resolution in a state with the same node and a kernel table extending the old one's. -/
theorem resolveNode_kernels (N : Nums Int) (kn kn' : Nat → Option (List Char))
    (hk : ∀ k name, kn k = some name → kn' k = some name) (nd : Host.Mlx.Ffi.Node) (r : RNode Int InKey)
    (hr : resolveNode N kn nd = some r) : resolveNode N kn' nd = some r := by
  have ha : Agree N N (fun i => i) SynImg.id kn kn' (fun _ => True) :=
    ⟨fun _ _ h => h, fun _ _ h => h, fun _ _ h => h, fun _ _ h => h, fun _ _ _ h => h, hk⟩
  have hA : ∀ p, PrimArgs (fun _ => True) p := by
    intro p; induction p <;> simp_all [PrimArgs]
  have h := resolveNode_img ha (fun i => i) nd r (hA _) hr
  have hnd : nodeI (fun i => i) SynImg.id nd = nd := by rw [nodeI, primI_id]; simp [SynImg.id]
  rw [hnd, mapN_id] at h
  exact h.trans (congrArg some (renameN_id r))

/-- **Parameter values in any later native state** that keeps the nodes the
parameter tensors are computed from and every route kernel object. -/
theorem parameter_values_extend (leaves : Leaves code env.weights) (native : Host.Mlx.Ffi.St)
    (preserved : ∀ t ∈ parameterTensors parameterChoice, ∀ j ≤ t.node,
      native.nodes.get j = firstChoice.graph.nodes.get j)
    (kernels : ∀ k name, kernelName? SourceKernels.sources firstChoice.graph k = some name →
      kernelName? SourceKernels.sources native k = some name) :
    ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) t.node =
        some (firstValues M K env table t) := by
  intro t ht
  let G := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources firstChoice.graph
  let G' := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native
  let B : Nat → Option (RNode Int InKey) := fun j => if j ≤ t.node then G j else none
  have old := parameter_evaluated M K env (firstFfiGraph table) leaves
    (first_load_matches table SourceKernels.sources) t ht
  have hB : evalR M K env B t.node = evalR M K env G t.node :=
    evalR_prefix M K env B G t.node fun j hj => by simp only [B, hj, ↓reduceIte]
  have emb : Embeds (fun i => i) (fun h => h) B G' := by
    refine ⟨fun j r hr => ?_, fun _ _ _ h => h⟩
    have hj : j ≤ t.node := by
      by_contra hj; simp [B, hj] at hr
    simp only [B, hj, ↓reduceIte] at hr
    obtain ⟨nd, hnd, hres⟩ := Option.bind_eq_some_iff.mp hr
    show (native.nodes.get j).bind _ = _
    rw [preserved t ht j hj, hnd, Option.bind_some, renameN_id]
    exact resolveNode_kernels _ _ _ kernels nd r hres
  exact evalR_embed M K env B G' emb t.node _ (hB.trans old)

/-! ## Output carriers -/

/-- **The iteration's cache outputs** are the template's carriers renamed:
the template's own carrier check (`load_cache_carriers` on the template's
next caches and `(templateOf …).2.2`) and the iteration map on cache tensors
give the output premise of `template_cached_forward`. -/
theorem outputs_of_template (cert : List Nat) (ps : List (Nat × Nat)) (templateCache nextCache : List Cache)
    (σ : Nat → Nat) (template : templateCache.map cacheNodePair = ps.map (certifiedCachePair cert))
    (renamed : nextCache.map cacheNodePair =
      templateCache.map fun c => ((cacheNodePair c).1.map σ, (cacheNodePair c).2.map σ)) :
    nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      ps.map (fun (a, b) => (some (σ (certAt cert a)), some (σ (certAt cert b)))) := by
  have h : nextCache.map cacheNodePair =
      (templateCache.map cacheNodePair).map fun p => (p.1.map σ, p.2.map σ) := by
    rw [renamed, List.map_map]; rfl
  rw [template, List.map_map] at h
  exact h

end Host.Mlx.SimGraph
