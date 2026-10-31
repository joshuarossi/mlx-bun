import host.sim.compose.a4b.GraphColdCacheOpsIn
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter

kernel_rfl actual_cache_output_operations :
  (loadedT endLoad (entryEnv Host.Load.Run.Prompt.P.s0)).map (fun l => l.cache.map Cache.operation) =
    some cacheOperations
end Host.Ts.Sim.Compose.ColdGraph
