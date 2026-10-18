import host.load.Native
import host.load.Choice
import host.load.run.full.H111
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full.Cached
open Host.Ts Host.Load.Extract
load_state_summary after5 : P.s3573, entryEnv P.s0
load_summary_checked loaded5 : P.s3573, entryEnv P.s0 using after5
kernel_rfl graph5_nodes_source : P.s3573.ffi.mlx.nodes = after5.graph.nodes
end Host.Load.Run.Full.Cached
