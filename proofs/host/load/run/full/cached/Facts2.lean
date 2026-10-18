import host.load.CacheCarriersCommand
import host.load.run.full.cached.FinalGraph
import host.load.run.full.cached.Carriers2
import host.load.run.full.cached.Choice2
import host.load.run.full.cached.expected2.Base
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Mlx Host.Mlx.FfiEval Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem before2_model : firstChoice.model = parameterChoice.model := by exact first_parameters_preserved
theorem model2_preserved : after2.model = parameterChoice.model := by rfl
theorem offsets2 : after2.cache.map Cache.offset = List.replicate 64 2 := by rfl

theorem feedback2_node (table : List F64) :
    terminalGraph table token2.node = some ⟨.reshape [1,1], [17776]⟩ := by rfl

theorem output2_token : certAt carriers2 Expected2.tokenNode = 20157 := by rfl

load_cache_carriers output2_caches : after2.cache, Expected2.cacheOutputs, carriers2

theorem original2 : stepGraph Expected2.stages Expected2.head 1 =
    (Expected2.graph,Expected2.tokenNode,Expected2.cacheOutputs) := by
  change stepGraph Expected2.stages Expected2.head 1 = _
  exact Expected2.graph_original
end Host.Load.Run.Full.Cached
