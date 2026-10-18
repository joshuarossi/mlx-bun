import host.load.CacheCarriersCommand
import host.load.run.full.cached.FinalGraph
import host.load.run.full.cached.Carriers4
import host.load.run.full.cached.Choice4
import host.load.run.full.cached.expected2.Base
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Mlx Host.Mlx.FfiEval Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem before4_model : after3.model = parameterChoice.model := by rfl
theorem model4_preserved : after4.model = parameterChoice.model := by rfl
theorem offsets4 : after4.cache.map Cache.offset = List.replicate 64 4 := by rfl

theorem feedback4_node (table : List F64) :
    terminalGraph table token4.node = some ⟨.reshape [1,1], [22538]⟩ := by rfl

theorem output4_token : certAt carriers4 Expected4.tokenNode = 24919 := by rfl

load_cache_carriers output4_caches : after4.cache, Expected4.cacheOutputs, carriers4

theorem original4 : stepGraph Expected2.stages Expected2.head 3 =
    (Expected4.graph,Expected4.tokenNode,Expected4.cacheOutputs) := by
  change stepGraph Expected4.stages Expected4.head 3 = _
  exact Expected4.graph_original
end Host.Load.Run.Full.Cached
