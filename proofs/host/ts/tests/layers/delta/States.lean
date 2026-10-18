import host.ts.tests.layers.DeltaLayer
namespace Host.Ts.Tests.Layers.DeltaLayer
open Host.Ts

/-! `QwenResidualDeltaLayer` 1 of the route (`QwenFusedHeadsDeltaNet` mixer),
built by `DeltaWeights.stage` over real `Weights` (MLX FFI model, checkpoint
header of layer 1), two decode forwards from an empty `SSMCache` (the first
traces the compiled closures, the second replays them), kernel-checked in chunks. -/

host_chain P : Host.Mlx.Ffi.ffi, boot0, ⟨[], []⟩, [10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000]

end Host.Ts.Tests.Layers.DeltaLayer
