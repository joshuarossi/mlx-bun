import host.load.Native
import host.load.Decode
import host.load.Choice
import host.load.RoutePrompt
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
load_replay_summary parameterChoice : bootL (RoutePrompt.cx [9707]) Decode.world 2000, Decode.tab, Decode.valuation, 28172201
end Host.Load.Run.Prompt
