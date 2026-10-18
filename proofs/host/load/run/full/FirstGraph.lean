import host.load.run.full.FirstChoice
import host.load.run.full.ChoiceStates
import host.load.run.full.G2974

namespace Host.Load.Run.Full
open Host.Ts Host.Load

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

load_summary_checked firstParameters : P.s2974, entryEnv P.s0 using firstChoice

/-- The compact first-yield graph is exactly the native state reached by the
continuous source execution boundary, not an independently supplied graph. -/
theorem first_graph_matches : P.s2974.ffi.mlx = firstChoice.graph := by rfl

/-- Decode preserves the loaded model's projected parameter objects. Cache
changes are represented separately in the same source-state projection. -/
theorem first_parameters_preserved : firstChoice.model = parameterChoice.model := by rfl

theorem first_cache_count : firstChoice.cache.length = 64 := by rfl

end Host.Load.Run.Full
