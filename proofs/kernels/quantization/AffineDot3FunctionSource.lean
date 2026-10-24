import kernels.quantization.AffineDot3LoopSource
import kernels.quantization.AffineDot4FunctionSource

namespace Inference.Kernels.Quantization.AffineDot3FunctionSource
open Contracts.Mlx ArithmeticFold AffineDot3Source AffineDot3LoopSource
open AffineDot4FunctionSource (startSource start_zero returned return_model)
set_option maxRecDepth 10000

-- Initialization and return belong to the same parsed qdot function as the
-- four-bit branch. Here the intervening body is the actual byte-based branch,
-- with two cumulative pointer updates and ten ordered statements per visit.
structure Execution (contracted : Nat → Bool) (tailContracted : Bool) (memory : Memory)
    (scale sum bias resultValue : Float32) : Prop where
  initial : startSource=some 0
  headerParsed : AffineDot4LoopSource.parseHeader sourceHeader=some header
  loop : Runs header contracted header.initial memory 0 [0,1] (result contracted memory 0)
  finish : returned tailContracted scale (result contracted memory 0) sum bias=some resultValue

theorem execution (contracted : Nat → Bool) (tailContracted : Bool) (memory : Memory) (scale sum bias : Float32)
    (packedRoom : memory.packedBase+6≤2^64) (scaledRoom : memory.scaledBase+16≤2^64)
    (finite : Arithmetic.Finite (AffineTile.tailBind scale (result contracted memory 0) sum bias)
      (AffineTile.tailExpr tailContracted)) :
    Execution contracted tailContracted memory scale sum bias
      (maddFloat tailContracted scale (result contracted memory 0) (FlushToZero.mul sum bias)) :=
  ⟨start_zero,parsed_header,AffineDot3LoopSource.execution contracted memory 0 packedRoom scaledRoom,
    return_model tailContracted scale _ sum bias finite⟩

def weights (memory : Memory) (chunk : Fin 2) : Fin 3 → BitVec 8 := bytes (slice memory chunk)
def inputs (memory : Memory) (chunk : Fin 2) : Fin 8 → Float32 := input (slice memory chunk)

theorem dot_eq (p : AffineTile.Platform) (x : Fin 16 → AffineTile.BF) (memory : Memory)
    (prepared : ∀ chunk offset, inputs memory chunk offset=AffineTile.prepared3 p x chunk offset) :
    result p.contracted memory 0=AffineTile.dot3 p x (weights memory) := by
  have same : inputs memory=AffineTile.prepared3 p x := funext (fun chunk => funext (prepared chunk))
  simp only [result,step,AffineTile.dot3,AffineTile.step3,←same,weights,inputs]

theorem tile_execution (p : AffineTile.Platform) (x : Fin 16 → AffineTile.BF)
    (memory : Memory) (scale bias : AffineTile.BF)
    (packedRoom : memory.packedBase+6≤2^64) (scaledRoom : memory.scaledBase+16≤2^64)
    (prepared : ∀ chunk offset, inputs memory chunk offset=AffineTile.prepared3 p x chunk offset)
    (finite : AffineTile.Finite3 p x (weights memory) scale bias) :
    Execution p.contracted p.tailContracted memory (BFloat16.widen scale)
      (AffineInput.summed x AffineInput.groups3) (BFloat16.widen bias)
      (AffineTile.value3 p x (weights memory) scale bias) := by
  have dot := dot_eq p x memory prepared
  have tail := finite.tail
  rw [←dot] at tail
  have run := execution p.contracted p.tailContracted memory (BFloat16.widen scale)
    (AffineInput.summed x AffineInput.groups3) (BFloat16.widen bias) packedRoom scaledRoom tail
  simpa only [dot,AffineTile.value3,AffineTile.combine] using run

end Inference.Kernels.Quantization.AffineDot3FunctionSource
