import kernels.trellis.DownDevice

namespace Inference.Kernels.Trellis.DownInputCongruence
open Contracts.Mlx Contracts.Mlx.M1Max
open DownExecution (PackedMatrix SimdReduction scalarRows_congr)

-- Only the 17408 input elements owned by the tensor can affect a result.
-- A total mathematical memory view needs no agreement outside that range.
theorem split_eq (words : PackedMatrix) (k : Nat) (scale input reference : Nat → Float32)
    (same : ∀ row, row<17408 → input row=reference row) (split column : Nat) (bound : split<128) :
    DownFlushToZero.splitSum words k scale input split column=DownFlushToZero.splitSum words k scale reference split column := by
  unfold DownFlushToZero.splitSum
  apply scalarRows_congr
  intro row start finish acc
  rw [same row (by omega)]

theorem partial_eq (words : PackedMatrix) (k : Nat) (scale input reference : Nat → Float32)
    (same : ∀ row, row<17408 → input row=reference row) (lane column : Nat) (bound : lane<32) :
    DownFlushToZero.partialSum words k scale input lane column=DownFlushToZero.partialSum words k scale reference lane column := by
  unfold DownFlushToZero.partialSum
  apply scalarRows_congr
  intro split start finish acc
  rw [split_eq words k scale input reference same _ column (by omega)]

theorem output_eq (trace : DownDevice.Trace load before base words k scale input) (hardware : LoadContract load)
    (aligned : base%4=0) (address : base+16384 ≤ 2^64) (bits : k=2 ∨ k=3 ∨ k=4)
    (reference : Nat → Float32) (same : ∀ row, row<17408 → input row=reference row)
    (reduce : SimdReduction) (convert : Float32 → Float32) (column : Nat) (hc : column<5120) :
    DownDevice.output trace reduce convert column=
      convert (reduce (fun lane => DownFlushToZero.partialSum words k scale reference lane.val column)) := by
  rw [DownDevice.output_correct trace hardware aligned address bits reduce convert column hc]
  apply congrArg convert
  apply congrArg reduce
  funext lane
  exact partial_eq words k scale input reference same lane.val column lane.isLt

end Inference.Kernels.Trellis.DownInputCongruence
