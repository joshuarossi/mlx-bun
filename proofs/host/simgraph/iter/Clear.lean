import host.simgraph.iter.ClearGraph
import host.simgraph.Forward
import host.load.run.full.CachedLayout
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter.Clear
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Full.Cached
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Load.Run.Tpl (CLEAR.s150 CLEAR.S150)
open Inference.Models.Qwen

/-! # One CLEAR iteration of the checkpoint's pipeline

`graph_iter` at the checkpoint's weights, composed with
`template_cached_forward`: the next token at the iteration's output node,
`ChainHolds`/`CacheValues` of the next caches, and their capacity. -/

theorem capsFor_populated (c : Nat) : ∀ ws : List StageWeights, CapsFor c ws (populatedHandlesFor ws c)
  | [] => .nil
  | .delta _ :: ws => .cons trivial (capsFor_populated c ws)
  | .attention _ :: ws => .cons ⟨rfl, rfl⟩ (capsFor_populated c ws)

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)

theorem layout_eq : chainLayout (stageWeights (weights (firstValues M K env table))) (populatedLayoutHandles 256) =
    Expected2.stages := by
  change chainLayout (stageWeights (weights (headerValues (contents M K env (firstFfiGraph table)))))
    (populatedLayoutHandles 256) = _
  rfl

theorem head_eq : linLayout .affineRow (weights (firstValues M K env table)).head = Expected2.head := by
  change linLayout .affineRow (weights (headerValues (contents M K env (firstFfiGraph table)))).head = _
  rfl

theorem caps_eq : CapsFor 256 (stageWeights (weights (firstValues M K env table))) (populatedLayoutHandles 256) := by
  rw [← populatedHandlesFor_loaded (contents M K env (firstFfiGraph table)) 256]
  exact capsFor_populated 256 _

/-- **One CLEAR iteration.** -/
theorem forward_iter (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (time : Nat) (supported : time + 1 ≤ 262144)
    (P : Sim.LoadP) (Mp : Sim.Map) (n : Nat) (y : LSt)
    (hR : Sim.LoadR P Mp n CLEAR.s150.ffi y) (hNL : NL ≤ P.NL) (hN0 : P.N0 ≤ N0)
    (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat time)
    (hnum : ∀ i e, nth? CLEAR.S150.tab i = some e → CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (l : Loaded) (token : Tensor) (hs : List Handles) (nextCache : List Cache) (c : Nat)
    (caps : CapsFor c (stageWeights (weights (firstValues M K env table))) hs) (interior : time + 1 < c)
    (hin : ∀ key j, insT key = some j → inputNode l token key = some (Mp.node j))
    (hout : nextCache.map cacheNodePair = choice.outputs.map fun p => (p.1.map Mp.node, p.2.map Mp.node))
    (hmodel : l.model = parameterChoice.model)
    (parameterValues : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx) t.node =
        some (firstValues M K env table t))
    (chain : ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs
      ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).cache)
    (caches : CacheValues M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx)
      l.cache hs)
    (previous : ∃ r, evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx)
        (Mp.node 22538) = some r ∧
      itemUint32 r = some ((firstContext M K env table leaves typed parameters).run promptToken time (by omega)).token.val) :
    let after := (firstContext M K env table leaves typed parameters).run promptToken (time + 1) supported
    ∃ next, (∃ r, evalR M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx)
        (Mp.node (certAt choice.cert Tpl.Ordinary.tokenNode)) = some r ∧ itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages next after.cache ∧
      CacheValues M K env (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx) nextCache next ∧
      CapsFor c (stageWeights (weights (firstValues M K env table))) next := by
  obtain ⟨emb, hbranch, hfeed, hearlier, houts, hinputs, htok⟩ :=
    graph_iter _ _ (caps_eq M K env table) (layout_eq M K env table) (head_eq M K env table) table P Mp n y hR hNL hN0
      ρ time hρ (by omega) hnum hrope l token hs nextCache c caps interior hin hout
  obtain ⟨next, ht, hh, hc, hcaps⟩ := template_cached_forward M K env table leaves typed parameters time supported
    y.mlx l token (Mp.node 22538) _ hs nextCache c _ Mp.node Mp.handle hmodel parameterValues chain caps
    hbranch caches hfeed hearlier previous emb hinputs houts rfl
  refine ⟨next, ?_, hh, hc, by rwa [kvCap_interior c time interior] at hcaps⟩
  rw [htok] at ht
  exact ht

end Host.Mlx.SimGraph.Iter.Clear
