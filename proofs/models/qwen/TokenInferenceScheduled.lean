import models.qwen.Qwen38TrellisM1MaxScheduled

namespace Inference.Models.Qwen.TokenInferenceScheduled
open DecodeStage TokenInference Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

abbrev Execution (p : Pipeline) (c : p.graph.Cache n) (token : Fin 248320) (a : RopeAngles.Inputs) :=
  Qwen38TrellisM1MaxScheduled.Execution p.graph c (p.embedding.forward token) a

def Execution.canonical (p : Pipeline) (c : p.graph.Cache n) (token : Fin 248320) (a : RopeAngles.Inputs) :
    Execution p c token a :=
  DecodeChainScheduled.Execution.canonical p.graph.stages c (p.embedding.forward token) a

def run (p : Pipeline) (c : p.graph.Cache n) (token : Fin 248320) (a : RopeAngles.Inputs)
    (execution : Execution p c token a) : (Fin 248320 → BF) × p.graph.Cache (n+1) :=
  Qwen38TrellisM1MaxScheduled.run p.graph c (p.embedding.forward token) a execution

theorem run_eq (p : Pipeline) (c : p.graph.Cache n) (token : Fin 248320) (a : RopeAngles.Inputs)
    (execution : Execution p c token a) : run p c token a execution=p.run c token a :=
  Qwen38TrellisM1MaxScheduled.run_eq p.graph c (p.embedding.forward token) a execution

theorem run_correct (p : Pipeline) (c : p.graph.Cache n) (ct ce : p.graph.ReferenceCache n)
    (token : Fin 248320) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (execution : Execution p c token a)
    (hc : DecodeChain.CacheErrors p.graph.stages c ct ce) (hcf : DecodeChain.CachesFinite p.graph.stages c)
    (hf : p.Ranges c token a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : p.Capacities c ct ce token a aim ae hf) :
    (∀ i, |Model.toReal ((run p c token a execution).1 i)-(p.targetRun ct token aim).1 i| ≤
      (p.budgetRun c ct ce token a aim ae hf).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (run p c token a execution).2 (p.targetRun ct token aim).2
      (p.budgetRun c ct ce token a aim ae hf).2 ∧
    (∀ i, Model.isFinite ((run p c token a execution).1 i)=true) ∧
      DecodeChain.CachesFinite p.graph.stages (run p c token a execution).2 := by
  rw [run_eq]
  exact p.run_correct c ct ce token a aim ae hc hcf hf ha hb capacity

end Inference.Models.Qwen.TokenInferenceScheduled
