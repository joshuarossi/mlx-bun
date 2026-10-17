import models.qwen.InitialCopiedEntryLineage
namespace Inference.Models.Qwen.InitialCopiedInitializationLineage
open Contracts.Mlx Layers TokenInference
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

theorem initialized (stages : List DecodeStage.Stage) (plan : InitialCacheMemory.Plan stages)
    (before : ByteMemory.Bytes) :
    EmptyKvLineage.Canonical stages (InitialState.caches stages) (InitialCacheMemory.execute stages plan before)
      (DecodeFrame.initial stages plan before) :=
  EmptyKvLineage.initial stages plan _ (InitialCacheMemory.execute_ready stages plan before)

theorem state (p : Pipeline) (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages)
    (before : ByteMemory.Bytes) (index : Inference.State.TokenStorage.Buffer token)
    (shared : index.bytes=InitialCacheMemory.execute p.graph.stages plan before) :
    let initial := TokenAutoregressiveMemory.initial p token plan before index shared
    EmptyKvLineage.Canonical p.graph.stages initial.logical.cache initial.index.bytes initial.caches :=
  EmptyKvLineage.transport shared.symm _ (initialized p.graph.stages plan before)

end Inference.Models.Qwen.InitialCopiedInitializationLineage
