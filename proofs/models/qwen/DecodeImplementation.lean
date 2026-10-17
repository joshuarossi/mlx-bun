import models.qwen.MlpExecution
import models.qwen.AttentionExecution
import models.qwen.DeltaExecution
import models.qwen.TokenInference

namespace Inference.Models.Qwen.DecodeImplementation
open DecodeStage DecodeChain Kernels.Attention TokenInference
set_option maxRecDepth 10000

structure Implementation where
  mlp : MlpExecution.Implementation
  attention : AttentionExecution.Implementation
  delta : DeltaExecution.Implementation

def StageTrace (impl : Implementation) : (s : Stage) → Cache s n → Row BF → RopeAngles.Inputs → Type
  | .delta l, c, x, _ => (first : DeltaExecution.ResidualTrace impl.delta l x c) ×
      MlpExecution.ResidualTrace impl.mlp l.suffix x (DeltaExecution.mixed impl.delta l x c first)
  | .attention l, c, x, a => (first : AttentionExecution.ResidualTrace impl.attention l x a c) ×
      MlpExecution.ResidualTrace impl.mlp l.suffix x (AttentionExecution.mixed impl.attention l x a c first)

def StageTrace.canonical (impl : Implementation) : (s : Stage) → (c : Cache s n) → (x : Row BF) →
    (a : RopeAngles.Inputs) → StageTrace impl s c x a
  | .delta l, c, x, _ =>
      let first := impl.delta.canonical l.mixer (l.inputNorm.forward x) c
      ⟨first, impl.mlp.canonical l.suffix.mlp (l.suffix.inputBits x (DeltaExecution.mixed impl.delta l x c first))⟩
  | .attention l, c, x, a =>
      let first := impl.attention.canonical l.mixer (l.inputNorm.forward x) a c
      ⟨first, impl.mlp.canonical l.suffix.mlp (l.suffix.inputBits x (AttentionExecution.mixed impl.attention l x a c first))⟩

def stageForward (impl : Implementation) : (s : Stage) → (c : Cache s n) → (x : Row BF) → (a : RopeAngles.Inputs) →
    StageTrace impl s c x a → Row BF
  | .delta l, c, x, _, execution => MlpExecution.residualForward impl.mlp l.suffix x
      (DeltaExecution.mixed impl.delta l x c execution.1) execution.2
  | .attention l, c, x, a, execution => MlpExecution.residualForward impl.mlp l.suffix x
      (AttentionExecution.mixed impl.attention l x a c execution.1) execution.2

theorem stage_eq (impl : Implementation) (s : Stage) (c : Cache s n) (x : Row BF) (a : RopeAngles.Inputs)
    (execution : StageTrace impl s c x a) : stageForward impl s c x a execution=DecodeStage.forward s c x a := by
  cases s with
  | delta l =>
      change MlpExecution.residualForward impl.mlp l.suffix x
        (DeltaExecution.mixed impl.delta l x c execution.1) execution.2=l.forward c (fun _ => x) 0
      rw [MlpExecution.residual_eq]
      exact congrArg (l.suffix.forward x) (DeltaExecution.mixed_eq impl.delta l x c execution.1)
  | attention l =>
      change MlpExecution.residualForward impl.mlp l.suffix x
        (AttentionExecution.mixed impl.attention l x a c execution.1) execution.2=l.forward x a c
      rw [MlpExecution.residual_eq]
      exact congrArg (l.suffix.forward x) (AttentionExecution.mixed_eq impl.attention l x a c execution.1)

def stageCache (impl : Implementation) : (s : Stage) → (c : Cache s n) → (x : Row BF) → (a : RopeAngles.Inputs) →
    StageTrace impl s c x a → Cache s (n+1)
  | .delta l, c, x, _, execution => DeltaExecution.cacheAfter impl.delta l x c execution.1
  | .attention l, c, x, a, execution => AttentionExecution.cacheAfter impl.attention l x a c execution.1

theorem stage_cache_eq (impl : Implementation) (s : Stage) (c : Cache s n) (x : Row BF) (a : RopeAngles.Inputs)
    (execution : StageTrace impl s c x a) : stageCache impl s c x a execution=DecodeStage.cacheAfter s c x a := by
  cases s with
  | delta l => exact DeltaExecution.cache_eq impl.delta l x c execution.1
  | attention l => exact AttentionExecution.cache_eq impl.attention l x a c execution.1

def ChainTrace (impl : Implementation) : (stages : List Stage) → Caches stages n → Row BF → RopeAngles.Inputs → Type
  | [], _, _, _ => PUnit
  | s::rest, c, x, a => (first : StageTrace impl s c.1 x a) × ChainTrace impl rest c.2 (stageForward impl s c.1 x a first) a

def ChainTrace.canonical (impl : Implementation) : (stages : List Stage) → (c : Caches stages n) → (x : Row BF) →
    (a : RopeAngles.Inputs) → ChainTrace impl stages c x a
  | [], _, _, _ => ⟨⟩
  | s::rest, c, x, a =>
    let first := StageTrace.canonical impl s c.1 x a
    ⟨first, ChainTrace.canonical impl rest c.2 (stageForward impl s c.1 x a first) a⟩

def chain (impl : Implementation) : (stages : List Stage) → (c : Caches stages n) → (x : Row BF) → (a : RopeAngles.Inputs) →
    ChainTrace impl stages c x a → Row BF × Caches stages (n+1)
  | [], _, x, _, _ => (x, ⟨⟩)
  | s::rest, c, x, a, execution =>
    let tail := chain impl rest c.2 (stageForward impl s c.1 x a execution.1) a execution.2
    (tail.1, (stageCache impl s c.1 x a execution.1, tail.2))

theorem chain_eq (impl : Implementation) (stages : List Stage) (c : Caches stages n) (x : Row BF) (a : RopeAngles.Inputs)
    (execution : ChainTrace impl stages c x a) : chain impl stages c x a execution=DecodeChain.run stages c x a := by
  induction stages generalizing x with
  | nil => rfl
  | cons s rest ih =>
    have tail := ih c.2 (stageForward impl s c.1 x a execution.1) execution.2
    simp only [chain, tail, stage_eq, stage_cache_eq, DecodeChain.run]

abbrev PipelineTrace (impl : Implementation) (p : Pipeline) (cache : p.graph.Cache n)
    (token : Fin 248320) (angle : RopeAngles.Inputs) := ChainTrace impl p.graph.stages cache (p.embedding.forward token) angle

def pipeline (impl : Implementation) (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320)
    (angle : RopeAngles.Inputs) (execution : PipelineTrace impl p cache token angle) : (Fin 248320 → BF) × p.graph.Cache (n+1) :=
  let result := chain impl p.graph.stages cache (p.embedding.forward token) angle execution
  (p.graph.output.forward (p.graph.finalNorm.forward result.1), result.2)

theorem pipeline_eq (impl : Implementation) (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320)
    (angle : RopeAngles.Inputs) (execution : PipelineTrace impl p cache token angle) : pipeline impl p cache token angle execution=p.run cache token angle := by
  unfold pipeline
  rw [chain_eq]
  rfl

end Inference.Models.Qwen.DecodeImplementation
