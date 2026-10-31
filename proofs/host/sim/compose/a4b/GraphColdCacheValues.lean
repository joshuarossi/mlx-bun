import host.sim.compose.a4b.GraphColdCacheOffsets
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph

/- offsetOf_sound relates these reads to the actual numeric heap fields at
rho9=1. The offset in SimGraph.cacheT is a separate zero placeholder. -/
kernel_rfl actual_heap_cache_input_offsets : offsetsOf startLoad startSrv = some (List.replicate 64 0)
kernel_rfl actual_heap_cache_output_offsets : offsetsOf endLoad endSrv = some (List.replicate 64 1)
end Host.Ts.Sim.Compose.ColdGraph
