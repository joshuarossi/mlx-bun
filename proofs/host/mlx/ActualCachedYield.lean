import host.load.run.full.FirstGraph
import host.mlx.ActualCachedCall

set_option Elab.async false

namespace Host.Load.Run.Full.CachedKernel
open Host.Ts Host.Mlx.Ffi

theorem graph_at_yield : P.s2974.ffi.mlx = source := first_graph_matches

/-- The source invocation is instantiated on the native projection of the
continuous interpreter boundary. Reachability of that boundary is supplied by
the separately checked source-run chain. -/
theorem source_call_at_yield (b off : Nat) :
    Host.Mlx.Ffi.call P.s2974.ffi.mlx chars!"mlx_closure_apply" [output b off,.big 1352,.big 18221] =
      okW (final.newObj (.vec [source.nnext])).2 status0 [u64Write b off source.next] := by
  rw [graph_at_yield]
  exact source_cached_call b off

end Host.Load.Run.Full.CachedKernel
