import host.load.run.full.FirstGraph
import host.mlx.ActualKernelCalls

set_option Elab.async false

namespace Host.Load.Run.Full.Kernel1354
open Host.Ts Host.Mlx.Ffi

theorem graph_at_yield : P.s2974.ffi.mlx = source := first_graph_matches

theorem source_call_at_yield (b off : Nat) :
    Host.Mlx.Ffi.call P.s2974.ffi.mlx chars!"mlx_closure_apply" [output b off,.big 1354,.big 18173] =
      okW (s3.newObj (.vec [17777,17778,17779])).2 status0 [u64Write b off source.next] := by
  rw [graph_at_yield]
  exact source_cached_call b off

end Host.Load.Run.Full.Kernel1354

namespace Host.Load.Run.Full.Kernel1362
open Host.Ts Host.Mlx.Ffi

theorem graph_at_yield : P.s2974.ffi.mlx = source := first_graph_matches

theorem source_call_at_yield (b off : Nat) :
    Host.Mlx.Ffi.call P.s2974.ffi.mlx chars!"mlx_closure_apply" [output b off,.big 1362,.big 18238] =
      okW (s2.newObj (.vec [17777,17778])).2 status0 [u64Write b off source.next] := by
  rw [graph_at_yield]
  exact source_cached_call b off

end Host.Load.Run.Full.Kernel1362

