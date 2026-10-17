import models.qwen.InitialCopiedTokenConstruction
import models.qwen.CapacityCopiedTokenConstruction
import models.qwen.InitialCopiedParameterFrame
import models.qwen.CapacityAttentionParameterFrame
namespace Inference.Models.Qwen.CopiedTokenBodyConstruction
open Contracts.Mlx Layers TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

def AffineRegion (p : AffineVerifyLinear.Projection steps rows) (w : AffineDevice.Storage p) (base size : Nat) : Prop :=
  ∀ property, AffineMemoryFrames.Protected p w property → property base size

theorem affine_regions (p : AffineVerifyLinear.Projection steps rows) (w : AffineDevice.Storage p) :
    AffineMemoryFrames.Protected p w (AffineRegion p w) := by
  cases p <;> exact ⟨fun _ safe => safe.1,fun _ safe => safe.2.1,fun _ safe => safe.2.2⟩

-- Only spans outside the original stage bundle need extra per-step geometry.
def Extra {p : Pipeline} {memory : ByteMemory.Bytes} (w : TokenParameterMemory.Storage p memory) (base size : Nat) : Prop :=
  (base=w.embedding.packedBase ∧ size=4*(248320*640)) ∨
  (base=w.embedding.scales.base ∧ size=2*(248320*80)) ∨
  (base=w.embedding.biases.base ∧ size=2*(248320*80)) ∨
  (base=w.graph.norm.base ∧ size=10240) ∨ AffineRegion p.graph.output w.graph.output base size

namespace Initial
variable {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  (embedding : TokenParameterConstruction.EmbeddingPlan original) {angle : RopeAngles.Inputs}
  (plan : InitialCopiedTokenConstruction.ChainPlan embedding angle)

def Path := InitialCopiedParameterFrame.RegionPath p.graph.stages .root before.logical.cache
  (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
  embedding.afterEmbedding.graph.stages plan (Extra embedding.afterEmbedding)

theorem parameters (path : Path embedding plan) :
    embedding.afterEmbedding.Protected (InitialCopiedTokenConstruction.ChainSafe embedding plan) := by
  let w := embedding.afterEmbedding
  have follows := InitialCopiedParameterFrame.path_safe p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan (Extra w) path
  have stages := InitialCopiedParameterFrame.protected_chain p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan
  refine ⟨follows _ _ (Or.inl ⟨rfl,rfl⟩),follows _ _ (Or.inr (Or.inl ⟨rfl,rfl⟩)),
    follows _ _ (Or.inr (Or.inr (Or.inl ⟨rfl,rfl⟩))),stages,
    follows _ _ (Or.inr (Or.inr (Or.inr (Or.inl ⟨rfl,rfl⟩)))),?_⟩
  exact AffineMemoryFrames.protected_mono _ _
    (fun _ _ region => follows _ _ (Or.inr (Or.inr (Or.inr (Or.inr region)))))
    (affine_regions p.graph.output w.graph.output)

def body (caches : InitialCopiedTokenConstruction.ChainCaches embedding plan) (path : Path embedding plan) :
    InitialCopiedTokenConstruction.BodyPlan embedding angle where
  chain := plan
  caches := caches
  parameters := parameters embedding plan path

theorem body_chain (caches : InitialCopiedTokenConstruction.ChainCaches embedding plan) (path : Path embedding plan) :
    (body embedding plan caches path).chain=plan := rfl
end Initial

namespace Capacity
variable {n : Nat} {p : Pipeline} {before : TokenAutoregressiveMemory.State p (n+1)}
  {original : TokenParameterMemory.Storage p before.index.bytes}
  (embedding : TokenParameterConstruction.EmbeddingPlan original) {angle : RopeAngles.Inputs}
  (plan : CapacityCopiedTokenConstruction.ChainPlan embedding angle)

def Path := CapacityAttentionParameterFrame.RegionPath p.graph.stages .root before.logical.cache
  (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
  embedding.afterEmbedding.graph.stages plan (Extra embedding.afterEmbedding)

theorem parameters (path : Path embedding plan) :
    embedding.afterEmbedding.Protected (CapacityCopiedTokenConstruction.ChainSafe embedding plan) := by
  let w := embedding.afterEmbedding
  have follows := CapacityAttentionParameterFrame.path_safe p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan (Extra w) path
  have stages := CapacityAttentionParameterFrame.protected_chain p.graph.stages .root before.logical.cache
    (p.embedding.forward before.logical.token) angle embedding.entry.source embedding.entry.storage
    embedding.afterEmbedding.graph.stages plan
  refine ⟨follows _ _ (Or.inl ⟨rfl,rfl⟩),follows _ _ (Or.inr (Or.inl ⟨rfl,rfl⟩)),
    follows _ _ (Or.inr (Or.inr (Or.inl ⟨rfl,rfl⟩))),stages,
    follows _ _ (Or.inr (Or.inr (Or.inr (Or.inl ⟨rfl,rfl⟩)))),?_⟩
  exact AffineMemoryFrames.protected_mono _ _
    (fun _ _ region => follows _ _ (Or.inr (Or.inr (Or.inr (Or.inr region)))))
    (affine_regions p.graph.output w.graph.output)

def body (caches : CapacityCopiedTokenConstruction.ChainCaches embedding plan) (path : Path embedding plan) :
    CapacityCopiedTokenConstruction.BodyPlan embedding angle where
  chain := plan
  caches := caches
  parameters := parameters embedding plan path

theorem body_chain (caches : CapacityCopiedTokenConstruction.ChainCaches embedding plan) (path : Path embedding plan) :
    (body embedding plan caches path).chain=plan := rfl
end Capacity

end Inference.Models.Qwen.CopiedTokenBodyConstruction
