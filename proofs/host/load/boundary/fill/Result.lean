import host.load.boundary.fill.Execution
import host.load.boundary.fill.Forward
import host.load.run.full.SourceInitialization
namespace Host.Load.Run.Full.Fill64
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen
set_option Elab.async false
set_option maxRecDepth 1000000

noncomputable def sourceTable (ρ : Nat → F64) : List F64 := S1491.tab.map (SymE.eval ρ)

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey)

/-- Source execution and mathematical feedback share the same returned heap,
native graph and concrete numeric table. Future-entry reachability and the
incoming semantic cache/token remain explicit caller obligations. -/
theorem source_cached_forward (ρ : Nat → F64) (initial : CSrv)
    (table : initial.tab = S0.tab.map (SymE.eval ρ))
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env (sourceTable ρ) leaves typed))
    (ids : Value) (hs : List Handles)
    (chain : ChainHolds (firstPipeline M K env (sourceTable ρ) leaves typed).graph.stages hs
      ((firstContext M K env (sourceTable ρ) leaves typed parameters).run promptToken 255 (by decide)).cache)
    (caches : CacheValues M K env (graph (sourceTable ρ)) before.cache hs)
    (buffer : TokenBuffer ids
      ((firstContext M K env (sourceTable ρ) leaves typed parameters).run promptToken 255 (by decide)).token.val)
    (tokenValue : evalR M K env (graph (sourceTable ρ)) inputToken.node = some ids) :
    let next := (firstContext M K env (sourceTable ρ) leaves typed parameters).run promptToken 256 (by decide)
    ∃ out, runC Host.Load.ffi 1490133 entry initial = some (s1491,⟨sourceTable ρ⟩) ∧
      Extract.loaded s1491 (entryEnv P.s0) = some after ∧
      firstPipeline M K env (sourceTable ρ) leaves typed = initialPipeline M K env [] leaves typed ∧
      ((s1491.cell? 2673320).join.bind (Extract.tensor s1491)).map Tensor.node = some 24887 ∧
      (∃ r, evalR M K env (graph (sourceTable ρ)) 24887 = some r ∧ itemUint32 r = some next.token.val) ∧
      ChainHolds (firstPipeline M K env (sourceTable ρ) leaves typed).graph.stages out next.cache ∧
      CacheValues M K env (graph (sourceTable ρ)) after.cache out ∧
      List.Forall₂ CacheCompatible (stageWeights (weights (firstValues M K env (sourceTable ρ)))) out ∧
      chainLayout (stageWeights (weights (firstValues M K env (sourceTable ρ)))) out =
        chainLayout (stageWeights (weights (firstValues M K env (sourceTable ρ)))) (populatedLayoutHandles 256) := by
  obtain ⟨server,executed,finalTable⟩ := fragment_execution ρ initial table
  have serverEq : server = ⟨sourceTable ρ⟩ := by
    cases server with
    | mk values => exact congrArg CSrv.mk finalTable
  subst server
  obtain ⟨out,read,nextChain,nextCache,compatible,layout⟩ := cached_forward M K env (sourceTable ρ)
    leaves typed parameters ids hs chain caches buffer tokenValue
  exact ⟨out,executed,after_checked.matches,
    (initial_pipeline_first M K env [] (sourceTable ρ) leaves typed).symm,
    selected_lookahead_node,read,nextChain,nextCache,compatible,layout⟩
end Host.Load.Run.Full.Fill64
