import models.qwen.EmptyKvLineage
import models.qwen.TokenAutoregressiveMemoryConstruction
namespace Inference.Models.Qwen.InitialCopiedEntryLineage
open Contracts.Mlx Layers TokenInference TokenAutoregressiveMemoryConstruction
set_option maxRecDepth 10000

-- Empty attachments are preserved through the actual embedding execution;
-- the chain allocator does not need a fresh equality assumption for each head.
theorem canonical {p : Pipeline} {before : TokenAutoregressiveMemory.State p 0}
    (entry : Entry before)
    (initial : EmptyKvLineage.Canonical p.graph.stages before.logical.cache before.index.bytes before.caches) :
    EmptyKvLineage.Canonical p.graph.stages before.logical.cache entry.source.bytes entry.storage := by
  unfold Entry.storage
  exact EmptyKvLineage.embedding_caches before entry.embedding rfl entry.caches initial

end Inference.Models.Qwen.InitialCopiedEntryLineage
