import host.load.CacheCarriersCommand
import host.load.run.full.cached.FinalGraph
import host.load.run.full.cached.Carriers5
import host.load.run.full.cached.Choice5
import host.load.run.full.cached.expected2.Base
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Mlx Host.Mlx.FfiEval Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem before5_model : after4.model = parameterChoice.model := by rfl
theorem model5_preserved : after5.model = parameterChoice.model := by rfl
theorem offsets5 : after5.cache.map Cache.offset = List.replicate 64 5 := by rfl

theorem feedback5_node (table : List F64) :
    terminalGraph table token5.node = some ⟨.reshape [1,1], [24919]⟩ := by rfl

theorem output5_token : certAt carriers5 Expected5.tokenNode = 27300 := by rfl

load_cache_carriers output5_caches : after5.cache, Expected5.cacheOutputs, carriers5

theorem original5 : stepGraph Expected2.stages Expected2.head 4 =
    (Expected5.graph,Expected5.tokenNode,Expected5.cacheOutputs) := by
  change stepGraph Expected5.stages Expected5.head 4 = _
  exact Expected5.graph_original
end Host.Load.Run.Full.Cached
