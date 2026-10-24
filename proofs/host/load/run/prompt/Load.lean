import host.load.run.prompt.H88
import host.load.run.prompt.ChoiceStates
import host.load.Choice
import host.load.run.tail.Command
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load

/-! The load facts of `Full.Load` at this route's `loadDone` (boundary 2818), for every prompt. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
load_summary_checked parameters : P.s2818, entryEnv P.s0 using parameterChoice

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager parameters_all : ∀ fw : List Val, Extract.loaded (P.a2818 fw) (entryEnv P.s0) = some parameters

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager graph_matches : ∀ fw : List Val, (P.a2818 fw).ffi.mlx = parameterChoice.graph

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager loaded_marker : ∀ fw : List Val, Decode.loadDone (entryEnv P.s0) (P.a2818 fw) = true

set_option maxRecDepth 1000000 in
theorem stages_64 : parameters.model.stages.length = 64 := by rfl

set_option maxRecDepth 1000000 in
theorem caches_64 : parameters.cache.length = 64 := by rfl

end Host.Load.Run.Prompt
