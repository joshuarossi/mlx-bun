import host.load.run.full.ParameterEquality
import host.load.run.full.WeightsEquality
import host.load.run.full.FirstStep
set_option Elab.async false

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Load.Program Host.Mlx Host.Mlx.FfiEval Host.Ts
open Inference.Models.Qwen

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : Env InKey)

theorem first_weights_table_eq (table table' : List F64) :
    weights (firstValues M K env table) = weights (firstValues M K env table') := by
  apply weights_congr
  intro t ht
  have he := covered_value_eq M K env (firstFfiGraph table) (firstFfiGraph table')
    code code.cert t (first_load_matches table SourceKernels.sources)
    (first_load_matches table' SourceKernels.sources) ht
  simp only [firstValues, headerValues, contents, he]

private theorem pipeline_eq (w w' : GlueStep.PipelineWeights)
    (shape : Reify.PayloadShape w) (shape' : Reify.PayloadShape w') (hw : w = w') :
    Reify.pipeline M K w shape = Reify.pipeline M K w' shape' := by
  cases hw
  rfl

/-- The mathematical model is fixed by checkpoint evaluation before any
token readback valuation is chosen. -/
theorem firstPipeline_table_eq (table table' : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) :
    firstPipeline M K env table leaves typed = firstPipeline M K env table' leaves typed := by
  exact pipeline_eq M K _ _
    (shapes_from_checkpoint M K env (firstFfiGraph table) leaves typed
      (first_load_matches table SourceKernels.sources))
    (shapes_from_checkpoint M K env (firstFfiGraph table') leaves typed
      (first_load_matches table' SourceKernels.sources))
    (first_weights_table_eq M K env table table')

private theorem context_heq (p p' : TokenInference.Pipeline) (w w' : GlueStep.PipelineWeights)
    (hl : GlueStep.PipelineLoaded M K p w) (hl' : GlueStep.PipelineLoaded M K p' w')
    (parameters : TokenSequenceRanges.Parameters p) (parameters' : TokenSequenceRanges.Parameters p')
    (hp : p = p') (hw : w = w') :
    HEq (GlueM1Max.context M K p w hl parameters) (GlueM1Max.context M K p' w' hl' parameters') := by
  cases hp
  cases hw
  rfl

theorem firstContext_table_heq (table table' : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (parameters' : TokenSequenceRanges.Parameters (firstPipeline M K env table' leaves typed)) :
    HEq (firstContext M K env table leaves typed parameters)
      (firstContext M K env table' leaves typed parameters') :=
  context_heq M K _ _ _ _ _ _ _ _ (firstPipeline_table_eq M K env table table' leaves typed)
    (first_weights_table_eq M K env table table')

private theorem context_run_token_eq {p p' : TokenInference.Pipeline}
    (ctx : ReachedTokenContext.Context p) (ctx' : ReachedTokenContext.Context p')
    (hp : p = p') (hc : HEq ctx ctx') (token : Fin 248320) (time : Nat) (ht : time ≤ 262144) :
    (ctx.run token time ht).token = (ctx'.run token time ht).token := by
  cases hp
  cases hc
  rfl

private theorem context_run_heq {p p' : TokenInference.Pipeline}
    (ctx : ReachedTokenContext.Context p) (ctx' : ReachedTokenContext.Context p')
    (hp : p = p') (hc : HEq ctx ctx') (token : Fin 248320) (time : Nat) (ht : time ≤ 262144) :
    HEq (ctx.run token time ht) (ctx'.run token time ht) := by
  cases hp
  cases hc
  rfl

theorem recurrence_state_table_heq (table table' : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (parameters' : TokenSequenceRanges.Parameters (firstPipeline M K env table' leaves typed))
    (time : Nat) (ht : time ≤ 262144) :
    HEq ((firstContext M K env table leaves typed parameters).run promptToken time ht)
      ((firstContext M K env table' leaves typed parameters').run promptToken time ht) :=
  context_run_heq _ _ (firstPipeline_table_eq M K env table table' leaves typed)
    (firstContext_table_heq M K env table table' leaves typed parameters parameters') promptToken time ht

/-- In particular, the computed token sequence cannot depend on the values
chosen for the symbolic native readbacks of that same sequence. -/
theorem recurrence_token_table_eq (table table' : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (parameters' : TokenSequenceRanges.Parameters (firstPipeline M K env table' leaves typed))
    (time : Nat) (ht : time ≤ 262144) :
    ((firstContext M K env table leaves typed parameters).run promptToken time ht).token =
      ((firstContext M K env table' leaves typed parameters').run promptToken time ht).token :=
  context_run_token_eq _ _ (firstPipeline_table_eq M K env table table' leaves typed)
    (firstContext_table_heq M K env table table' leaves typed parameters parameters') promptToken time ht

end Host.Load.Run.Full
