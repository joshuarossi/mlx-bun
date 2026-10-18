import host.load.run.full.FirstGraph
import host.mlx.ActualShapelessCall

set_option Elab.async false

namespace Host.Load.Run.Full.Shapeless
open Host.Ts Host.Mlx.Ffi

theorem graph_at_yield : P.s2974.ffi.mlx = source := first_graph_matches

/-- This invocation uses the exact native projection of the continuous first
source yield; it does not assert that it is the next TypeScript invocation. -/
theorem source_call_at_yield (b off : Nat) :
    Host.Mlx.Ffi.call P.s2974.ffi.mlx chars!"mlx_closure_apply" [output b off,.big 18194,.big 18195] =
      okW (s8.newObj (.vec [17783])).2 status0 [u64Write b off source.next] := by
  rw [graph_at_yield]
  exact source_cached_call b off

end Host.Load.Run.Full.Shapeless
