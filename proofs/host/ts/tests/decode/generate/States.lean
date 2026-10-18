import host.ts.tests.decode.Generate
namespace Host.Ts.Tests.Decode.Generate
open Host.Ts

/-! The generation run in chunks of 10000 steps, its tests answered at `n = 5`, `c = 256`,
`M = 5` and tokens `100 … 107` (`P.O`), and `forwarded` (the tokens whose KV entered the
cache) abstracted over states 37 … 75: from inside iteration 0 to before
`makeStats` reads it, every chunk holds for any contents of the array (`P.ac<k>`). -/

set_option maxHeartbeats 0 in
host_chain_abs P : Host.Mlx.Ffi.ffi, boot0, tab, (fun i => F64.ofNat ([5, 256, 5, 100, 101, 102, 103, 104, 105, 106, 107].getD i 0)), 800000, [10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000], 37, 75, "forwarded"

end Host.Ts.Tests.Decode.Generate
