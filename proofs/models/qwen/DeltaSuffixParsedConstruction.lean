import models.qwen.ResidualMlpParsedConstruction
import models.qwen.ResidualDeltaConstruction
namespace Inference.Models.Qwen.DeltaSuffixParsedConstruction
open Contracts.Mlx Kernels Kernels.Delta Kernels.Trellis Layers
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF
variable {reduce : (Fin 32 → Float32) → Float32} {flags : Gated.Contraction}
  {initial : GatedDevice.State} {values : GatedInputs.Values}
  {recurrence : GatedShared.Execution reduce flags initial values}
  {gate : GatedRmsNormDevice.Rows} {weights : Fin 128 → BF}
  {tailInput : DeltaTailMemory.Input recurrence gate weights}
  {p : GatedRmsNorm.Platform} {width eps : Float32} {projection : AffineVerifyLinear.Projection 12 5120}
  {x : Fin 5120 → BF} {block : ResidualBlocks.Mlp}
  (tail : DeltaTailMemory.Execution tailInput p width eps projection)
  (source : ArrayStorage.BFBuffer x) (shared : source.bytes=recurrence.input.state.bytes)
  (sourceSafe : DeltaTailMemory.Safe tail source.base 10240)
  {history : State.ConvolutionStorage.History} (historyBuffer : State.ConvolutionStorage.Storage history)
  (historyShared : historyBuffer.bytes=recurrence.input.state.bytes)
  (historySafe : DeltaTailMemory.Safe tail historyBuffer.base 61440)
  (historyState : MemoryRegions.Disjoint historyBuffer.base 61440 recurrence.stores.trace.stateBase 3145728)
  (parameters : ResidualDeltaConstruction.SuffixParameters (block:=block) tail)
  (allocation : ResidualDeltaConstruction.SuffixAllocation tail source shared sourceSafe historyBuffer parameters)

def existing := ResidualDeltaConstruction.suffix tail source shared sourceSafe historyBuffer historyShared historySafe historyState parameters allocation

def attach (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential block.mlp.activation precise absolute)
    (inputBounded : ∀ group, (((existing tail source shared sourceSafe historyBuffer historyShared historySafe historyState parameters allocation).suffix).mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad) :
    ResidualMlpParsedTrellis.Source (existing tail source shared sourceSafe historyBuffer historyShared historySafe historyState parameters allocation).suffix :=
  ResidualMlpParsedConstruction.source (block:=block) (DeltaResidualMemory.residualInput tail source shared sourceSafe)
    parameters.normAfter rfl parameters.trellisAfter allocation.allocation precise absolute exponential inputBounded vector

end Inference.Models.Qwen.DeltaSuffixParsedConstruction
