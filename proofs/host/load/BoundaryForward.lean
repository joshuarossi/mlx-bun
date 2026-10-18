import host.load.run.full.cached.Layout
import host.load.run.full.cached.Step
import host.load.CachedGrowthShapes

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

/-- A capacity-boundary graph consumes the incoming semantic cache and
device token. Its output capacity is proved from its producing operations,
so the next compatible feedback layout introduces no capacity assumption.
Entry reachability and transporting these incoming invariants remain the
responsibility of the source loop theorem. -/
theorem boundary_cached_forward (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (time : Nat) (supported : time + 1 ≤ 262144) (native : Host.Mlx.Ffi.St)
    (before : Loaded) (afterCache : List Cache) (token : Tensor) (ids : Value)
    (hs : List Handles) (E : List (RNode Int InKey)) (expectedToken : Nat)
    (expectedCaches : List (Nat × Nat)) (cert : List Nat) (outputNode outputCapacity : Nat)
    (hmodel : before.model = parameterChoice.model)
    (parameterValues : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) t.node =
        some (firstValues M K env table t))
    (classes : List.Forall₂ CacheClassMatches (stageWeights (weights (firstValues M K env table))) before.cache)
    (nextClasses : List.Forall₂ CacheClassMatches (stageWeights (weights (firstValues M K env table))) afterCache)
    (beforeShapes : CachedGrowthShapes.checkCaches
      (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) .bfloat16 256 12 before.cache = true)
    (afterShapes : CachedGrowthShapes.checkCaches
      (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) .bfloat16 outputCapacity 12 afterCache = true)
    (original : stepGraph Cached.Expected2.stages Cached.Expected2.head time = (E,expectedToken,expectedCaches))
    (matched : Matches (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) E cert = true)
    (inputs : inputCarriersMatch E cert (inputNode before token) = true)
    (outputs : afterCache.map (fun c => (c.first.map Tensor.node,c.second.map Tensor.node)) =
      expectedCaches.map (fun (a,b) => (some (certAt cert a),some (certAt cert b))))
    (tokenOutput : certAt cert expectedToken = outputNode)
    (chain : ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs
      ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).cache)
    (caches : CacheValues M K env
      (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) before.cache hs)
    (buffer : TokenBuffer ids
      ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.val)
    (tokenValue : evalR M K env (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) token.node = some ids) :
    let after := (firstContext M K env table leaves typed parameters).run promptToken (time+1) supported
    ∃ next, (∃ r, evalR M K env
        (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) outputNode = some r ∧
        itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages next after.cache ∧
      CacheValues M K env (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native) afterCache next ∧
      List.Forall₂ CacheCompatible (stageWeights (weights (firstValues M K env table))) next ∧
      chainLayout (stageWeights (weights (firstValues M K env table))) next =
        chainLayout (stageWeights (weights (firstValues M K env table))) (populatedLayoutHandles outputCapacity) := by
  let G := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources native
  let p := firstPipeline M K env table leaves typed
  let w := weights (firstValues M K env table)
  have loaded := stages_loaded M K p w (firstPipeline_loaded M K env table leaves typed)
  have compatible := cacheCompatible_of_holds M K p.graph.stages (stageWeights w) hs _ loaded chain
  have beforeShapeValues := CachedGrowthShapes.caches_sound M K env G .bfloat16 256 12 before.cache beforeShapes
  have layout := Cached.populated_step_graph M K env G (contents M K env (firstFfiGraph table))
    before.cache hs caches compatible classes (fun c hc hop t ht v hv => (beforeShapeValues c hc hop t ht v hv).2) time
  change stepGraphOf w hs time = _ at layout
  rw [original] at layout
  have hm : Matches G (stepGraphOf w hs time).1 cert = true := by rw [layout]; exact matched
  have hin : inputCarriersMatch (stepGraphOf w hs time).1 cert (inputNode before token) = true := by
    rw [layout]; exact inputs
  have hout : afterCache.map (fun c => (c.first.map Tensor.node,c.second.map Tensor.node)) =
      (stepGraphOf w hs time).2.2.map (fun (a,b) => (some (certAt cert a),some (certAt cert b))) := by
    rw [layout]; exact outputs
  obtain ⟨next,tokenResult,nextChain,nextValues⟩ := Cached.cached_decode_from_values M K env table leaves typed
    parameters time supported native before token ids hs afterCache cert hmodel parameterValues
    chain caches buffer tokenValue hm hin hout
  have nextCompatible := cacheCompatible_of_holds M K p.graph.stages (stageWeights w) next _ loaded nextChain
  have afterShapeValues := CachedGrowthShapes.caches_sound M K env G .bfloat16 outputCapacity 12 afterCache afterShapes
  have nextLayout := cached_stage_layout M K env G (contents M K env (firstFfiGraph table))
    afterCache next outputCapacity nextValues nextCompatible nextClasses
    (fun c hc hop t ht v hv => (afterShapeValues c hc hop t ht v hv).2)
  refine ⟨next,?_,nextChain,nextValues,nextCompatible,nextLayout⟩
  rw [layout,tokenOutput] at tokenResult
  exact tokenResult

end Host.Load.Run.Full
