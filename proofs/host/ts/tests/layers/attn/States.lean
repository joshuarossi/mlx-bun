import host.ts.tests.layers.AttnLayer
namespace Host.Ts.Tests.Layers.AttnLayer
open Host.Ts

/-! `QwenResidualAttentionLayer` 3 of the route, built by the repository's
`AttentionWeights.stage` over real `Weights` (MLX FFI model, checkpoint header
of layer 3), one decode forward at symbolic cache offset `n`, kernel-checked in chunks. `P.O`
is the run's oracle (its tests answered at `n = 5`). -/

host_chain_sym P : Host.Mlx.Ffi.ffi, boot0, [.var 0], (fun _ => F64.ofNat 5), 300000, [10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000]

end Host.Ts.Tests.Layers.AttnLayer
