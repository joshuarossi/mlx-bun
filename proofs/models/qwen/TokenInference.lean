import models.qwen.Qwen38TrellisM1Max
import layers.QuantizedEmbedding

namespace Inference.Models.Qwen.TokenInference
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Attention DecodeStage

structure Pipeline where
  embedding : Layers.QuantizedEmbedding.Layer
  graph : Qwen38TrellisM1Max.Graph

-- Token-to-logits arithmetic and all returned cache slots for one decode
-- step. This models the plain BF16 cache, dispatched one-/two-pass
-- attention, no-adapter route.
def Pipeline.run (p : Pipeline) (c : p.graph.Cache n) (token : Fin 248320) (a : RopeAngles.Inputs) :
    (Fin 248320 → BF) × p.graph.Cache (n+1) :=
  (p.graph.forward c (p.embedding.forward token) a,
    (DecodeChain.run p.graph.stages c (p.embedding.forward token) a).2)
noncomputable def Pipeline.targetRun (p : Pipeline) (c : p.graph.ReferenceCache n) (token : Fin 248320) (a : RopeAngles.Target) :
    (Fin 248320 → ℝ) × p.graph.ReferenceCache (n+1) :=
  (p.graph.target c (p.embedding.target token) a,
    (DecodeChain.targetRun p.graph.stages c (p.embedding.target token) a).2)

-- Range and capacity certificates are software obligations about the actual
-- model weights and reachable executions. They are not hardware axioms and
-- are not discharged merely by assembling this pipeline theorem.
structure Pipeline.Ranges (p : Pipeline) (c : p.graph.Cache n) (token : Fin 248320) (a : RopeAngles.Inputs) where
  embedding : p.embedding.Finite token
  graph : p.graph.Ranges c (p.embedding.forward token) a

noncomputable def Pipeline.budgetRun (p : Pipeline) (c : p.graph.Cache n) (ct ce : p.graph.ReferenceCache n)
    (token : Fin 248320) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target) (hf : p.Ranges c token a) :
    (Fin 248320 → ℝ) × p.graph.ReferenceCache (n+1) :=
  (p.graph.budget c ct ce (p.embedding.forward token) (p.embedding.target token) (p.embedding.budget token) a aim ae hf.graph,
    (DecodeChain.budgetRun p.graph.stages c ct ce (p.embedding.forward token) (p.embedding.target token)
      (p.embedding.budget token) a aim ae hf.graph.chain).2)

def Pipeline.Capacities (p : Pipeline) (c : p.graph.Cache n) (ct ce : p.graph.ReferenceCache n)
    (token : Fin 248320) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target) (hf : p.Ranges c token a) : Prop :=
  DecodeChain.Capacities p.graph.stages c ct ce (p.embedding.forward token) (p.embedding.target token)
    (p.embedding.budget token) a aim ae hf.graph.chain

theorem Pipeline.run_correct (p : Pipeline) (c : p.graph.Cache n) (ct ce : p.graph.ReferenceCache n)
    (token : Fin 248320) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (hc : DecodeChain.CacheErrors p.graph.stages c ct ce) (hcf : DecodeChain.CachesFinite p.graph.stages c)
    (hf : p.Ranges c token a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : p.Capacities c ct ce token a aim ae hf) :
    (∀ i, |Model.toReal ((p.run c token a).1 i) - (p.targetRun ct token aim).1 i| ≤
      (p.budgetRun c ct ce token a aim ae hf).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (p.run c token a).2 (p.targetRun ct token aim).2 (p.budgetRun c ct ce token a aim ae hf).2 ∧
    (∀ i, Model.isFinite ((p.run c token a).1 i) = true) ∧ DecodeChain.CachesFinite p.graph.stages (p.run c token a).2 := by
  have he := p.embedding.forward_error token hf.embedding
  have hef := p.embedding.forward_finite token hf.embedding
  have hg := p.graph.forward_error c ct ce (p.embedding.forward token) (p.embedding.target token) (p.embedding.budget token)
    a aim ae he hef hc hcf hf.graph ha hb capacity
  have hcache := p.graph.cache_error c ct ce (p.embedding.forward token) (p.embedding.target token) (p.embedding.budget token)
    a aim ae he hef hc hcf hf.graph ha hb capacity
  exact ⟨hg, hcache.1, p.graph.forward_finite c (p.embedding.forward token) a hf.graph, hcache.2⟩

end Inference.Models.Qwen.TokenInference
