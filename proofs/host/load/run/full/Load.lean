import host.load.run.full.G2818
import host.load.run.full.ChoiceStates
import host.load.Choice
set_option Elab.async false
namespace Host.Load.Run.Full
open Host.Ts Host.Load

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
load_summary_checked parameters : P.s2818, entryEnv P.s0 using parameterChoice

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl graph_matches : P.s2818.ffi.mlx = parameterChoice.graph

set_option maxRecDepth 1000000 in
theorem loaded_marker : Decode.loadDone (entryEnv P.s0) P.s2818 = true := by rfl

set_option maxRecDepth 1000000 in
theorem stages_64 : parameters.model.stages.length = 64 := by rfl

set_option maxRecDepth 1000000 in
theorem caches_64 : parameters.cache.length = 64 := by rfl

end Host.Load.Run.Full
