import host.load.CacheCarriersCommand
import host.load.run.full.cached.FinalGraph
import host.load.run.full.cached.Carriers3
import host.load.run.full.cached.Choice3
import host.load.run.full.cached.expected2.Base
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Mlx Host.Mlx.FfiEval Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem before3_model : after2.model = parameterChoice.model := by rfl
theorem model3_preserved : after3.model = parameterChoice.model := by rfl
theorem offsets3 : after3.cache.map Cache.offset = List.replicate 64 3 := by rfl

theorem feedback3_node (table : List F64) :
    terminalGraph table token3.node = some ⟨.reshape [1,1], [20157]⟩ := by rfl

theorem output3_token : certAt carriers3 Expected3.tokenNode = 22538 := by rfl

load_cache_carriers output3_caches : after3.cache, Expected3.cacheOutputs, carriers3

theorem original3 : stepGraph Expected2.stages Expected2.head 2 =
    (Expected3.graph,Expected3.tokenNode,Expected3.cacheOutputs) := by
  change stepGraph Expected3.stages Expected3.head 2 = _
  exact Expected3.graph_original
end Host.Load.Run.Full.Cached
